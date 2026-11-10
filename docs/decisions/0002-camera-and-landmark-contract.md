# 0002 — Kontrak Kamera, Resolusi Handedness Kembar, dan Metadata Landmark (v2)

Status: diterima (Minggu 2) · Pemilik: Anggota 1 (bersama Anggota 4, 5, 6)

## Konteks
Setelah audit baseline (`docs/audit/2026-11-07-audit-baseline.md` — temuan H4, H6, H7, H8, F15, F16) dan audit dataset MediaPipe (`ml/reports/audit_dataset_comparison.csv`), ditemukan beberapa kebutuhan teknis yang harus dikunci sebelum implementasi spike kamera Web/Android dan ekstraksi fitur dataset:
1. **Resolusi Handedness Kembar (H6):** MediaPipe Hand Landmarker pada frame kamera nyata terkadang mendeteksi 2 tangan dengan label `handedness` yang sama (`left` + `left` atau `right` + `right`). Pada kontrak v1, `HandLandmarkFrame.fromHands` melempar `LandmarkContractException('Tangan left ganda.')` yang berpotensi menghentikan stream real-time.
2. **Metadata Fitur & World Landmarks (H7):** Dokumentasi resmi MediaPipe menyatakan bahwa `worldLandmarks` menggunakan titik asal $(0, 0, 0)$ pada pusat geometris masing-masing tangan, sehingga jarak relatif antartangan untuk huruf BISINDO 2 tangan harus dihitung dari `landmarks` ternormalisasi yang dikoreksi rasio aspek (`imageWidth`, `imageHeight`).
3. **Surface Preview Kamera (H4):** Siklus hidup kamera dan tracker MediaPipe terikat erat di Web (`HTMLVideoElement`) maupun Android (`Texture`/`PlatformView`), sehingga memisahkan `CameraService` dari `HandTrackingService` akan memaksa pengiriman frame mentah melintasi batas interop pada setiap frame.
4. **Kode Error Terstruktur (H8):** UI `PracticeView` membutuhkan klasifikasi error (`permissionDenied`, `cameraUnavailable`, `insecureContext`, `modelLoadFailed`, `notImplemented`, `unknown`) untuk memberikan instruksi pemulihan yang spesifik.

## Keputusan
1. **Resolusi Spasial untuk Handedness Kembar (`HandLandmarkFrame.fromHands`):**
   - Apabila input berisi 2 tangan dengan `HandSide` berbeda, gunakan sisi yang dilaporkan tracker (`isHandednessInferred = false`).
   - Apabila input berisi 2 tangan dengan `HandSide` yang sama (mis. dua-duanya `left`), jangan melempar exception pada mode default (`resolveDuplicateSides: true`). Urutkan kedua tangan berdasarkan koordinat `x` wrist (`landmarks[0].x`): tangan dengan `x` lebih kecil ditempatkan pada slot `left`, tangan satunya pada slot `right`, dan tandai frame dengan `isHandednessInferred = true`.
   - Mode validasi ketat (`resolveDuplicateSides: false`) tetap tersedia bila diperlukan pada pengujian unit ketat.
2. **Metadata Tambahan pada `TrackedHand` dan `HandLandmarkFrame`:**
   - `TrackedHand` menyimpan `handednessScore` (`double?`, rentang $0.0..1.0$) dan `worldLandmarks` (`List<HandLandmark>?`, opsional 21 titik dalam satuan meter).
   - `HandLandmarkFrame` menyimpan `isHandednessInferred` (`bool`), `imageWidth` (`int?`), `imageHeight` (`int?`), dan `isMirrored` (`bool`, default `false`).
3. **Preview Kamera Terpadu pada `HandTrackingService`:**
   - `HandTrackingService` menyediakan method `Widget buildPreview(BuildContext context)` sehingga widget `PracticeView` dapat merender preview kamera platform secara langsung tanpa menyalin buffer piksel ke Dart.
4. **Error Terstruktur (`HandTrackingErrorCode`):**
   - `HandTrackingException` memuat field `final HandTrackingErrorCode code;` dengan nilai `permissionDenied`, `cameraUnavailable`, `insecureContext`, `modelLoadFailed`, `notImplemented`, dan `unknown`.
5. **Lifecycle Stream & Background (`PracticeController`):**
   - `PracticeController` berlangganan pada `_tracking.start()` segera setelah `_tracking.initialize()` berhasil, menyimpan `latestFrame`, menghitung jumlah tangan terdeteksi, serta menyediakan `pauseForBackground()` dan `resumeFromBackground()` yang dipanggil oleh `AppLifecycleListener`.

## Dampak
- `frontend/lib/core/errors/app_exceptions.dart`
- `frontend/lib/models/hand_landmark_model.dart`
- `frontend/lib/services/hand_tracking_service.dart`
- `frontend/lib/platform/{web,android,hand_tracking_platform_stub}/`
- `frontend/lib/controllers/practice_controller.dart`
- `frontend/lib/views/practice/practice_view.dart`
