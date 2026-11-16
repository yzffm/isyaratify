"""Module: ml.src.train

Arsitektur model MLP Landmark, pembersihan filter aturan 1 vs 2 tangan,
augmentasi koordinat aman (safe noise & scaling), proses training dengan class weight seimbang,
serta ekspor model ke format Keras (.keras) dan quantized TensorFlow Lite (.tflite).

Logika dirujuk dari:
- ml/notebooks/03_bisindo_mlp_landmark_final.ipynb (Sel 2, 4, dan 5)
"""

import argparse
import json
import os
import zipfile
from typing import Dict, List, Optional, Tuple, Union

import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.utils.class_weight import compute_class_weight
import tensorflow as tf

# Aturan kanonik BISINDO
HURUF_1_TANGAN = {"C", "E", "I", "J", "L", "O", "R", "U", "V", "Z"}
HURUF_2_TANGAN = {
    "A", "B", "D", "F", "G", "H", "K", "M", "N",
    "P", "Q", "S", "T", "W", "X", "Y"
}
HURUF_RAWAN_TERTUKAR = ["C", "D", "G", "J", "M", "N", "R", "S", "U", "Y"]


def load_extracted_data(
    features_path: str,
    labels_path: Optional[str] = None,
) -> Tuple[np.ndarray, np.ndarray]:
    """Memuat data fitur dan label dari file .npz, .npy, atau .csv."""
    if features_path.endswith(".npz"):
        data = np.load(features_path)
        X = data["X"].astype(np.float32)
        y = data["y"]
    elif features_path.endswith(".npy"):
        X = np.load(features_path).astype(np.float32)
        if labels_path is None:
            raise ValueError("labels_path (.npy) harus diberikan jika features_path adalah .npy")
        y = np.load(labels_path)
    else:
        raise ValueError(f"Format file tidak didukung: {features_path}. Gunakan .npz atau .npy")

    y = np.array([str(lbl).strip().upper() for lbl in y])
    print(f"Data termuat: {X.shape[0]} sampel | Dimensi fitur: {X.shape[1]}")
    return X, y


def filter_by_hand_count_rules(
    X_data: np.ndarray,
    y_raw: np.ndarray,
    min_samples_threshold: int = 10,
) -> Tuple[np.ndarray, np.ndarray]:
    """Membersihkan sampel berdasarkan aturan kanonik BISINDO 1 tangan vs 2 tangan.

    - Huruf 1 tangan: paksa slot koordinat tangan kedua (indeks 63..125) menjadi 0.0.
    - Huruf 2 tangan: seleksi sampel yang tangan keduanya terdeteksi (tidak 0 semua).
      Jika sampel 2 tangan yang tersisa < min_samples_threshold, fallback mempertahankan
      seluruh sampel kelas tersebut agar kelas tidak hilang.
    """
    X_clean = X_data.copy()
    valid_indices: List[int] = []

    for h in np.unique(y_raw):
        idx_class = np.where(y_raw == h)[0]

        if h in HURUF_1_TANGAN:
            # Paksa slot tangan ke-2 menjadi 0.0
            X_clean[idx_class, 63:] = 0.0
            valid_indices.extend(idx_class)

        elif h in HURUF_2_TANGAN:
            # Periksa sampel yang tangan keduanya terbaca (ada nilai non-zero di indeks 63..)
            has_second_hand = np.any(X_clean[idx_class, 63:] != 0, axis=1)
            idx_two_hands = idx_class[has_second_hand]

            if len(idx_two_hands) >= min_samples_threshold:
                valid_indices.extend(idx_two_hands)
            else:
                valid_indices.extend(idx_class)
        else:
            valid_indices.extend(idx_class)

    valid_indices = sorted(valid_indices)
    X_clean = X_clean[valid_indices]
    y_clean = y_raw[valid_indices]

    print(
        f"Filter 1 vs 2 tangan selesai: {len(X_clean)} sampel valid dari "
        f"{len(X_data)} sampel awal."
    )
    return X_clean, y_clean


def add_safe_noise(data_x: np.ndarray, noise_level: float) -> np.ndarray:
    """Menambahkan Gaussian noise hanya pada koordinat aktif (non-zero).

    Mencegah slot koordinat tangan ke-2 yang bernilai 0 (pada huruf 1 tangan)
    terkontaminasi oleh noise acak.
    """
    active_mask = (data_x != 0.0).astype(np.float32)
    noise = np.random.normal(0.0, noise_level, data_x.shape).astype(np.float32)
    return data_x + (noise * active_mask)


def augment_training_data(
    X_train: np.ndarray,
    y_train: np.ndarray,
    class_labels: np.ndarray,
    tricky_letters: Optional[List[str]] = None,
) -> Tuple[np.ndarray, np.ndarray]:
    """Augmentasi data koordinat landmark (noise aman, scaling, dan oversampling huruf rawan tertukar)."""
    if tricky_letters is None:
        tricky_letters = HURUF_RAWAN_TERTUKAR

    # 1. Augmentasi umum
    X_noise = add_safe_noise(X_train, 0.012)
    X_scale_up = X_train * 1.06
    X_scale_down = X_train * 0.94

    # 2. Penajaman khusus huruf rawan tertukar
    focus_indices = [
        np.where(class_labels == h)[0][0]
        for h in tricky_letters
        if h in class_labels
    ]

    mask_focus = np.isin(y_train, focus_indices)
    X_focus = X_train[mask_focus]
    y_focus = y_train[mask_focus]

    if len(X_focus) > 0:
        X_focus_1 = add_safe_noise(X_focus, 0.008)
        X_focus_2 = add_safe_noise(X_focus, 0.016)
        X_focus_3 = X_focus * 1.04

        X_train_aug = np.concatenate([
            X_train, X_noise, X_scale_up, X_scale_down,
            X_focus_1, X_focus_2, X_focus_3,
        ], axis=0)

        y_train_aug = np.concatenate([
            y_train, y_train, y_train, y_train,
            y_focus, y_focus, y_focus,
        ], axis=0)
    else:
        X_train_aug = np.concatenate([X_train, X_noise, X_scale_up, X_scale_down], axis=0)
        y_train_aug = np.concatenate([y_train, y_train, y_train, y_train], axis=0)

    # Acak urutan dataset augmentasi
    perm = np.random.permutation(len(X_train_aug))
    X_train_aug = X_train_aug[perm]
    y_train_aug = y_train_aug[perm]

    print(f"Total sampel training setelah augmentasi: {X_train_aug.shape[0]}")
    return X_train_aug, y_train_aug


def build_mlp_model(
    input_dim: int = 126,
    num_classes: int = 26,
    learning_rate: float = 0.001,
) -> tf.keras.Model:
    """Membangun arsitektur jaringan saraf tiruan (MLP) untuk landmark 126-d.

    Lapisan:
    - Input(126)
    - Dense(256, relu) -> BatchNormalization -> Dropout(0.3)
    - Dense(128, relu) -> BatchNormalization -> Dropout(0.25)
    - Dense(64, relu) -> BatchNormalization -> Dropout(0.2)
    - Dense(num_classes, softmax)
    """
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(input_dim,)),

        tf.keras.layers.Dense(256, activation="relu"),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),

        tf.keras.layers.Dense(128, activation="relu"),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.25),

        tf.keras.layers.Dense(64, activation="relu"),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.2),

        tf.keras.layers.Dense(num_classes, activation="softmax"),
    ])

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def train_mlp(
    X_train: np.ndarray,
    y_train: np.ndarray,
    X_val: np.ndarray,
    y_val: np.ndarray,
    num_classes: int,
    epochs: int = 80,
    batch_size: int = 32,
    learning_rate: float = 0.001,
    model_save_path: str = "artifacts/bisindo_mlp_landmark.keras",
) -> Tuple[tf.keras.Model, tf.keras.callbacks.History]:
    """Melatih model MLP dengan EarlyStopping, ReduceLROnPlateau, dan Class Weights."""
    os.makedirs(os.path.dirname(os.path.abspath(model_save_path)), exist_ok=True)

    # Hitung bobot kelas seimbang
    classes_present = np.unique(y_train)
    weights_arr = compute_class_weight("balanced", classes=classes_present, y=y_train)
    class_weights = {int(classes_present[i]): float(weights_arr[i]) for i in range(len(weights_arr))}

    model = build_mlp_model(
        input_dim=X_train.shape[1],
        num_classes=num_classes,
        learning_rate=learning_rate,
    )

    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_loss", patience=12, restore_best_weights=True, verbose=1
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss", factor=0.5, patience=5, min_lr=1e-5, verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint(
            model_save_path, monitor="val_accuracy", save_best_only=True, verbose=0
        ),
    ]

    print("\nMemulai Pelatihan Model MLP...")
    history = model.fit(
        X_train,
        y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        class_weight=class_weights,
        callbacks=callbacks,
        verbose=1,
    )

    # Pastikan model terakhir disimpan
    model.save(model_save_path)
    print(f"\nModel tersimpan di: {model_save_path}")
    return model, history


def export_to_tflite(
    model: tf.keras.Model,
    output_path: str = "artifacts/bisindo_mlp_landmark_quant.tflite",
    quantize: bool = True,
) -> str:
    """Mengonversi model Keras menjadi TensorFlow Lite (.tflite) quantized untuk Flutter on-device."""
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    if quantize:
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        print("Menerapkan kuantisasi default TFLite (Post-Training Dynamic Range Quantization)...")

    tflite_model = converter.convert()
    with open(output_path, "wb") as f:
        f.write(tflite_model)

    size_kb = os.path.getsize(output_path) / 1024
    print(f"Model TFLite berhasil diekspor: {output_path} ({size_kb:.2f} KB)")
    return output_path


def export_labels_and_rules(
    classes: List[str],
    output_json: str = "artifacts/labels_and_rules.json",
    output_txt: str = "artifacts/labels.txt",
    confidence_threshold: float = 0.55,
    smoothing_window: int = 7,
) -> None:
    """Menyimpan daftar label kelas dan konfigurasi aturan 1 vs 2 tangan ke file JSON & TXT."""
    os.makedirs(os.path.dirname(os.path.abspath(output_json)), exist_ok=True)
    os.makedirs(os.path.dirname(os.path.abspath(output_txt)), exist_ok=True)

    sorted_classes = [str(c).upper() for c in classes]

    with open(output_txt, "w", encoding="utf-8") as f:
        f.write("\n".join(sorted_classes))

    rules_meta = {
        "labels": sorted_classes,
        "input_dimension": 126,
        "huruf_1_tangan": sorted(list(HURUF_1_TANGAN)),
        "huruf_2_tangan": sorted(list(HURUF_2_TANGAN)),
        "confidence_threshold": confidence_threshold,
        "smoothing_window": smoothing_window,
    }

    with open(output_json, "w", encoding="utf-8") as f:
        json.dump(rules_meta, f, indent=2)

    print(f"Metadata label tersimpan di:\n  {output_json}\n  {output_txt}")


def bundle_artifacts_zip(
    file_paths: List[str],
    zip_path: str = "artifacts/signquest_ml_artifacts.zip",
) -> str:
    """Mengemas file model dan laporan ke dalam satu file ZIP terpadu."""
    os.makedirs(os.path.dirname(os.path.abspath(zip_path)), exist_ok=True)
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in file_paths:
            if os.path.exists(p):
                zf.write(p, arcname=os.path.basename(p))
    print(f"Paket artefak ZIP berhasil dibuat: {zip_path}")
    return zip_path


def run_training_pipeline(
    features_path: str,
    labels_path: Optional[str] = None,
    output_dir: str = "artifacts",
    epochs: int = 80,
    batch_size: int = 32,
    learning_rate: float = 0.001,
) -> Tuple[tf.keras.Model, tf.keras.callbacks.History, LabelEncoder, np.ndarray, np.ndarray]:
    """Menjalankan alur lengkap pembersihan, augmentasi, pelatihan, dan ekspor model."""
    os.makedirs(output_dir, exist_ok=True)

    # 1. Muat data
    X_raw, y_raw = load_extracted_data(features_path, labels_path)

    # 2. Filter aturan tangan
    X_clean, y_clean = filter_by_hand_count_rules(X_raw, y_raw)

    # 3. Label encoding
    le = LabelEncoder()
    y_encoded = le.fit_transform(y_clean)
    num_classes = len(le.classes_)

    # 4. Train/Test split stratified
    X_train, X_test, y_train, y_test = train_test_split(
        X_clean, y_encoded, test_size=0.2, random_state=42, stratify=y_encoded
    )

    # 5. Augmentasi data training
    X_train_aug, y_train_aug = augment_training_data(
        X_train, y_train, le.classes_, tricky_letters=HURUF_RAWAN_TERTUKAR
    )

    # 6. Pelatihan model
    model_keras_path = os.path.join(output_dir, "bisindo_mlp_landmark.keras")
    model, history = train_mlp(
        X_train=X_train_aug,
        y_train=y_train_aug,
        X_val=X_test,
        y_val=y_test,
        num_classes=num_classes,
        epochs=epochs,
        batch_size=batch_size,
        learning_rate=learning_rate,
        model_save_path=model_keras_path,
    )

    # 7. Ekspor TFLite
    tflite_path = os.path.join(output_dir, "bisindo_mlp_landmark_quant.tflite")
    export_to_tflite(model, output_path=tflite_path, quantize=True)

    # 8. Ekspor metadata label
    json_path = os.path.join(output_dir, "labels_and_rules.json")
    txt_path = os.path.join(output_dir, "labels.txt")
    export_labels_and_rules(list(le.classes_), output_json=json_path, output_txt=txt_path)

    # 9. Simpan test split untuk evaluasi
    test_split_path = os.path.join(output_dir, "test_split.npz")
    np.savez_compressed(test_split_path, X_test=X_test, y_test=y_test, classes=le.classes_)

    return model, history, le, X_test, y_test


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Training Pipeline MLP Landmark BISINDO")
    parser.add_argument(
        "--features-path",
        required=True,
        help="Path ke file .npz (berisi X dan y) atau .npy fitur hasil ekstraksi",
    )
    parser.add_argument(
        "--labels-path",
        default=None,
        help="Path ke file .npy label (jika features-path adalah file .npy)",
    )
    parser.add_argument(
        "--output-dir",
        default="artifacts",
        help="Direktori output artefak model",
    )
    parser.add_argument(
        "--epochs",
        type=int,
        default=80,
        help="Jumlah epoch pelatihan (default: 80)",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=32,
        help="Ukuran batch pelatihan (default: 32)",
    )
    parser.add_argument(
        "--lr",
        type=float,
        default=0.001,
        help="Learning rate awal optimizer Adam (default: 0.001)",
    )

    args = parser.parse_args()
    run_training_pipeline(
        features_path=args.features_path,
        labels_path=args.labels_path,
        output_dir=args.output_dir,
        epochs=args.epochs,
        batch_size=args.batch_size,
        learning_rate=args.lr,
    )
