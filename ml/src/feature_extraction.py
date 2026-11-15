"""Module: ml.src.feature_extraction

Fungsi ekstraksi landmark tangan (MediaPipe Hand Landmarker),
normalisasi koordinat spasial 21 titik per tangan (translasi wrist dan scaling),
serta pembentukan vektor fitur 126-dimensi untuk klasifikasi alfabet BISINDO.

Logika dirujuk dari:
- ml/notebooks/01_dataset_audit_comparison.ipynb
- ml/notebooks/02_feature_extraction_unimal_.ipynb
- ml/notebooks/03_bisindo_mlp_landmark_final.ipynb
"""

import argparse
import os
import urllib.request
from collections import defaultdict
from typing import Dict, List, Optional, Tuple

import cv2
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import numpy as np
import pandas as pd
from tqdm import tqdm

DEFAULT_MODEL_URL = (
    "https://storage.googleapis.com/mediapipe-models/hand_landmarker/"
    "hand_landmarker/float16/1/hand_landmarker.task"
)
DEFAULT_MODEL_PATH = "hand_landmarker.task"

# Pembagian huruf BISINDO berdasarkan jumlah tangan kanonik
HURUF_1_TANGAN = ("C", "E", "I", "J", "L", "O", "R", "U", "V", "Z")
HURUF_2_TANGAN = (
    "A", "B", "D", "F", "G", "H", "K", "M", "N",
    "P", "Q", "S", "T", "W", "X", "Y"
)


def ensure_model_exists(
    model_path: str = DEFAULT_MODEL_PATH,
    model_url: str = DEFAULT_MODEL_URL,
) -> str:
    """Mengunduh model hand_landmarker.task jika belum ada di path lokal."""
    if not os.path.exists(model_path):
        os.makedirs(os.path.dirname(os.path.abspath(model_path)), exist_ok=True)
        print(f"Mengunduh model MediaPipe Hand Landmarker dari:\n  {model_url}")
        urllib.request.urlretrieve(model_url, model_path)
        print(f"Model berhasil disimpan di: {model_path}")
    return model_path


def create_hand_detector(
    model_path: str = DEFAULT_MODEL_PATH,
    num_hands: int = 2,
    min_confidence: float = 0.5,
) -> vision.HandLandmarker:
    """Menginisialisasi MediaPipe Tasks HandLandmarker detector (hingga 2 tangan)."""
    ensure_model_exists(model_path)
    base_options = python.BaseOptions(model_asset_path=model_path)
    options = vision.HandLandmarkerOptions(
        base_options=base_options,
        num_hands=num_hands,
        min_hand_detection_confidence=min_confidence,
    )
    return vision.HandLandmarker.create_from_options(options)


def normalize_single_hand(landmarks) -> np.ndarray:
    """Normalisasi 21 landmark tangan (x, y, z) relatif terhadap wrist (titik 0).

    1. Translasi: koordinat wrist menjadi (0, 0, 0).
    2. Scaling: bagi dengan jarak Euclidean maksimum dari wrist agar skala konsisten
       terhadap jarak kamera (dengan epsilon proteksi pembagian nol).

    Mengembalikan vektor 1D berukuran 63 (21 x 3).
    """
    coords = np.array([[lm.x, lm.y, lm.z] for lm in landmarks], dtype=np.float32)

    # 1. Translasi wrist ke pusat (0, 0, 0)
    wrist = coords[0].copy()
    coords = coords - wrist

    # 2. Scaling jarak maksimum
    max_dist = float(np.max(np.linalg.norm(coords, axis=1)))
    if max_dist > 1e-6:
        coords = coords / max_dist

    return coords.flatten().astype(np.float32)  # 63 nilai


def extract_feature_vector(detection_result) -> Optional[np.ndarray]:
    """Mengekstrak vektor fitur 126-dimensi dari hasil deteksi MediaPipe.

    - Urutan kanonik tangan diurutkan dari kiri ke kanan berdasarkan X wrist di layar.
    - Tangan 1: 63 fitur ternormalisasi.
    - Tangan 2: 63 fitur ternormalisasi jika terdeteksi, atau 63 nol jika 1 tangan.
    - Total: 126 fitur float32.
    """
    if not detection_result.hand_landmarks:
        return None

    # Urutkan tangan dari kiri ke kanan berdasarkan koordinat X wrist
    hands_sorted = sorted(detection_result.hand_landmarks, key=lambda h: h[0].x)

    hand_1_features = normalize_single_hand(hands_sorted[0])

    if len(hands_sorted) > 1:
        hand_2_features = normalize_single_hand(hands_sorted[1])
    else:
        hand_2_features = np.zeros(63, dtype=np.float32)

    return np.concatenate([hand_1_features, hand_2_features]).astype(np.float32)


def extract_landmarks_from_image(
    image_path: str,
    detector: vision.HandLandmarker,
) -> Optional[np.ndarray]:
    """Membaca gambar dari disk dan menghasilkan vektor fitur 126-d via MediaPipe."""
    img_bgr = cv2.imread(image_path)
    if img_bgr is None:
        return None

    img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)
    detection_result = detector.detect(mp_image)

    return extract_feature_vector(detection_result)


def collect_class_images(base_path: str) -> Dict[str, List[str]]:
    """Mengumpulkan path gambar A-Z dari struktur folder dataset."""
    valid_ext = ('.jpg', '.jpeg', '.png', '.bmp', '.webp', '.JPG', '.PNG')
    class_images: Dict[str, List[str]] = defaultdict(list)

    for root, _, files in os.walk(base_path):
        folder_name = os.path.basename(root).strip().upper()
        if len(folder_name) == 1 and 'A' <= folder_name <= 'Z':
            for f in files:
                if f.endswith(valid_ext):
                    class_images[folder_name].append(os.path.join(root, f))

    return dict(class_images)


def extract_dataset_features(
    dataset_paths: List[str],
    detector: Optional[vision.HandLandmarker] = None,
    model_path: str = DEFAULT_MODEL_PATH,
    output_npz: Optional[str] = None,
    output_csv: Optional[str] = None,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Mengekstrak landmark dari satu atau lebih direktori dataset.

    Returns:
        X: array fitur bentuk (N, 126)
        y: array label string (N,)
        hand_counts: array jumlah tangan terdeteksi (N,)
    """
    if detector is None:
        detector = create_hand_detector(model_path=model_path)

    # Kumpulkan seluruh gambar
    combined_class_images: Dict[str, List[str]] = defaultdict(list)
    for p in dataset_paths:
        collected = collect_class_images(p)
        for label, img_list in collected.items():
            combined_class_images[label].extend(img_list)

    classes = sorted(combined_class_images.keys())
    total_imgs = sum(len(v) for v in combined_class_images.values())
    print(f"Total gambar ditemukan: {total_imgs} dari {len(classes)} kelas (A-Z).")

    features_list: List[np.ndarray] = []
    labels_list: List[str] = []
    hand_counts_list: List[int] = []

    for label in classes:
        imgs = combined_class_images[label]
        desc = f"Ekstraksi Kelas {label}"

        for img_path in tqdm(imgs, desc=desc, leave=False):
            img_bgr = cv2.imread(img_path)
            if img_bgr is None:
                continue

            img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)
            result = detector.detect(mp_image)

            feat = extract_feature_vector(result)
            if feat is not None:
                features_list.append(feat)
                labels_list.append(label)
                hand_counts_list.append(min(len(result.hand_landmarks), 2))

    X = np.array(features_list, dtype=np.float32)
    y = np.array(labels_list)
    hand_counts = np.array(hand_counts_list, dtype=np.int32)

    print(f"\nEkstraksi Selesai! Sampel berhasil diekstrak: {len(X)} | Dimensi: {X.shape}")

    # Simpan ke .npz jika path diberikan
    if output_npz:
        os.makedirs(os.path.dirname(os.path.abspath(output_npz)), exist_ok=True)
        np.savez_compressed(output_npz, X=X, y=y, num_hands=hand_counts)
        print(f"Vektor fitur tersimpan di: {output_npz}")

    # Simpan ke CSV jika path diberikan
    if output_csv:
        os.makedirs(os.path.dirname(os.path.abspath(output_csv)), exist_ok=True)
        cols = [f"h{h}_p{p}_{ax}" for h in (1, 2) for p in range(21) for ax in ("x", "y", "z")]
        df = pd.DataFrame(X, columns=cols)
        df.insert(0, "label", y)
        df.insert(1, "detected_hands", hand_counts)
        df.to_csv(output_csv, index=False)
        print(f"Tabel fitur CSV tersimpan di: {output_csv}")

    return X, y, hand_counts


def audit_dataset(
    dataset_name: str,
    raw_path: str,
    detector: vision.HandLandmarker,
    save_csv_path: Optional[str] = None,
) -> pd.DataFrame:
    """Menjalankan audit deteksi landmark per kelas sesuai standar notebook 01."""
    print(f"\n=== Memulai Audit Dataset: {dataset_name} ===")
    class_map = collect_class_images(raw_path)

    if not class_map:
        print(f"Tidak ada kelas A-Z ditemukan di: {raw_path}")
        return pd.DataFrame()

    results = []
    for label in sorted(class_map.keys()):
        image_paths = class_map[label]
        total = len(image_paths)
        success = 0
        failed = 0
        one_hand = 0
        two_hands = 0

        for path in image_paths:
            img_bgr = cv2.imread(path)
            if img_bgr is None:
                failed += 1
                continue

            img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)
            result = detector.detect(mp_image)
            num_detected = len(result.hand_landmarks) if result.hand_landmarks else 0

            if num_detected > 0:
                success += 1
                if num_detected == 1:
                    one_hand += 1
                else:
                    two_hands += 1
            else:
                failed += 1

        fail_pct = round((failed / total) * 100, 2) if total > 0 else 0.0
        results.append({
            "dataset": dataset_name,
            "class_label": label,
            "total_images": total,
            "success_images": success,
            "one_hand_detected": one_hand,
            "two_hands_detected": two_hands,
            "failed_images": failed,
            "failure_rate_pct": fail_pct,
        })
        print(f"Kelas {label}: {total} sampel | Sukses: {success} | Gagal: {fail_pct}%")

    df = pd.DataFrame(results)
    if save_csv_path:
        os.makedirs(os.path.dirname(os.path.abspath(save_csv_path)), exist_ok=True)
        df.to_csv(save_csv_path, index=False)
        print(f"Laporan audit tersimpan di: {save_csv_path}")

    return df


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ekstraksi Fitur Landmark MediaPipe BISINDO")
    parser.add_argument(
        "--dataset-dirs",
        nargs="+",
        required=True,
        help="Satu atau lebih direktori dataset gambar berstruktur kelas A-Z",
    )
    parser.add_argument(
        "--model-path",
        default=DEFAULT_MODEL_PATH,
        help="Path ke file hand_landmarker.task",
    )
    parser.add_argument(
        "--output-npz",
        default="artifacts/bisindo_landmarks_clean.npz",
        help="Path output file .npz hasil ekstraksi",
    )
    parser.add_argument(
        "--output-csv",
        default=None,
        help="Path output file .csv hasil ekstraksi (opsional)",
    )

    args = parser.parse_args()
    det = create_hand_detector(model_path=args.model_path)
    extract_dataset_features(
        dataset_paths=args.dataset_dirs,
        detector=det,
        output_npz=args.output_npz,
        output_csv=args.output_csv,
    )
