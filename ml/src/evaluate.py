"""Module: ml.src.evaluate

Evaluasi model klasifikasi alfabet BISINDO:
- Perhitungan akurasi dan loss pada data uji (Test Set).
- Pembuatan dan ekspor Classification Report (per huruf A-Z) ke teks dan CSV.
- Pembuatan visualisasi Confusion Matrix dengan Seaborn.
- Pembuatan grafik riwayat training (kurva akurasi dan loss per epoch).
- Pengujian langsung model TensorFlow Lite (.tflite) menggunakan TFLite Interpreter.

Logika dirujuk dari:
- ml/notebooks/02_feature_extraction_unimal_.ipynb (Sel 3)
- ml/notebooks/03_bisindo_mlp_landmark_final.ipynb (Sel 3 dan 5)
"""

import argparse
import os
from typing import Any, Dict, List, Optional, Tuple, Union

import matplotlib
# Gunakan backend non-GUI agar aman dijalankan pada server/CLI/headless environment
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix
import tensorflow as tf


def evaluate_keras_model(
    model: tf.keras.Model,
    X_test: np.ndarray,
    y_test: np.ndarray,
    class_names: List[str],
) -> Dict[str, Any]:
    """Mengevaluasi model Keras pada data uji (loss, akurasi, dan classification report)."""
    print("\n" + "=" * 50)
    print("Mengevaluasi Model Keras pada Test Set...")
    print("=" * 50)

    test_loss, test_acc = model.evaluate(X_test, y_test, verbose=0)
    print(f"Test Accuracy : {test_acc:.4f} ({test_acc * 100:.2f}%)")
    print(f"Test Loss     : {test_loss:.4f}")
    print("=" * 50)

    y_pred_probs = model.predict(X_test, verbose=0)
    y_pred = np.argmax(y_pred_probs, axis=1)

    report_str = classification_report(
        y_test, y_pred, target_names=class_names, digits=4
    )
    report_dict = classification_report(
        y_test, y_pred, target_names=class_names, output_dict=True
    )

    print("\nClassification Report:\n")
    print(report_str)

    return {
        "test_loss": float(test_loss),
        "test_accuracy": float(test_acc),
        "y_pred": y_pred,
        "y_pred_probs": y_pred_probs,
        "report_str": report_str,
        "report_dict": report_dict,
    }


def evaluate_tflite_model(
    tflite_path: str,
    X_test: np.ndarray,
    y_test: np.ndarray,
    class_names: List[str],
) -> Dict[str, Any]:
    """Mengevaluasi model TFLite (.tflite) terkuantisasi menggunakan TFLite Interpreter."""
    if not os.path.exists(tflite_path):
        raise FileNotFoundError(f"Model TFLite tidak ditemukan: {tflite_path}")

    print("\n" + "=" * 50)
    print(f"Mengevaluasi Model TFLite ({os.path.basename(tflite_path)})...")
    print("=" * 50)

    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    input_index = input_details[0]["index"]
    output_index = output_details[0]["index"]

    y_pred_list: List[int] = []
    correct_count = 0
    total_samples = len(X_test)

    for i in range(total_samples):
        sample = np.expand_dims(X_test[i], axis=0).astype(input_details[0]["dtype"])
        interpreter.set_tensor(input_index, sample)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_index)[0]

        pred_class = int(np.argmax(output_data))
        y_pred_list.append(pred_class)
        if pred_class == y_test[i]:
            correct_count += 1

    tflite_acc = correct_count / total_samples
    y_pred = np.array(y_pred_list)

    print(f"TFLite Test Accuracy: {tflite_acc:.4f} ({tflite_acc * 100:.2f}%)")
    print("=" * 50)

    report_str = classification_report(
        y_test, y_pred, target_names=class_names, digits=4
    )
    report_dict = classification_report(
        y_test, y_pred, target_names=class_names, output_dict=True
    )

    return {
        "test_accuracy": float(tflite_acc),
        "y_pred": y_pred,
        "report_str": report_str,
        "report_dict": report_dict,
    }


def plot_training_history(
    history: Any,
    output_path: str = "artifacts/grafik_training_mlp.png",
) -> str:
    """Menggambar grafik kurva akurasi dan loss per epoch untuk training vs validasi."""
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)

    # Dukung objek tf.keras.callbacks.History atau dict history biasa
    hist_dict = history.history if hasattr(history, "history") else history

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # 1. Plot Akurasi
    if "accuracy" in hist_dict:
        axes[0].plot(hist_dict["accuracy"], label="Train Accuracy", linewidth=2, color="#453FD6")
    if "val_accuracy" in hist_dict:
        axes[0].plot(hist_dict["val_accuracy"], label="Validation Accuracy", linewidth=2, color="#FFC93C")
    axes[0].set_title("Grafik Akurasi Model MLP Landmark BISINDO", fontsize=12, fontweight="bold")
    axes[0].set_xlabel("Epoch")
    axes[0].set_ylabel("Accuracy")
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # 2. Plot Loss
    if "loss" in hist_dict:
        axes[1].plot(hist_dict["loss"], label="Train Loss", linewidth=2, color="#BA1A1A")
    if "val_loss" in hist_dict:
        axes[1].plot(hist_dict["val_loss"], label="Validation Loss", linewidth=2, color="#00662B")
    axes[1].set_title("Grafik Loss Model MLP Landmark BISINDO", fontsize=12, fontweight="bold")
    axes[1].set_xlabel("Epoch")
    axes[1].set_ylabel("Loss")
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(output_path, dpi=150)
    plt.close(fig)

    print(f"Grafik training berhasil disimpan di: {output_path}")
    return output_path


def plot_confusion_matrix(
    y_true: np.ndarray,
    y_pred: np.ndarray,
    class_names: List[str],
    output_path: str = "artifacts/confusion_matrix_mlp.png",
    title: str = "Confusion Matrix - Test Set (MLP Landmark BISINDO)",
) -> str:
    """Menggambar heatmap confusion matrix berukuran 26x26 (A-Z) menggunakan Seaborn."""
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)

    cm = confusion_matrix(y_true, y_pred)
    fig_cm = plt.figure(figsize=(14, 11))

    sns.heatmap(
        cm,
        annot=True,
        fmt="d",
        cmap="Blues",
        xticklabels=class_names,
        yticklabels=class_names,
        cbar=True,
    )
    plt.title(title, fontsize=14, fontweight="bold", pad=12)
    plt.xlabel("Predicted Label (Huruf Tebakan Model)", fontsize=11)
    plt.ylabel("True Label (Huruf Sebenarnya)", fontsize=11)
    plt.tight_layout()
    plt.savefig(output_path, dpi=150)
    plt.close(fig_cm)

    print(f"Confusion matrix berhasil disimpan di: {output_path}")
    return output_path


def save_classification_report_csv(
    report_dict: Dict[str, Any],
    output_path: str = "artifacts/classification_report.csv",
) -> str:
    """Menyimpan dictionary classification report ke dalam file CSV terstruktur."""
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    df_report = (
        pd.DataFrame(report_dict)
        .transpose()
        .reset_index()
        .rename(columns={"index": "class"})
    )
    df_report.to_csv(output_path, index=False)
    print(f"Laporan klasifikasi CSV tersimpan di: {output_path}")
    return output_path


def run_evaluation_pipeline(
    model_path: str,
    test_data_path: str,
    output_dir: str = "artifacts",
) -> Dict[str, Any]:
    """Menjalankan evaluasi komprehensif pada model (.keras atau .tflite)."""
    os.makedirs(output_dir, exist_ok=True)

    # 1. Muat data uji
    test_data = np.load(test_data_path)
    X_test = test_data["X_test"].astype(np.float32)
    y_test = test_data["y_test"]
    classes = [str(c).upper() for c in test_data["classes"]]

    # 2. Jalankan evaluasi sesuai jenis model
    if model_path.endswith(".tflite"):
        eval_result = evaluate_tflite_model(
            tflite_path=model_path,
            X_test=X_test,
            y_test=y_test,
            class_names=classes,
        )
    else:
        model = tf.keras.models.load_model(model_path)
        eval_result = evaluate_keras_model(
            model=model,
            X_test=X_test,
            y_test=y_test,
            class_names=classes,
        )

    # 3. Simpan Confusion Matrix
    cm_path = os.path.join(output_dir, "confusion_matrix_mlp.png")
    plot_confusion_matrix(
        y_true=y_test,
        y_pred=eval_result["y_pred"],
        class_names=classes,
        output_path=cm_path,
    )

    # 4. Simpan Classification Report CSV
    csv_path = os.path.join(output_dir, "classification_report.csv")
    save_classification_report_csv(
        report_dict=eval_result["report_dict"],
        output_path=csv_path,
    )

    return eval_result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Evaluasi Model MLP Landmark BISINDO")
    parser.add_argument(
        "--model-path",
        required=True,
        help="Path ke file model (.keras atau .tflite)",
    )
    parser.add_argument(
        "--test-data-path",
        required=True,
        help="Path ke file .npz yang berisi X_test, y_test, dan classes",
    )
    parser.add_argument(
        "--output-dir",
        default="artifacts",
        help="Direktori penyimpanan grafik dan laporan evaluasi",
    )

    args = parser.parse_args()
    run_evaluation_pipeline(
        model_path=args.model_path,
        test_data_path=args.test_data_path,
        output_dir=args.output_dir,
    )
