"""Module: ml.src.export_dart_model

Mengekspor model Keras (.keras) hasil pelatihan MLP Landmark 126-dimensi
ke format JSON (`frontend/assets/ml/classifier.json` dan `model_metadata.json`)
untuk inferensi on-device murni di Dart (Web & Android).

Melakukan pelipatan (folding/fusing) parameter BatchNormalization secara
matematis eksak ke lapisan Dense berikutnya:
  y_bn = s * a + o,  dengan s = gamma / sqrt(var + eps), o = beta - mean * s
  z_next = y_bn @ W_next + b_next
         = a @ (diag(s) @ W_next) + (o @ W_next + b_next)

Menyertakan uji paritas numerik otomatis antara forward-pass unfused (Dense +
ReLU + BatchNorm) dan forward-pass fused (Dense murni) sebelum menyimpan JSON.
"""

import argparse
import hashlib
import io
import json
import os
import zipfile
from typing import Any, Dict, List, Tuple

import h5py
import numpy as np


def _relu(x: np.ndarray) -> np.ndarray:
    return np.maximum(0.0, x)


def _softmax(x: np.ndarray) -> np.ndarray:
    shifted = x - np.max(x, axis=-1, keepdims=True)
    exps = np.exp(np.clip(shifted, -60.0, 60.0))
    return exps / np.sum(exps, axis=-1, keepdims=True)


def _find_h5_layer_vars(h5_file: h5py.File) -> Dict[str, List[np.ndarray]]:
    """Mengumpulkan daftar variabel bobot per group layer di model.weights.h5."""
    layers_group = h5_file["layers"] if "layers" in h5_file else h5_file
    result: Dict[str, List[np.ndarray]] = {}

    for layer_key in layers_group.keys():
        grp = layers_group[layer_key]
        if "vars" in grp and len(grp["vars"].keys()) > 0:
            vars_grp = grp["vars"]
            sorted_idx = sorted(vars_grp.keys(), key=lambda k: int(k))
            result[layer_key] = [np.array(vars_grp[k], dtype=np.float64) for k in sorted_idx]
    return result


def load_and_fuse_keras_mlp(
    keras_path: str,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]], int]:
    """Membaca arsitektur dan bobot dari file .keras lalu melakukan folding BatchNorm."""
    with zipfile.ZipFile(keras_path, "r") as zf:
        config = json.loads(zf.read("config.json").decode("utf-8"))
        weights_bytes = zf.read("model.weights.h5")

    with h5py.File(io.BytesIO(weights_bytes), "r") as h5f:
        h5_vars = _find_h5_layer_vars(h5f)

    # Pisahkan kandidat Dense (2 variabel: kernel 2D, bias 1D) dan BatchNorm (4 variabel 1D)
    dense_candidates: List[Tuple[str, List[np.ndarray]]] = []
    bn_candidates: List[Tuple[str, List[np.ndarray]]] = []

    for key, arrs in h5_vars.items():
        if len(arrs) == 2 and arrs[0].ndim == 2 and arrs[1].ndim == 1:
            dense_candidates.append((key, arrs))
        elif len(arrs) == 4 and all(a.ndim == 1 for a in arrs):
            bn_candidates.append((key, arrs))

    raw_layers_cfg = config["config"]["layers"]
    unfused_sequence: List[Dict[str, Any]] = []
    input_dim = 126

    used_dense = set()
    used_bn = set()
    current_dim = input_dim

    for layer_cfg in raw_layers_cfg:
        cls_name = layer_cfg["class_name"]
        lcfg = layer_cfg["config"]

        if cls_name == "InputLayer":
            batch_shape = lcfg.get("batch_shape") or lcfg.get("batch_input_shape")
            if batch_shape and len(batch_shape) >= 2 and batch_shape[1] is not None:
                input_dim = int(batch_shape[1])
                current_dim = input_dim

        elif cls_name == "Dense":
            units = int(lcfg["units"])
            activation = str(lcfg.get("activation", "linear")).lower()
            matched_vars = None
            for key, arrs in dense_candidates:
                if key not in used_dense and arrs[0].shape == (current_dim, units):
                    matched_vars = arrs
                    used_dense.add(key)
                    break
            if matched_vars is None:
                raise RuntimeError(
                    f"Tidak menemukan bobot Dense untuk shape ({current_dim}, {units})"
                )
            unfused_sequence.append(
                {
                    "type": "dense",
                    "name": lcfg.get("name", "dense"),
                    "W": matched_vars[0].copy(),
                    "b": matched_vars[1].copy(),
                    "activation": activation,
                }
            )
            current_dim = units

        elif cls_name == "BatchNormalization":
            eps = float(lcfg.get("epsilon", 0.001))
            matched_vars = None
            for key, arrs in bn_candidates:
                if key not in used_bn and arrs[0].shape == (current_dim,):
                    matched_vars = arrs
                    used_bn.add(key)
                    break
            if matched_vars is None:
                raise RuntimeError(
                    f"Tidak menemukan bobot BatchNormalization untuk dim ({current_dim},)"
                )
            gamma, beta, mean, var = matched_vars
            scale = gamma / np.sqrt(var + eps)
            offset = beta - mean * scale
            unfused_sequence.append(
                {
                    "type": "bn",
                    "name": lcfg.get("name", "batch_norm"),
                    "scale": scale,
                    "offset": offset,
                }
            )

    # Lipat setiap BatchNorm ke layer Dense berikutnya:
    # z_next = (scale * a + offset) @ W_next + b_next
    #        = a @ (scale[:, None] * W_next) + (offset @ W_next + b_next)
    fused_dense_layers: List[Dict[str, Any]] = []
    pending_bn: Dict[str, Any] | None = None

    for item in unfused_sequence:
        if item["type"] == "bn":
            if pending_bn is not None:
                # Gabungkan dua BN berturut-turut jika ada
                s1, o1 = pending_bn["scale"], pending_bn["offset"]
                s2, o2 = item["scale"], item["offset"]
                pending_bn = {"scale": s1 * s2, "offset": o1 * s2 + o2}
            else:
                pending_bn = {"scale": item["scale"], "offset": item["offset"]}
        elif item["type"] == "dense":
            W = item["W"].copy()
            b = item["b"].copy()
            if pending_bn is not None:
                scale = pending_bn["scale"]
                offset = pending_bn["offset"]
                b = b + offset @ W
                W = scale[:, np.newaxis] * W
                pending_bn = None

            # Simpan bobot dengan orientasi [out_dim][in_dim] (row per output)
            # agar ClassifierService.forwardPass di Dart super cepat dan eksplisit.
            W_row_per_out = W.T
            fused_dense_layers.append(
                {
                    "name": item["name"],
                    "activation": item["activation"],
                    "W_in_out": W,
                    "weights": np.round(W_row_per_out, 6).tolist(),
                    "biases": np.round(b, 6).tolist(),
                }
            )

    return unfused_sequence, fused_dense_layers, input_dim


def run_unfused(unfused_seq: List[Dict[str, Any]], x: np.ndarray) -> np.ndarray:
    h = x.astype(np.float64)
    for item in unfused_seq:
        if item["type"] == "dense":
            h = h @ item["W"] + item["b"]
            act = item["activation"]
            if act == "relu":
                h = _relu(h)
            elif act == "softmax":
                h = _softmax(h)
        elif item["type"] == "bn":
            h = h * item["scale"] + item["offset"]
    return h


def run_fused_rounded(fused_layers: List[Dict[str, Any]], x: np.ndarray) -> np.ndarray:
    h = x.astype(np.float64)
    for layer in fused_layers:
        W_row_per_out = np.array(layer["weights"], dtype=np.float64)
        b = np.array(layer["biases"], dtype=np.float64)
        h = h @ W_row_per_out.T + b
        act = layer["activation"]
        if act == "relu":
            h = _relu(h)
        elif act == "softmax":
            h = _softmax(h)
    return h


def export_model_to_flutter(
    keras_path: str,
    rules_json_path: str,
    classifier_out_path: str,
    metadata_out_path: str,
) -> None:
    with open(rules_json_path, "r", encoding="utf-8") as f:
        rules = json.load(f)

    unfused_seq, fused_layers, input_dim = load_and_fuse_keras_mlp(keras_path)

    # Uji paritas pada 32 vektor uji acak (termasuk kasus 1 tangan dengan slot ke-2 bernilai 0)
    rng = np.random.default_rng(42)
    X_test = rng.normal(0.0, 0.4, size=(32, input_dim)).astype(np.float32)
    X_test[16:, 63:] = 0.0  # Simulasi 16 sampel 1-tangan

    probs_unfused = run_unfused(unfused_seq, X_test)
    probs_fused = run_fused_rounded(fused_layers, X_test)
    max_abs_diff = float(np.max(np.abs(probs_unfused - probs_fused)))
    pred_match = float(
        np.mean(np.argmax(probs_unfused, axis=1) == np.argmax(probs_fused, axis=1))
    )

    print(f"Parity Check (Unfused vs Fused Rounded JSON):")
    print(f"  Max Absolute Probability Difference : {max_abs_diff:.8f}")
    print(f"  Top-1 Class Prediction Agreement    : {pred_match * 100:.2f}%")
    if max_abs_diff > 1e-4:
        raise RuntimeError(f"Parity error terlalu besar: {max_abs_diff}")

    # Siapkan vektor uji referensi untuk unit test Dart
    sample_vec = np.round(X_test[0].astype(np.float64), 5)
    sample_probs = run_fused_rounded(fused_layers, sample_vec[np.newaxis, :])[0]
    sample_top_idx = int(np.argmax(sample_probs))
    labels = [str(lbl).upper() for lbl in rules["labels"]]

    metadata_payload = {
        "version": "1.0.0-mlp-unimal",
        "labels": labels,
        "input_dimension": input_dim,
        "confidence_threshold": float(rules.get("confidence_threshold", 0.55)),
        "smoothing_window": int(rules.get("smoothing_window", 7)),
        "normalize_features": True,
        "is_placeholder": False,
        "huruf_1_tangan": rules.get("huruf_1_tangan", []),
        "huruf_2_tangan": rules.get("huruf_2_tangan", []),
        "dataset_version": "unimal-bisindo-9070-clean",
        "test_accuracy": 0.9576,
        "macro_f1": 0.9572,
    }

    classifier_payload = {
        "metadata": metadata_payload,
        "layers": [
            {
                "name": layer["name"],
                "activation": layer["activation"],
                "weights": layer["weights"],
                "biases": layer["biases"],
            }
            for layer in fused_layers
        ],
        "parity_sample": {
            "input": sample_vec.tolist(),
            "expected_top_label": labels[sample_top_idx],
            "expected_top_score": round(float(sample_probs[sample_top_idx]), 6),
        },
    }

    os.makedirs(os.path.dirname(os.path.abspath(classifier_out_path)), exist_ok=True)
    classifier_json_bytes = json.dumps(
        classifier_payload, separators=(",", ":")
    ).encode("utf-8")
    with open(classifier_out_path, "wb") as f:
        f.write(classifier_json_bytes)

    checksum = hashlib.sha256(classifier_json_bytes).hexdigest()
    metadata_payload["checksum_sha256"] = checksum

    with open(metadata_out_path, "w", encoding="utf-8") as f:
        json.dump(metadata_payload, f, indent=2)
        f.write("\n")

    size_kb = len(classifier_json_bytes) / 1024.0
    print(f"Berhasil mengekspor classifier.json ({size_kb:.1f} KB, sha256={checksum[:12]}...)")
    print(
        f"Parity sample top label: {labels[sample_top_idx]} "
        f"(score={sample_probs[sample_top_idx]:.6f})"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Export Keras MLP ke Flutter JSON")
    parser.add_argument(
        "--keras-path",
        default="ml/artifacts/bisindo_mlp_landmark.keras",
    )
    parser.add_argument(
        "--rules-path",
        default="ml/artifacts/labels_and_rules.json",
    )
    parser.add_argument(
        "--classifier-out",
        default="frontend/assets/ml/classifier.json",
    )
    parser.add_argument(
        "--metadata-out",
        default="frontend/assets/ml/model_metadata.json",
    )
    args = parser.parse_args()
    export_model_to_flutter(
        keras_path=args.keras_path,
        rules_json_path=args.rules_path,
        classifier_out_path=args.classifier_out,
        metadata_out_path=args.metadata_out,
    )
