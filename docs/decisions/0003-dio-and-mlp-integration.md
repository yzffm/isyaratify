# 0003 — Integrasi HTTP Client `dio`, Fused MLP 126-Dimensi On-Device, dan Cloudflare Auto-Deploy

Status: diterima (Minggu 3–6) · Pemilik: Anggota 1 (bersama Anggota 5 & 6)

## Konteks
Menjelang rilis demo dan penyelesaian milestone Minggu 3–6:
1. **Unifikasi HTTP Client (`dio`):** Sebelumnya `PlatformHttpClient` memelihara dua adapter terpisah (`dart:io` `HttpClient` di Android dan JS `fetch` interop manual di Web). Dibutuhkan satu HTTP client terstandar dengan interceptor header JSON, timeout seragam, dan pemetaan `DioException` ke `ApiException`.
2. **Parity Model MLP Python ↔ Dart (`95.76%` Test Accuracy):** Anggota 6 telah melatih model MLP pada dataset Unimal BISINDO (`9.070` sampel valid, 26 kelas A–Z) dengan input 126 fitur ternormalisasi per tangan (`ml/src/feature_extraction.py` & `ml/src/train.py`). Agar model Keras (`Dense` + `BatchNormalization` + `ReLU`) dapat berjalan 100% lokal di Web dan Android tanpa dependensi C++/WASM TFLite tambahan, bobot `BatchNormalization` perlu dilipat (*folded*) ke layer `Dense` berikutnya dan diekspor ke `frontend/assets/ml/classifier.json`.
3. **Auto-Deploy GitHub ke Cloudflare:** Dibutuhkan konfigurasi yang memungkinkan integrasi Git langsung dari Cloudflare (*Connect GitHub* pada Cloudflare Pages maupun Workers Static Assets) mem-build Flutter Web (`3.38.6`) dan menangani routing SPA `go_router`.

## Keputusan
1. **`DioPlatformHttpClient` (`package:dio ^5.8.0+1`):**
   - Mengimplementasikan `PlatformHttpClient` menggunakan `Dio` di `frontend/lib/platform/http_client_platform.dart` dengan `InterceptorsWrapper` dan timeout 12 detik (tanpa `sendTimeout` pada `BaseOptions` untuk menghindari peringatan `BrowserHttpClientAdapter` pada request `GET` di Web).
   - Kontrak `SupabaseService` tetap menerima `PlatformHttpClient? httpClient` sehingga isolasi pengujian unit dan widget terjaga.
2. **Ekspor Fused MLP & Skema 126 Fitur (`ml/src/export_dart_model.py`):**
   - Melipat parameter `BatchNormalization` ($\gamma, \beta, \mu, \sigma^2$) setelah aktivasi `ReLU` secara matematis eksak ke dalam matriks bobot dan bias layer `Dense` berikutnya.
   - Menyimpan artefak ke `frontend/assets/ml/classifier.json` dan `frontend/assets/ml/model_metadata.json` (selisih probabilitas maksimum terhadap model Keras asli $< 2 \times 10^{-5}$, kesepakatan kelas Top-1 `100%`).
   - Menambahkan `FeatureService.extractMlpFeatures126` (pengurutan tangan kiri-ke-kanan berdasarkan `wrist.x`, normalisasi per tangan ke titik wrist, dan pengisian `0.0` pada slot tangan kedua untuk gestur 1 tangan) serta filter aturan `huruf_1_tangan` vs `huruf_2_tangan` di `ClassifierService`.
3. **Konfigurasi Cloudflare Direct Git Integration:**
   - Menyediakan `scripts/cloudflare-build.sh`, `wrangler.jsonc`, `frontend/web/_redirects`, dan `frontend/web/_headers` agar setiap push ke GitHub dapat langsung di-build dan di-deploy oleh Cloudflare.
