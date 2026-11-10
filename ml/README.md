# Machine Learning Pipeline — Isyaratify

Direktori ini memuat notebook eksperimen, skrip ekstraksi landmark/training, artefak model, dan laporan evaluasi untuk klasifikasi **alfabet statis BISINDO (A–Z, 26 kelas)** berbasis landmark tangan MediaPipe.

> **Prinsip utama (`AGENTS.md` §6):**
> - MediaPipe digunakan untuk mengekstrak 21 landmark per tangan (maksimum 2 tangan), sedangkan classifier mengklasifikasikan fitur landmark menjadi huruf A–Z.
> - Inferensi pada aplikasi Flutter berjalan **on-device** (tanpa mengunggah frame kamera ke server).
> - Jangan mengklaim dataset atau model telah tervalidasi sebelum audit dan evaluasi selesai.

---

## 1. Status Audit Dataset (Gate DG-01: **Terbuka / Sedang Dievaluasi**)

Pada Minggu 1 (PR #1 — `ml/notebooks/01_dataset_audit_comparison.ipynb`), Anggota 6 (Muhammad Nur Ilham) telah menjalankan audit ekstraksi landmark menggunakan **MediaPipe Hand Landmarker** (`num_hands=2`, `min_hand_detection_confidence=0.5`) terhadap tiga kandidat dataset publik:

| Kandidat Dataset | Sumber / URL | Jumlah Kelas | Total Gambar | Berhasil Diekstrak | 1 Tangan | 2 Tangan | Gagal | Failure Rate (%) | Kelas Gagal >50% |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **Kandidat 1 (UMN ~312)** | Kaggle: `achmadnoer/alfabet-bisindo` (rujukan repositori UMN) | 26 | 312 | 281 | 195 | 86 | 31 | 9.94% | 1 (`Z`: 66.67%) |
| **Kandidat 2 (Unimal ~11.500)** | Kaggle: `agungmrf/indonesian-sign-language-bisindo` (rujukan prosiding MICOMS Unimal) | 26 | 11.470 | 9.070 | 5.446 | 3.624 | 2.400 | 20.92% | 0 |
| **Kandidat 3 (Mendeley 796 MB)** | Mendeley Data: `4xnkvr88tk/1` | 26 | 8.040 | 5.763 | 3.219 | 2.544 | 2.277 | 28.32% | 1 (`V`: 51.33%) |

Laporan detail per kelas (A–Z) tersimpan di:
- `ml/reports/audit_dataset_comparison.csv`
- `ml/reports/audit_kandidat_1_umn.csv`
- `ml/reports/audit_kandidat_2_unimal.csv`
- `ml/reports/audit_kandidat_3_mendeley.csv`

### Catatan Keputusan DG-01 (Per 10 November 2026)
- **Status:** **Belum dikunci (Masih dievaluasi oleh Anggota 6).**
- **Temuan Teknis Penting:**
  1. Kandidat 1 terlalu kecil (12 gambar/kelas) dan huruf `Z` hanya menyisakan 4 sampel berhasil.
  2. Kandidat 2 memiliki jumlah sampel berhasil terbesar (9.070 gambar) dan satu-satunya yang tidak memiliki kelas dengan tingkat kegagalan >50%, namun pada sejumlah huruf dua tangan (`B`, `D`, `F`, `G`, `H`, `K`, `M`, `N`, `P`, `Q`, `S`, `T`, `W`, `X`) terdapat proporsi sampel yang hanya terdeteksi 1 tangan akibat oklusi saat kedua tangan bersentuhan.
  3. Anggota 6 saat ini sedang mengevaluasi kandidat dataset tambahan dan strategi pembersihan sampel sebelum mengunci dataset final untuk tahap training Minggu 3.

---

## 2. Kontrak Fitur & Landmark Lintas Platform (ADR 0002)

Agar hasil training Python di Google Colab/Kaggle kompatibel 100% dengan inferensi Dart di Flutter (`frontend/lib/models/hand_landmark_model.dart` dan `frontend/lib/services/feature_service.dart`), ikuti spesifikasi berikut:

1. **Urutan Kanonik Tangan:** `left` terlebih dahulu, kemudian `right`.
   - Bila MediaPipe mendeteksi 2 tangan dengan label `handedness` yang sama pada satu gambar/frame, urutkan berdasarkan koordinat `x` wrist (`landmark[0].x` lebih kecil = `left`, lebih besar = `right`).
2. **Representasi Landmark Mentah:**
   - 21 landmark per tangan $\times$ $(x, y, z)$ = 63 nilai per tangan (total 126 nilai koordinat untuk `[left, right]`).
   - 2 indikator *presence* (`[hasLeft, hasRight]` / `[1.0, 0.0]`).
   - Total vektor fitur dasar: **128 nilai** (126 koordinat ternormalisasi + 2 indikator presence).
3. **Normalisasi Fitur Standar (`FeatureService`):**
   - Setiap tangan yang terdeteksi ditranslasikan terhadap titik *wrist* (`landmark[0]`) tangan tersebut sehingga wrist berada pada $(0, 0, 0)$, lalu dibagi dengan skala tangan (jarak Euklides maksimum 2D/3D dari wrist ke landmark pada tangan tersebut, dengan batas bawah $\epsilon = 10^{-6}$).
   - Tangan yang tidak terdeteksi diisi `0.0` pada ke-63 nilai koordinatnya dan memiliki indikator presence `0.0`.

---

## 3. Struktur Folder `ml/`

```text
ml/
├── README.md
├── requirements.txt
├── notebooks/
│   └── 01_dataset_audit_comparison.ipynb
├── reports/
│   ├── audit_dataset_comparison.csv
│   ├── audit_kandidat_1_umn.csv
│   ├── audit_kandidat_2_unimal.csv
│   └── audit_kandidat_3_mendeley.csv
├── src/
└── artifacts/
```
