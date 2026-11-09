# Audit Baseline Repository Isyaratify — 7 November 2026

- **Tanggal audit:** 7 November 2026 (`2026-11-07T09:24:48+07:00`)
- **Commit yang diaudit:** `cb63340` (`main` — *first commit : Boilerplate*)
- **Mode audit:** Read-only pada saat pengambilan data (status tindak lanjut dicatat pada Tabel 6.1)
- **Lingkungan mesin audit:** Windows 11 25H2 (`10.0.26200.9711`), Flutter `3.38.6` (stable), Dart `3.10.7`, Android SDK `36.1.0`, Chrome `156.0.8078.80`

---

## 1. Konteks Repository & Struktur Awal

### 1.1 Riwayat Commit (`git log --oneline -20`)

```text
cb63340 first commit : Boilerplate
```

### 1.2 Status Git Awal (`git status`)

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

### 1.3 Struktur Folder Aktual

```text
isyaratify/
├── .env.example
├── .gitignore
├── AGENTS.md                           # lokal (diabaikan oleh .gitignore)
├── Technical-Docs.md                   # lokal (diabaikan oleh .gitignore)
├── README.md
├── .github/
│   └── workflows/
│       └── flutter-ci.yml
├── docs/
│   ├── audit/
│   │   └── 2026-11-07-audit-baseline.md
│   └── decisions/
│       └── 0001-frontend-baseline.md
├── frontend/
│   ├── .gitignore
│   ├── .metadata
│   ├── README.md
│   ├── analysis_options.yaml
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   ├── android/
│   │   ├── .gitignore
│   │   ├── build.gradle.kts
│   │   ├── gradle.properties
│   │   ├── settings.gradle.kts
│   │   ├── gradle/wrapper/gradle-wrapper.properties
│   │   └── app/
│   │       ├── build.gradle.kts
│   │       └── src/
│   │           ├── debug/AndroidManifest.xml
│   │           ├── main/AndroidManifest.xml
│   │           ├── main/kotlin/com/isyaratify/app/MainActivity.kt
│   │           ├── main/res/...
│   │           └── profile/AndroidManifest.xml
│   ├── assets/
│   │   ├── hand_landmarker/.gitkeep
│   │   ├── icons/.gitkeep
│   │   ├── images/.gitkeep
│   │   └── ml/.gitkeep
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── controllers/
│   │   │   ├── auth_controller.dart
│   │   │   └── practice_controller.dart
│   │   ├── core/
│   │   │   ├── config/.gitkeep
│   │   │   ├── constants/app_strings.dart
│   │   │   ├── errors/app_exceptions.dart
│   │   │   ├── routing/
│   │   │   │   ├── app_router.dart
│   │   │   │   └── app_routes.dart
│   │   │   └── theme/app_theme.dart
│   │   ├── models/
│   │   │   └── hand_landmark_model.dart
│   │   ├── platform/
│   │   │   ├── hand_tracking_platform.dart
│   │   │   ├── hand_tracking_platform_stub.dart
│   │   │   ├── android/hand_tracking_android.dart
│   │   │   └── web/hand_tracking_web.dart
│   │   ├── services/
│   │   │   └── hand_tracking_service.dart
│   │   ├── views/
│   │   │   ├── auth/login_view.dart
│   │   │   ├── dictionary/dictionary_view.dart
│   │   │   ├── home/dashboard_view.dart
│   │   │   ├── practice/practice_view.dart
│   │   │   ├── profile/.gitkeep
│   │   │   ├── progress/.gitkeep
│   │   │   ├── quest/.gitkeep
│   │   │   └── splash/splash_view.dart
│   │   └── widgets/
│   │       └── placeholder_scaffold.dart
│   ├── test/
│   │   ├── integration/.gitkeep
│   │   ├── unit/
│   │   │   ├── hand_landmark_model_test.dart
│   │   │   └── hand_tracking_contract_test.dart
│   │   └── widget/
│   │       └── app_navigation_test.dart
│   └── web/
│       ├── favicon.png
│       ├── index.html
│       ├── manifest.json
│       └── icons/...
├── ml/
│   ├── artifacts/.gitkeep
│   ├── notebooks/.gitkeep
│   ├── reports/.gitkeep
│   └── src/.gitkeep
└── supabase/
    ├── migrations/.gitkeep
    └── seed/.gitkeep
```

---

## 2. Output Eksekusi Perintah (Saat Audit Commit `cb63340`)

> Catatan sanitasi: path lokal absolut pada mesin uji telah diganti dengan placeholder (`<FLUTTER_SDK>`, `<ANDROID_SDK>`, `<CHROME_PATH>`, `<VS_BUILDTOOLS_PATH>`, `<REPO_ROOT>`), dan preamble resolusi `pub get` yang identik pada perintah Flutter diringkas setelah bagian 2.3.

### 2.1 `flutter --version`

```text
Flutter 3.38.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 8b87286849 (10 months ago) • 2026-01-08 10:49:17 -0800
Engine • hash 6f3039bf7c3cb5306513c75092822d4d94716003 (revision 78fc3012e4) (9 months ago) • 2026-01-07 18:42:12.000Z
Tools • Dart 3.10.7 • DevTools 2.51.1
```

### 2.2 `flutter doctor -v`

```text
[√] Flutter (Channel stable, 3.38.6, on Microsoft Windows [Version 10.0.26200.9711], locale id-ID) [1.179ms]
    • Flutter version 3.38.6 on channel stable at <FLUTTER_SDK>
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision 8b87286849 (10 months ago), 2026-01-08 10:49:17 -0800
    • Engine revision 78fc3012e4
    • Dart version 3.10.7
    • DevTools version 2.51.1
    • Feature flags: enable-web, enable-linux-desktop, enable-macos-desktop, enable-windows-desktop, enable-android, enable-ios, cli-animations, enable-native-assets, omit-legacy-version-file, enable-lldb-debugging

[√] Windows Version (Windows 11 or higher, 25H2, 2009) [2,5s]

[!] Android toolchain - develop for Android devices (Android SDK version 36.1.0) [1.237ms]
    • Android SDK at <ANDROID_SDK>
    • Emulator version 36.3.10.0 (build_id 14472402) (CL:N/A)
    X cmdline-tools component is missing.
      Try installing or updating Android Studio.
      Alternatively, download the tools from https://developer.android.com/studio#command-line-tools-only and make sure to set the ANDROID_HOME environment variable.
      See https://developer.android.com/studio/command-line for more details.
    X Android license status unknown.
      Run `flutter doctor --android-licenses` to accept the SDK licenses.
      See https://flutter.dev/to/windows-android-setup for more details.

[√] Chrome - develop for the web [555ms]
    • Chrome at <CHROME_PATH>

[!] Visual Studio - develop Windows apps (Visual Studio Build Tools 2019 16.11.45) [552ms]
    • Visual Studio at <VS_BUILDTOOLS_PATH>
    • Visual Studio Build Tools 2019 version 16.11.35826.135
    X Visual Studio is missing necessary components. Please re-run the Visual Studio installer for the "Desktop development with C++" workload, and include these components:
        MSVC v142 - VS 2019 C++ x64/x86 build tools
         - If there are multiple build tool versions available, install the latest
        C++ CMake tools for Windows
        Windows 10 SDK

[√] Connected device (3 available) [552ms]
    • Windows (desktop) • windows • windows-x64    • Microsoft Windows [Version 10.0.26200.9711]
    • Chrome (web)      • chrome  • web-javascript • Google Chrome 156.0.8078.80
    • Edge (web)        • edge    • web-javascript • Microsoft Edge 157.0.4341.42

[√] Network resources [696ms]
    • All expected network resources are available.

! Doctor found issues in 2 categories.
```

### 2.3 `flutter pub get` (di `frontend/`)

Exit code: `0`

```text
Resolving dependencies...
Downloading packages...
  characters 1.4.0 (1.4.1 available)
  clock 1.1.2 (1.1.3 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  go_router 17.5.0 (18.1.3 available)
  matcher 0.12.17 (0.12.20 available)
  material_color_utilities 0.11.1 (0.13.1 available)
  meta 1.17.0 (1.19.0 available)
  stack_trace 1.12.1 (1.12.2 available)
  test_api 0.7.7 (0.7.15 available)
  vector_math 2.2.0 (2.4.4 available)
Got dependencies!
10 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

### 2.4 `dart format --output=none --set-exit-if-changed lib test` (di `frontend/`)

Exit code: `1` (GAGAL pada commit `cb63340`)

```text
Changed lib\app.dart
Formatted 24 files (1 changed) in 0.23 seconds.
```

- **Penyebab:** `frontend/lib/app.dart` memiliki satu baris kosong berlebih di akhir file (baris 48 setelah penutup `}` pada baris 47).
- **Langkah reproduksi:**
  ```powershell
  cd frontend
  dart format --output=none --set-exit-if-changed lib test
  ```

### 2.5 `flutter analyze` (di `frontend/`)

Exit code: `0` *(output `pub get` awal sama seperti §2.3)*

```text
Analyzing frontend...                                           
No issues found! (ran in 54.0s)
```

### 2.6 `flutter test` (di `frontend/`)

Exit code: `0` *(output `pub get` awal sama seperti §2.3)*

```text
00:00 +0: loading <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart
00:00 +0: <REPO_ROOT>/frontend/test/unit/hand_tracking_contract_test.dart: stub platform mengikuti kontrak dan melaporkan belum diimplementasikan
00:00 +1: <REPO_ROOT>/frontend/test/unit/hand_tracking_contract_test.dart: PracticeController: status ready bila initialize berhasil
00:00 +2: <REPO_ROOT>/frontend/test/unit/hand_tracking_contract_test.dart: PracticeController: unavailable + pesan bila initialize gagal
00:00 +3: <REPO_ROOT>/frontend/test/unit/hand_tracking_contract_test.dart: PracticeController.dispose menghentikan dan melepas service
00:03 +4: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: TrackedHand menerima tepat 21 landmark
00:03 +5: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: TrackedHand menolak jumlah landmark selain 21
00:03 +6: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: TrackedHand list landmark tidak dapat dimodifikasi
00:03 +7: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: HandLandmarkFrame frame kosong: tanpa tangan
00:03 +8: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: HandLandmarkFrame satu tangan: presence sesuai sisi
00:03 +9: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: HandLandmarkFrame urutan kanonik left lalu right walau input terbalik
00:03 +10: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: HandLandmarkFrame menolak lebih dari dua tangan
00:03 +11: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: HandLandmarkFrame menolak sisi ganda
00:03 +12: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: HandLandmarkFrame konstruktor menolak tangan di slot yang salah
00:03 +13: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: HandLandmarkFrame koordinat mentah 126 nilai, urutan left lalu right, missing = 0
00:03 +14: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: JSON round-trip
00:03 +15: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: JSON menolak handedness tidak dikenal
00:03 +16: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: JSON menolak nilai non-numerik / NaN
00:03 +17: <REPO_ROOT>/frontend/test/unit/hand_landmark_model_test.dart: JSON menolak timestamp dan hands yang tidak valid
00:03 +18: <REPO_ROOT>/frontend/test/widget/app_navigation_test.dart: splash -> login -> dashboard -> kamus & practice -> keluar
00:07 +19: All tests passed!
```

### 2.7 `flutter build web` (di `frontend/`)

Exit code: `0` *(output `pub get` awal sama seperti §2.3)*

```text
Compiling lib\main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Compiling lib\main.dart for the Web...                            104,9s
√ Built build\web
```

### 2.8 `flutter build apk --debug` (di `frontend/`)

Exit code: `0` *(output `pub get` awal sama seperti §2.3)*

```text
Running Gradle task 'assembleDebug'...                            234,4s
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

---

## 3. Verifikasi Hipotesis (H1–H14)

### H1 — CI run #1 gagal karena format `lib/app.dart`; analyze dan test belum pernah jalan di CI
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `.github/workflows/flutter-ci.yml:26-29`: urutan step job `analyze-and-test` pada commit `cb63340` adalah `flutter pub get` (baris 26), `dart format --output=none --set-exit-if-changed lib test` (baris 27), `flutter analyze` (baris 28), dan `flutter test` (baris 29).
  - `frontend/lib/app.dart:47-48`: memiliki baris kosong ekstra di akhir file sehingga `dart format --output=none --set-exit-if-changed lib test` keluar dengan kode `1` (`Changed lib\app.dart`).
  - API GitHub Actions (`https://api.github.com/repos/yzffm/isyaratify/actions/runs/41697754732/jobs`, run `#1` untuk commit `cb63340`): step #5 (`Run dart format --output=none --set-exit-if-changed lib test`) berstatus `conclusion: "failure"`, sedangkan step #6 (`Run flutter analyze`) dan step #7 (`Run flutter test`) berstatus `conclusion: "skipped"`.

### H2 — `AndroidManifest.xml` utama tidak memiliki izin `INTERNET` dan `CAMERA` (`INTERNET` hanya di manifest debug/profile)
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/android/app/src/main/AndroidManifest.xml:1-45` (pada `cb63340`): tidak memiliki deklarasi `<uses-permission>` apa pun (baik `android.permission.INTERNET` maupun `android.permission.CAMERA`) dan tidak memiliki `<uses-feature android:name="android.hardware.camera" .../>`.
  - `frontend/android/app/src/debug/AndroidManifest.xml:6`: mendeklarasikan `<uses-permission android:name="android.permission.INTERNET"/>`.
  - `frontend/android/app/src/profile/AndroidManifest.xml:6`: mendeklarasikan `<uses-permission android:name="android.permission.INTERNET"/>`.
  - Akibatnya, APK `release` tidak memiliki akses jaringan ke Supabase, dan seluruh mode build Android (`debug`/`profile`/`release`) tidak memiliki izin kamera.

### H3 — Pada `flutter test` (VM) `createPlatformHandTrackingService()` memilih implementasi Android (`dart.library.io` true), bukan stub; test navigasi bergantung pada implementasi platform
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/lib/platform/hand_tracking_platform.dart:4-6`:
    ```dart
    export 'hand_tracking_platform_stub.dart'
        if (dart.library.js_interop) 'web/hand_tracking_web.dart'
        if (dart.library.io) 'android/hand_tracking_android.dart';
    ```
    Pada runner `flutter test` (Dart VM host desktop), `dart.library.io` bernilai `true`, sehingga `createPlatformHandTrackingService()` mengembalikan `AndroidHandTrackingService` (`frontend/lib/platform/android/hand_tracking_android.dart:24-25`), **bukan** `UnsupportedHandTrackingService` (`frontend/lib/platform/hand_tracking_platform_stub.dart:23-24`).
  - Pada commit `cb63340`, `frontend/lib/core/routing/app_router.dart:45-47` membangun `const PracticeView()` tanpa menyuntikkan service factory, dan `frontend/test/widget/app_navigation_test.dart:25-27` serta `frontend/test/unit/hand_tracking_contract_test.dart:34-47` bergantung langsung pada `createPlatformHandTrackingService()`.

### H4 — `HandTrackingService` tidak menyediakan surface preview kamera (Web butuh `<video>`/`HtmlElementView`, Android butuh `PlatformView`/texture)
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/lib/services/hand_tracking_service.dart:6-19`: kontrak `HandTrackingService` hanya mendeklarasikan `initialize()`, `start()`, `stop()`, dan `dispose()`. Tidak ada cara bagi layer View untuk merender preview kamera (mis. `Widget buildPreview(BuildContext context)`).
  - `frontend/lib/views/practice/practice_view.dart:56-60`: masih berupa teks statis tanpa slot widget preview kamera.

### H5 — `PracticeController.initialize` hanya menangkap `HandTrackingException` (error lain membuat status macet di `initializing`); `dispose()` memakai `stop().then(dispose)` sehingga `dispose` tidak jalan bila `stop()` gagal
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/lib/controllers/practice_controller.dart:24-33` (pada `cb63340`): blok `try` hanya menangkap `on HandTrackingException catch (e)`. Jika `_tracking.initialize()` melempar exception selain `HandTrackingException`, `_status` tertinggal di `PracticeStatus.initializing` selamanya.
  - `frontend/lib/controllers/practice_controller.dart:42-48` (pada `cb63340`): memanggil `_tracking.stop().then((_) => _tracking.dispose());`. Jika Future `_tracking.stop()` gagal (reject/throw), callback `.then(...)` dilewati sehingga `_tracking.dispose()` tidak pernah dijalankan dan menimbulkan unhandled async error.

### H6 — `HandLandmarkFrame.fromHands` melempar exception bila dua tangan bersisi sama; nilai dampaknya pada stream real-time
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/lib/models/hand_landmark_model.dart:124-139`:
    - Baris 129–131: `if (left != null) { throw const LandmarkContractException('Tangan left ganda.'); }`
    - Baris 134–136: `if (right != null) { throw const LandmarkContractException('Tangan right ganda.'); }`
  - `frontend/test/unit/hand_landmark_model_test.dart:88-96`: secara eksplisit menguji bahwa dua tangan `HandSide.left` melempar `LandmarkContractException`.
  - **Penilaian dampak pada stream real-time:**
    MediaPipe Hand Landmarker mengklasifikasikan handedness (`Left`/`Right`) secara independen untuk setiap bbox tangan yang terdeteksi. Pada huruf BISINDO dua tangan (ketika kedua tangan berdekatan, bersentuhan, atau sebagian saling menutupi), MediaPipe dapat mengeluarkan dua deteksi dengan label sisi yang sama pada satu frame (sebagai ilustrasi hipotesis, bukan hasil pengukuran: keduanya berlabel `Left` dengan skor `0.92` dan `0.58`). Bila adapter platform langsung memanggil `HandLandmarkFrame.fromHands` pada setiap frame kamera tanpa resolusi konflik atau pengurutan spasial, maka satu frame dengan label kembar akan melempar `LandmarkContractException` ke dalam stream real-time dan berpotensi memutus langganan stream atau membuat UI error.

### H7 — Kontrak belum membawa skor handedness, world landmarks, flag mirror, dan ukuran gambar
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/lib/models/hand_landmark_model.dart:34-61` (`HandLandmark`), `65-97` (`TrackedHand`), dan `103-200` (`HandLandmarkFrame`):
    - `TrackedHand` (baris 90–91) hanya memiliki `side` dan `landmarks`; tidak memiliki `handednessScore` (`double`) maupun `worldLandmarks` (`List<HandLandmark>?`).
    - `HandLandmarkFrame` (baris 162–164) hanya memiliki `timestamp`, `left`, dan `right`; tidak memiliki `isMirrored` (`bool`), `imageWidth` (`int`), maupun `imageHeight` (`int`).
  - Dampaknya: `FeatureService` nantinya tidak dapat melakukan koreksi rasio aspek frame (`Technical-Docs.md:370`), tidak mengetahui apakah koordinat `x` dan handedness sudah dicerminkan oleh kamera depan, dan tidak memiliki `worldLandmarks` 3D metrik.

### H8 — `HandTrackingException` tidak memiliki kode error terstruktur (permission ditolak, tidak ada kamera, konteks tidak aman, model gagal dimuat)
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/lib/core/errors/app_exceptions.dart:12-23`: `HandTrackingException` hanya memiliki satu field `final String message;` serta konstruktor `const HandTrackingException(this.message)` dan `const HandTrackingException.notImplemented(String platform)`.
  - Tidak ada enum/kode error terstruktur (seperti `permissionDenied`, `cameraUnavailable`, `insecureContext`, `modelLoadFailed`, `notImplemented`, `unknown`), sehingga `PracticeController` dan `PracticeView` belum dapat membedakan aksi pemulihan bagi pengguna sesuai `AGENTS.md:431-432` dan `Technical-Docs.md:625-635`.

### H9 — `AuthController` hanya boolean; `Splash` memakai `Timer` tetap; `redirect` tidak menyimpan tujuan awal; `signInPlaceholder` bisa ikut ke build release
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `AuthController` hanya boolean: `frontend/lib/controllers/auth_controller.dart:7-24` hanya memiliki `bool _isAuthenticated = false;`.
  - `SplashView` memakai `Timer` tetap: `frontend/lib/views/splash/splash_view.dart:22-24` menjalankan `Timer(const Duration(milliseconds: 1200), () { if (mounted) context.go(AppRoutes.login); });`.
  - `redirect` tidak menyimpan tujuan awal: `frontend/lib/core/routing/app_router.dart:16-26` mengembalikan `AppRoutes.login` ketika `!auth.isAuthenticated && !isPublic` tanpa menyertakan query lokasi asal, dan saat login selesai hanya mengarahkan ke `AppRoutes.home`.
  - `signInPlaceholder` bisa ikut ke build release: `frontend/lib/controllers/auth_controller.dart:13-17` dan tombol `'Lanjut (placeholder)'` di `frontend/lib/views/auth/login_view.dart:34-37` tidak dibatasi dengan `kDebugMode`.

### H10 — `.env.example` tidak punya mekanisme pembacaan di Flutter (kandidat: `--dart-define-from-file`)
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `.env.example:1-5` mendefinisikan `SUPABASE_URL=` dan `SUPABASE_PUBLISHABLE_KEY=`, serta `README.md:34` menginstruksikan menyalin `.env.example` ke `.env`.
  - Namun `frontend/lib/core/config/` masih kosong (`frontend/lib/core/config/.gitkeep`), `frontend/pubspec.yaml:30-39` tidak memiliki package pembaca `.env`, dan tidak ada kode `String.fromEnvironment('SUPABASE_URL')` / `String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY')` di `frontend/lib/`.

### H11 — Signing release masih memakai debug key
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/android/app/build.gradle.kts:33-39`:
    ```kotlin
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    ```

### H12 — `pubspec.yaml` tanpa bagian `assets:`; `cupertino_icons` tidak dipakai
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  - `frontend/pubspec.yaml:55-66`: bagian `assets:` masih dikomentari (`# assets:`), padahal direktori `frontend/assets/{hand_landmarker,icons,images,ml}/` sudah disiapkan.
  - `frontend/pubspec.yaml:36`: `cupertino_icons: ^1.0.8` terdaftar sebagai direct dependency, tetapi tidak ada satu pun file di `frontend/lib/` atau `frontend/test/` yang menggunakannya.

### H13 — `minSdk`, AGP, Gradle, dan Kotlin kompatibel dengan MediaPipe Tasks Vision Android
- **Status:** **TERKONFIRMASI**
- **Bukti di repository & toolchain:**
  - `frontend/android/app/build.gradle.kts:10-28` (pada `cb63340`): menggunakan `compileSdk = flutter.compileSdkVersion`, `ndkVersion = flutter.ndkVersion`, `minSdk = flutter.minSdkVersion`, `targetSdk = flutter.targetSdkVersion`, dan Java/Kotlin `VERSION_17`.
  - `<FLUTTER_SDK>/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt:22-40` (Flutter 3.38.6): menetapkan default `minSdkVersion = 24`, `compileSdkVersion = 36`, `targetSdkVersion = 36`, dan `ndkVersion = "28.2.13676358"`.
  - `frontend/android/settings.gradle.kts:22-23`: menggunakan AGP (`com.android.application`) `8.11.1` dan Kotlin (`org.jetbrains.kotlin.android`) `2.2.20`.
  - `frontend/android/gradle/wrapper/gradle-wrapper.properties:5`: menggunakan Gradle `8.14` (`gradle-8.14-all.zip`).
- **Verifikasi terhadap dokumentasi resmi:**
  1. **MediaPipe Tasks Vision Android (`com.google.mediapipe:tasks-vision`):**
     - Berdasarkan dokumentasi resmi Google AI Edge MediaPipe (*Setup Guide for Android*: https://ai.google.dev/edge/mediapipe/solutions/setup_android dan *Hand Landmarker for Android*: https://ai.google.dev/edge/mediapipe/solutions/vision/hand_landmarker/android), syarat perangkat lunak minimum adalah **Android SDK API level 24 (`minSdk = 24`, Android 7.0 Nougat)** atau lebih tinggi.
  2. **Android Gradle Plugin, Gradle, dan Kotlin:**
     - Berdasarkan dokumentasi resmi Android Developers (*Android Gradle plugin 8.11 release notes*: https://developer.android.com/build/releases/gradle-plugin), AGP `8.11.x` mensyaratkan **minimum Gradle 8.13** dan JDK 17. Proyek ini memakai **Gradle 8.14** dan **JDK 17**, sehingga memenuhi syarat.
     - Berdasarkan dokumentasi resmi Kotlin (*Configure a Gradle project*: https://kotlinlang.org/docs/gradle-configure-project.html), Kotlin `2.2.x` kompatibel dengan AGP `8.x` dan Gradle `8.x`, dan terbukti berhasil dikompilasi melalui `flutter build apk --debug`.

### H14 — `Technical-Docs` §6.6 tidak sama dengan `models/hand_landmark_model.dart`; tabel §16.1 rusak; ada typo di judul `AGENTS.md`
- **Status:** **TERKONFIRMASI**
- **Bukti:**
  1. **Ketidaksesuaian `Technical-Docs.md` §6.6 vs `frontend/lib/models/hand_landmark_model.dart`:**
     - `Technical-Docs.md:406-413` mendefinisikan `TrackedHand` dengan `final String handedness;`, sedangkan `frontend/lib/models/hand_landmark_model.dart:65-91` menggunakan `final HandSide side;` (enum `HandSide.left` / `HandSide.right`).
     - `Technical-Docs.md:415-422` mendefinisikan `HandLandmarkFrame` dengan field `final List<TrackedHand> hands;` pada konstruktor utama, sedangkan `frontend/lib/models/hand_landmark_model.dart:103-175` menggunakan field `final TrackedHand? left;` dan `final TrackedHand? right;`, factory `HandLandmarkFrame.fromHands(...)`, getter `hands`, `presence`, dan `toRawCoordinates()`.
     - `Technical-Docs.md:424-435` mencantumkan `class GesturePrediction`, yang belum dibuat di `frontend/lib/models/`.
  2. **Tabel `Technical-Docs.md` §16.1 rusak:**
     - `Technical-Docs.md:1121-1129`: tabel di bawah `## 16.1 Kolaborasi lintas peran` tidak memiliki baris pemisah header (`|---|---|---|`), sehingga tidak dirender sebagai tabel Markdown yang valid. Selain itu terdapat typo `"Colaborator Pendukung"` dan duplikasi judul sub-bab `## 16.1 Kolaborasi lintas peran` (baris 1119) dengan `## 16.2 Kolaborasi lintas peran` (baris 1130).
  3. **Typo di bagian judul/pembuka `AGENTS.md`:**
     - `AGENTS.md:3`: tertulis `Isyaratity` (seharusnya `Isyaratify`).
     - Selain itu pada `Technical-Docs.md:9`, tautan `[AGENTS.md]` ditulis tanpa target link (`[`AGENTS.md`]`).

---

## 4. Temuan Lain di Luar Daftar Hipotesis (F15–F21)

- **F15 — `PracticeController` belum memanggil `_tracking.start()` dan belum mengelola `StreamSubscription<HandLandmarkFrame>`:**
  - **Bukti:** `frontend/lib/controllers/practice_controller.dart:24-48`. Method `initialize()` hanya memanggil `_tracking.initialize()` tanpa berlangganan ke `_tracking.start()`, belum menyimpan frame terakhir/status deteksi tangan, dan belum memiliki penanganan error stream (`onError`) maupun `subscription.cancel()` pada `dispose()`.
- **F16 — Tidak ada pengelolaan lifecycle aplikasi (`AppLifecycleState`) saat kamera aktif:**
  - **Bukti:** `frontend/lib/views/practice/practice_view.dart:1-64` dan `frontend/lib/controllers/practice_controller.dart:1-49`. Ketika aplikasi Android dipindah ke background atau tab browser tidak aktif saat pengguna berada di layar Practice, widget tidak di-dispose sehingga kamera/tracker akan tetap menyala di background apabila tidak dihentikan pada `AppLifecycleState.inactive` / `paused`.
- **F17 — `AppRouter` tidak memiliki route `/` (root), dan `AppRoutes.splash` di `publicRoutes` dapat menyebabkan lompatan navigasi *(analisis kode statis — belum diuji di browser)*:**
  - **Bukti:** `frontend/lib/core/routing/app_routes.dart:2-11` dan `frontend/lib/core/routing/app_router.dart:13-49`. Daftar `routes` hanya mendefinisikan `/splash`, `/login`, `/home`, `/dictionary`, dan `/practice` tanpa `/`. Selain itu, secara analisis statis, jika pengguna yang sudah login mengunjungi `/splash`, `redirect` mengizinkannya (karena `splash` ada di `publicRoutes`), lalu `SplashView` (`frontend/lib/views/splash/splash_view.dart:22-24`) menunggu 1,2 detik untuk memanggil `context.go(AppRoutes.login)` yang baru kemudian dibelokkan oleh `redirect` ke `/home`. Perilaku ini belum diuji secara langsung di browser.
- **F18 — Navigasi kembali pada deep link Web & ketiadaan tombol keluar/stop kamera eksplisit di `PracticeView`:**
  - **Bukti:** `frontend/lib/views/home/dashboard_view.dart:24,30` memakai `context.push(...)`. Jika pengguna membuka `/practice` atau `/dictionary` secara langsung lewat URL browser (deep link), stack router tidak memiliki halaman sebelumnya (`canPop() == false`), sehingga `AppBar` tidak menampilkan tombol kembali. Selain itu `PracticeView` (`frontend/lib/views/practice/practice_view.dart:45-62`) belum menyediakan tombol stop/keluar kamera yang mudah ditemukan sebagaimana disyaratkan `AGENTS.md:434`.
- **F19 — Metadata Web (`index.html`, `manifest.json`) dan Android (`AndroidManifest.xml`) masih menggunakan nilai template bawaan:**
  - **Bukti:**
    - `frontend/web/manifest.json:2-3,6-7,9`: `"name": "isyaratify"` (huruf kecil), `"theme_color": "#0175C2"` (biru bawaan Flutter, berbeda dari `#2E6BE6` di `frontend/lib/core/theme/app_theme.dart:5`), dan `"orientation": "portrait-primary"` (kurang tepat untuk Web desktop).
    - `frontend/web/index.html:26,32`: judul halaman `<title>isyaratify</title>` masih huruf kecil.
    - `frontend/android/app/src/main/AndroidManifest.xml:3` (pada `cb63340`): `android:label="isyaratify"` masih huruf kecil.
- **F20 — Catatan di `docs/decisions/0001-frontend-baseline.md` tentang `flutter build apk` sudah tidak akurat:**
  - **Bukti:** `docs/decisions/0001-frontend-baseline.md:21,26` (pada `cb63340`) menyatakan `flutter build apk` belum dapat dijalankan karena `cmdline-tools` hilang. Faktanya, `flutter build apk --debug` berhasil menghasilkan APK (`build\app\outputs\flutter-apk\app-debug.apk`), meskipun `cmdline-tools` tetap diperlukan untuk `flutter doctor --android-licenses` dan manajemen paket SDK.
- **F21 — Banyak berkas pada struktur target `AGENTS.md` §4 masih berupa `.gitkeep` atau belum dibuat:**
  - **Bukti:**
    - Belum ada: `frontend/web/hand_tracking_web.js`, `ml/README.md`, `ml/requirements.txt`, `supabase/README.md`, `docs/api-contract.md`, `docs/ml-model-card.md`, `docs/test-plan.md`, `.github/workflows/web-deploy.yml`.
    - Masih berupa `.gitkeep`: `frontend/assets/{images,icons,hand_landmarker,ml}/`, `frontend/lib/core/config/`, `frontend/lib/views/{quest,progress,profile}/`, `frontend/test/integration/`, `ml/{artifacts,notebooks,reports,src}/`, `supabase/{migrations,seed}/`.

---

## 5. Pemeriksaan Kepatuhan terhadap `AGENTS.md`

| Bagian `AGENTS.md` | Status Kepatuhan | Catatan & Bukti |
|---|---|---|
| **§3.2 Non-goals MVP** | **PATUH** | Tidak ada klaim penerjemah kalimat/percakapan BISINDO, gerakan dinamis, chat/multiplayer, AR/3D, upload frame kamera ke server, microservices, penyimpanan foto/video, ataupun target iOS. `frontend/lib/core/constants/app_strings.dart:1-2` dan `README.md:5` menegaskan batasan alfabet statis. |
| **§4 Struktur folder** | **SEBAGIAN PATUH (Baseline M1)** | Pemisahan `main.dart` dan `app.dart`, layer `models/`, `views/`, `controllers/`, `services/`, `platform/{web,android}/`, dan `test/{unit,widget,integration}/` sudah mengikuti standar. File fitur Minggu 2–6 serta dokumen di `docs/`, `ml/`, dan `supabase/` masih placeholder/belum dibuat (lihat F21). |
| **§5 Aturan real-time** | **SEBAGIAN PATUH (Kontrak Awal)** | Tidak ada pengiriman frame ke jaringan (§5.1). Kontrak `HandTrackingService` (§5.2) dan `HandLandmarkFrame` 126 koordinat + 2 presence dengan urutan kanonik `left` lalu `right` (§5.3) sudah ada dan bebas `dart:io` di kode bersama. Namun belum ada surface preview kamera (H4), resolusi sisi tangan ganda di stream (H6), metadata frame/handedness score (H7), serta `FeatureService`, throttling/backpressure (§5.5), dan smoothing (§5.6). |
| **§10 Standar coding** | **SEBAGIAN BESAR PATUH** | Null safety aktif, tidak ada `dynamic` tanpa validasi, tidak ada secret/token/`.env` ter-commit, tidak ada Docker lokal, tidak ada `dart:io` lintas platform, `flutter analyze` lulus (`0` isu), dan `flutter test` lulus. Pelanggaran format pada `frontend/lib/app.dart` (H1) diperbaiki pada branch `fix/baseline-hardening`. |

---

## 6. Tabel Ringkasan Temuan, Prioritas Minggu 1–2, dan Pertanyaan Terbuka

### 6.1 Tabel Temuan Audit

| ID | Severity | Area | Bukti (`file:baris`) | Rekomendasi | Usaha | Status Perbaikan |
|---|---|---|---|---|---|---|
| **H1** | **Blocker** | CI / Formatting | `frontend/lib/app.dart:47-48`, `.github/workflows/flutter-ci.yml:27-29`, GitHub Actions run `#41697754732` | Jalankan `dart format lib test` dan perbarui workflow CI (Node 24 actions, pin `ubuntu-24.04`, tambah job `build-web` & `build-android-debug`). | **S** | **Selesai di PR `fix/baseline-hardening` (Commit 2 & 4)** |
| **H2** | **Blocker** | Android Manifest & Permissions | `frontend/android/app/src/main/AndroidManifest.xml:1-45`, `src/debug/AndroidManifest.xml:6`, `src/profile/AndroidManifest.xml:6` | Tambahkan `<uses-permission android:name="android.permission.INTERNET"/>`, `<uses-permission android:name="android.permission.CAMERA"/>`, dan `<uses-feature android:name="android.hardware.camera" android:required="false"/>` di `src/main/AndroidManifest.xml`. | **S** | **Selesai di PR `fix/baseline-hardening` (Commit 3)** |
| **H4** | **Blocker** | Camera & HandTracking Contract | `frontend/lib/services/hand_tracking_service.dart:6-19`, `frontend/lib/views/practice/practice_view.dart:56-60` | Perluas kontrak `HandTrackingService` untuk menyediakan preview kamera pada Web dan Android. | **M** | **Diusulkan — dibahas di ADR 0002 (Prompt 2-R)** |
| **H3** | **High** | Platform Conditional Import & Test | `frontend/lib/platform/hand_tracking_platform.dart:4-6`, `frontend/lib/views/practice/practice_view.dart:19-22`, `frontend/test/widget/app_navigation_test.dart:25-27`, `frontend/test/unit/hand_tracking_contract_test.dart:34` | Injeksi factory `HandTrackingService` melalui `IsyaratifyApp` → `AppRouter.create` → `PracticeView` dan gunakan fake eksplisit pada unit & widget test. | **S** | **Selesai di PR `fix/baseline-hardening` (Commit 5)** |
| **H5** | **High** | Practice Lifecycle & Error Handling | `frontend/lib/controllers/practice_controller.dart:24-33,42-48` | Tangkap semua exception di `initialize()` (log dengan `debugPrint`), cegah eksekusi ganda/saat `ready`, pastikan `_tracking.dispose()` selalu terpanggil walau `stop()` gagal, dan lepas ulang bila `initialize()` selesai setelah `dispose()`. | **S** | **Selesai di PR `fix/baseline-hardening` (Commit 6)** |
| **H6** | **High** | Real-Time Landmark Stream | `frontend/lib/models/hand_landmark_model.dart:124-139`, `frontend/test/unit/hand_landmark_model_test.dart:88-96` | Tangani kasus dua deteksi tangan dengan label sisi sama agar tidak memutus stream real-time. | **M** | **Diusulkan — dibahas di ADR 0002 (Prompt 2-R)** |
| **H7** | **High** | Landmark Data Contract | `frontend/lib/models/hand_landmark_model.dart:34-97,103-200`, `Technical-Docs.md:368-379` | Tambahkan metadata yang diperlukan (`handednessScore`, `worldLandmarks`, `isMirrored`, `imageWidth`, `imageHeight`) sebelum ekstraksi dataset Minggu 2. | **M** | **Diusulkan — dibahas di ADR 0002 (Prompt 2-R)** |
| **H8** | **High** | Structured Error Handling | `frontend/lib/core/errors/app_exceptions.dart:12-23`, `frontend/lib/views/practice/practice_view.dart:34-44` | Tambahkan kode error terstruktur pada `HandTrackingException` dan tampilkan panduan spesifik di UI. | **S** | **Dijadwalkan pada Prompt 2-R / Spike Kamera M1** |
| **H9** | **High** | Auth & Routing Security | `frontend/lib/controllers/auth_controller.dart:7-24`, `frontend/lib/views/auth/login_view.dart:34-37`, `frontend/lib/views/splash/splash_view.dart:22-24`, `frontend/lib/core/routing/app_router.dart:16-26` | Batasi `signInPlaceholder` dengan `kDebugMode` (atau hapus saat Supabase Auth masuk), simpan lokasi tujuan awal pada `redirect`, dan hubungkan `SplashView` dengan pengecekan sesi. | **M** | **Dijadwalkan pada Task Auth & Routing M2** |
| **F15** | **High** | Practice Stream Subscription | `frontend/lib/controllers/practice_controller.dart:24-48` | Kelola `StreamSubscription<HandLandmarkFrame>` di `PracticeController` (mulai `start()` setelah `initialize()`, tangani event & error stream, dan `cancel()` saat `stop()`/`dispose()`). | **M** | **Dijadwalkan pada Spike Kamera & MediaPipe M1/M2** |
| **F16** | **High** | App Lifecycle Camera Release | `frontend/lib/views/practice/practice_view.dart:1-64`, `frontend/lib/controllers/practice_controller.dart:1-49` | Gunakan `AppLifecycleListener` / `WidgetsBindingObserver` untuk menghentikan sementara kamera & tracker saat aplikasi pindah ke background/tab tidak aktif. | **M** | **Dijadwalkan pada Spike Kamera & MediaPipe M1/M2** |
| **H10** | **Medium** | Konfigurasi Environment | `.env.example:1-5`, `README.md:32-35`, `frontend/lib/core/config/.gitkeep` | Buat `AppConfig` di `lib/core/config/` menggunakan `String.fromEnvironment` dan dokumentasikan `--dart-define-from-file=../.env` di `README.md`. | **S** | **Dijadwalkan pada Task Setup Supabase M2** |
| **H11** | **Medium** | Android Release Signing | `frontend/android/app/build.gradle.kts:33-39`, `frontend/android/.gitignore:12-14` | Siapkan pembacaan `key.properties` untuk signing release (dengan fallback ke debug hanya jika `key.properties` tidak ada pada pengembangan lokal) sebelum rilis APK Minggu 6. | **S** | **Dijadwalkan sebelum Rilis APK M6** |
| **H12** | **Medium** | Konfigurasi `pubspec.yaml` | `frontend/pubspec.yaml:36,55-66` | Daftarkan folder asset yang digunakan pada `flutter: assets:` ketika file model/ilustrasi ditambahkan, dan hapus `cupertino_icons` jika tidak diperlukan. | **S** | **Dijadwalkan pada M2 (saat asset kamus/model masuk)** |
| **H13** | **Low** | Konfigurasi Gradle / MediaPipe | `frontend/android/app/build.gradle.kts:27`, `frontend/android/settings.gradle.kts:22-23`, `gradle-wrapper.properties:5` | Tuliskan `minSdk = 24` secara eksplisit di `app/build.gradle.kts` dengan rujukan dokumentasi resmi MediaPipe Tasks Vision Android. | **S** | **Selesai di PR `fix/baseline-hardening` (Commit 3)** |
| **F17** | **Medium** | Definisi Route Root & Splash | `frontend/lib/core/routing/app_router.dart:13-49`, `frontend/lib/core/routing/app_routes.dart:2-11` | Tambahkan route `/` dan cegah pengguna yang sudah terautentikasi tertahan di `/splash` (perlu diuji di browser). | **S** | **Dijadwalkan pada Task Auth & Routing M2** |
| **F18** | **Medium** | UX/Aksesibilitas Practice & Deep Link | `frontend/lib/views/practice/practice_view.dart:45-62`, `frontend/lib/views/home/dashboard_view.dart:24,30` | Tambahkan tombol eksplisit "Hentikan Kamera / Kembali ke Dashboard" di `PracticeView` serta label semantik status. | **S** | **Dijadwalkan pada Task Practice UI M2/M4** |
| **H14** | **Low** | Sinkronisasi Dokumentasi Lokal | `Technical-Docs.md:9,394-436,1119-1131`, `AGENTS.md:3` | Perbarui contoh kode §6.6 agar sesuai `hand_landmark_model.dart`, perbaiki header tabel Markdown §16.1 dan penomoran sub-bab, serta perbaiki typo `Isyaratity` di `AGENTS.md:3`. | **S** | **Menunggu pembaruan dokumen lokal (tidak di-commit ke git)** |
| **F19** | **Low** | Branding Manifest Web & Android | `frontend/web/manifest.json:2-9`, `frontend/web/index.html:26,32`, `frontend/android/app/src/main/AndroidManifest.xml:3` | Ubah label `"isyaratify"` menjadi `"Isyaratify"` di AndroidManifest; sesuaikan `manifest.json` & `index.html` Web pada task UI Web berikutnya. | **S** | **Sebagian selesai di PR `fix/baseline-hardening` (Commit 3: `android:label`); Web menyusul di M2** |
| **F20** | **Low** | Catatan Keputusan ADR 0001 | `docs/decisions/0001-frontend-baseline.md:21,26` | Perbarui catatan di ADR 0001 bahwa `flutter build web` dan `flutter build apk --debug` telah terverifikasi pada 7 Nov 2026. | **S** | **Selesai di PR `fix/baseline-hardening` (Commit 7)** |
| **F21** | **Low** | Kelengkapan Dokumen & Skeleton | `ml/`, `supabase/`, `docs/`, `.github/workflows/` | Buat `ml/README.md`, `supabase/README.md`, dan dokumen kontrak di `docs/` sesuai jadwal milestone. | **M** | **Sedang berjalan (PR #1 untuk audit dataset ML; sisanya M1–M6)** |

---

### 6.2 Urutan Perbaikan yang Disarankan untuk Minggu 1–2

1. **Tahap 1 — Pulihkan CI & Hygiene Dasar (Dikerjakan di PR `fix/baseline-hardening`):**
   - Tambahkan `.gitattributes` untuk menegakkan `LF` di seluruh platform (**Commit 1**).
   - Format `frontend/lib/app.dart` (**H1 — Commit 2**) dan perbarui `.github/workflows/flutter-ci.yml` ke Node 24 actions + `ubuntu-24.04` + job `build-web` & `build-android-debug` (**Commit 4**).
   - Tambahkan izin `INTERNET` dan `CAMERA`, label `Isyaratify`, serta `minSdk = 24` eksplisit di Android (**H2, H13, F19 — Commit 3**).
   - Pisahkan ketergantungan `createPlatformHandTrackingService()` pada widget/unit test melalui injeksi factory (**H3 — Commit 5**) dan perkuat error/dispose handling di `PracticeController` (**H5 — Commit 6**).
   - Perbarui `docs/decisions/0001-frontend-baseline.md` (**F20 — Commit 7**).

2. **Tahap 2 — Revisi Kontrak & Spike Kamera + MediaPipe Lintas Platform (ADR 0002 / Prompt 2-R — Gate M1):**
   - Bahas dan tetapkan ADR 0002 untuk kontrak `HandLandmarkFrame` & `TrackedHand` (**H6, H7**), kontrak preview kamera pada `HandTrackingService` (**H4**), serta kode error terstruktur `HandTrackingErrorCode` (**H8**).
   - Implementasikan langganan stream di `PracticeController` (**F15**) dan penghentian kamera saat aplikasi berpindah ke background (**F16**).

3. **Tahap 3 — Fondasi Aplikasi, Konfigurasi, dan Auth (Minggu 2 — Gate M2):**
   - Implementasikan pembacaan konfigurasi melalui `--dart-define-from-file` di `lib/core/config/` (**H10**).
   - Amankan `signInPlaceholder` dengan `kDebugMode` (atau ganti dengan Supabase Auth), perbaiki alur `SplashView`, tambahkan route `/`, dan simpan tujuan awal pada `redirect` (**H9, F17, F18**).
   - Aktifkan bagian `assets:` di `pubspec.yaml`, bersihkan `cupertino_icons` (**H12**), dan rapikan metadata Web (`manifest.json`, `index.html`) (**F19**).

---

### 6.3 Pertanyaan Terbuka & Status Pembahasan

1. **Resolusi Handedness Kembar (H6 — Status: `diusulkan`, dibahas di ADR 0002 / Prompt 2-R):**
   - *Pertanyaan:* Ketika MediaPipe mendeteksi 2 tangan dengan label sisi yang sama pada satu frame kamera, bagaimana kontrak harus menanganinya?
   - *Usulan arah untuk dibahas di ADR 0002:* Jangan bergantung semata pada label handedness MediaPipe. Opsi membuang salah satu tangan berisiko merusak huruf BISINDO dua tangan. Diusulkan mengevaluasi pengurutan spasial (misalnya tangan dengan koordinat `x` wrist paling kiri ditempatkan lebih dulu) dan membandingkannya dengan pengurutan berlabel pada data hasil ekstraksi; penandaan frame ambigu tetap disimpan sebagai fallback.

2. **Skema Normalisasi Fitur, `worldLandmarks`, dan Mirror (H7 — Status: `diusulkan`, dibahas di ADR 0002 / Prompt 2-R):**
   - *Fakta verifikasi dokumentasi resmi MediaPipe:* Berdasarkan dokumentasi resmi Google AI Edge MediaPipe Hand Landmarker (https://ai.google.dev/edge/mediapipe/solutions/vision/hand_landmarker), output `worldLandmarks` (`hand_world_landmarks`) berisi 21 titik 3D dalam satuan metrik dunia nyata (meter) dengan titik asal $(0, 0, 0)$ berada pada **pusat geometris masing-masing tangan**. Karena setiap tangan memiliki titik pusatnya sendiri, posisi/jarak relatif antartangan tidak terekam di dalam `worldLandmarks` saja.
   - *Usulan arah untuk dibahas di ADR 0002:* Simpan kedua jenis landmark (`landmarks` ternormalisasi dan `worldLandmarks`) saat ekstraksi untuk dibandingkan pada tahap training; gunakan `worldLandmarks` atau `normalizedLandmarks` + skala untuk bentuk per tangan, dan hitung offset antartangan dari koordinat gambar yang dikoreksi rasio aspek menggunakan `imageWidth` dan `imageHeight`. Untuk mirror, diusulkan konvensi bahwa input ke MediaPipe tidak di-mirror (mirror hanya untuk tampilan preview UI) disertai augmentasi horizontal flip saat training.

3. **Bentuk Kontrak Preview Kamera (H4 — Status: `diusulkan`, dibahas di ADR 0002 / Prompt 2-R):**
   - *Pertanyaan:* Apakah `HandTrackingService` mengekspos `buildPreview` secara langsung atau memisahkan `CameraService` dari `HandTrackingService`?
   - *Usulan arah untuk dibahas di ADR 0002:* Satu service terpadu dengan `buildPreview` karena siklus hidup kamera dan tracker saling terikat erat (memisahkannya akan memaksa frame kamera melintasi batas Dart/native), dan difinalkan setelah spike teknis.

4. **Keputusan CPMK API & Guest Mode (DG-03 & DG-04):**
   - **DG-03 (Penggunaan Supabase REST API untuk CPMK PBP):** Status: **menunggu jawaban dosen**.
   - **DG-04 (Kebijakan Autentikasi vs Guest Mode):** Status: **login wajib sementara, mengikuti dokumen**.
