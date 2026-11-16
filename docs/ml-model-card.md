# Model Card — Isyaratify BISINDO Static Alphabet MLP (`1.0.0-mlp-unimal`)

Dokumen ini mencatat spesifikasi model Machine Learning on-device yang digunakan pada aplikasi **Isyaratify** sesuai standar `AGENTS.md` §6 dan `Technical-Docs.md` §7.7.

---

## 1. Identitas Model

| Atribut | Nilai |
|---|---|
| **Nama Model** | `bisindo_mlp_landmark` (`1.0.0-mlp-unimal`) |
| **Arsitektur** | Multilayer Perceptron (MLP) — `126 -> 256 (ReLU+BN) -> 128 (ReLU+BN) -> 64 (ReLU+BN) -> 26 (Softmax)` |
| **Tugas** | Klasifikasi 26 alfabet statis BISINDO (`A`–`Z`) berbasis koordinat landmark tangan MediaPipe |
| **Artefak Training** | `ml/artifacts/bisindo_mlp_landmark.keras`, `ml/artifacts/bisindo_mlp_landmark_quant.tflite` |
| **Artefak Runtime Flutter** | `frontend/assets/ml/classifier.json` (BatchNormalization ter-fuse ke layer Dense), `frontend/assets/ml/model_metadata.json` |
| **Lokasi Inferensi** | 100% On-Device (Flutter Web & Android APK) tanpa pengiriman frame ke server |

---

## 2. Dataset & Preprocessing

- **Dataset Utama:** Kandidat 2 — *Indonesian Sign Language BISINDO* (`agungmrf/indonesian-sign-language-bisindo` / Unimal), dipilih setelah audit komparatif MediaPipe terhadap 3 dataset publik (`ml/reports/audit_dataset_comparison.csv`).
- **Jumlah Sampel:** `11.470` gambar mentah $\rightarrow$ `9.070` sampel berhasil diekstrak landmark MediaPipe (`0` kelas dengan tingkat kegagalan $> 50\%$).
- **Skema Fitur (126 float):**
  1. Deteksi maksimum 2 tangan menggunakan MediaPipe Hand Landmarker (`21` titik $\times (x, y, z)$ per tangan).
  2. Urutkan tangan yang terdeteksi dari kiri ke kanan layar berdasarkan koordinat `wrist.x` (`landmark[0].x`).
  3. Normalisasi setiap tangan terhadap titik wrist-nya masing-masing (`coords - wrist`), lalu bagi dengan jarak Euclidean maksimum dari wrist ($\epsilon = 10^{-6}$).
  4. **Aturan 1 vs 2 Tangan (`labels_and_rules.json`):**
     - **Huruf 1 Tangan (10 kelas):** `C, E, I, J, L, O, R, U, V, Z` (indeks `63..125` bernilai `0.0`).
     - **Huruf 2 Tangan (16 kelas):** `A, B, D, F, G, H, K, M, N, P, Q, S, T, W, X, Y`.

---

## 3. Hasil Evaluasi (Test Split Stratified 20% — 1.814 Sampel)

- **Test Accuracy:** `95.76%` (`0.95755`)
- **Macro Precision:** `95.96%`
- **Macro Recall:** `95.60%`
- **Macro F1-Score:** `95.72%` (`0.95719`)
- **Parity Python vs Dart (`export_dart_model.py`):**
  - Selisih probabilitas absolut maksimum: `0.0000154` ($< 2 \times 10^{-5}$)
  - Kesepakatan prediksi kelas Top-1: `100.00%`
- **Parameter Stabilitas Real-Time:**
  - `confidence_threshold`: `0.55`
  - `smoothing_window`: `7` frame (`minMajorityCount: 4`)

Detail metrik per huruf tersedia di `ml/reports/baseline_classification_report.csv` dan visualisasi matriks konfusi tersedia di `ml/reports/confusion_matrix_mlp.png`.

---

## 4. Batasan Penggunaan

1. Model ini hanya mengenali **gestur alfabet statis BISINDO A–Z**, bukan penerjemah kalimat, percakapan, ekspresi wajah, atau gerakan dinamis.
2. Akurasi pada kamera nyata dipengaruhi oleh pencahayaan, latar belakang, jarak tangan ke kamera, dan oklusi jari.
3. Nilai skor softmax digunakan sebagai indikator keyakinan relatif untuk bantuan belajar, bukan probabilitas kebenaran absolut.
