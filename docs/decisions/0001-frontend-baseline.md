# 0001 — Baseline frontend: Flutter, routing, state, platform adapter

Status: diterima (baseline Minggu 1) · Pemilik: Anggota 1

## Keputusan
- **Flutter 3.38.6 / Dart 3.10.7** (versi terpasang di mesin pengembangan). Platform `web` dan `android` saja (tanpa iOS/desktop).
- **Application ID Android:** `com.isyaratify.app` (namespace, `applicationId`, dan package `MainActivity` disesuaikan setelah `flutter create`). Sulit diubah setelah rilis pertama.
- **MVC pragmatis + Provider.** `main.dart` hanya `runApp`; `app.dart` memasang Provider, tema, dan router.
- **Routing: `go_router`** — deklaratif, redirect berbasis auth, siap untuk deep link Web.
- **Kontrak landmark:** `HandLandmarkFrame` (maks 2 tangan, 21 landmark/tangan, x/y/z, presence per tangan, urutan kanonik left lalu right, validasi ketat). Koordinat mentah 126 nilai; tangan yang tidak ada diisi 0.0 hanya pada representasi mentah. Penanganan missing hand, normalisasi, dan skala z untuk model ditetapkan di `FeatureService` (belum dibuat) bersama Anggota 4/5/6.
- **`HandTrackingService`** (abstract interface) dengan implementasi per platform di `lib/platform/{web,android}/`, dipilih lewat conditional import (`dart.library.js_interop` → Web, `dart.library.io` → Android). Tidak ada `dart:io` di kode lintas platform. Saat ini seluruhnya stub yang melempar `HandTrackingException`.
- **CI:** `dart format` (cek), `flutter analyze`, `flutter test`, `flutter build web --release`, dan `flutter build apk --debug` pada Flutter 3.38.6 dengan runner di-pin ke `ubuntu-24.04` (merujuk migrasi `ubuntu-latest` ke Ubuntu 26.04 pada `actions/runner-images#14748`).

## Dependency (versi hasil resolusi `flutter pub`, tercatat di `pubspec.lock`)
| Package | Versi | Alasan | Web | Android |
|---|---|---|---|---|
| `provider` | 6.1.5+1 | State management (keputusan proyek) | Pure Dart/Flutter, build web lulus* | Pure Dart/Flutter, build apk debug lulus* |
| `go_router` | 17.5.0 | Routing | Resmi Flutter, memakai `flutter_web_plugins` untuk Web* | Pure Dart/Flutter, build apk debug lulus* |
| `flutter_lints` (dev) | ^6.0.0 | Lint | n/a | n/a |

\* Diverifikasi pada 7 Nov 2026 (Windows 11, Flutter 3.38.6): `flutter build web` dan `flutter build apk --debug` lulus. Build APK release dan konfigurasi signing release belum diuji.

Sengaja ditunda: `camera`, MediaPipe, `supabase_flutter`, `fl_chart`, `flutter_animate`, `shared_preferences` — dipilih setelah spike dan uji dukungan Web/Android.

## Risiko / catatan
- `flutter build web` dan `flutter build apk --debug` telah terverifikasi pada 7 Nov 2026 (Windows 11, Flutter 3.38.6, Android SDK 36.1.0, `minSdk = 24`). APK release dan signing release belum diuji; komponen `cmdline-tools` pada mesin lokal masih perlu dipasang untuk menjalankan `flutter doctor --android-licenses`.
- GitHub Actions di-pin ke runner `ubuntu-24.04` (`actions/runner-images#14748`), memakai `actions/checkout@v7` dan `actions/setup-java@v6` (Node 24 native), serta mem-pin `subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2` (`v2.23.0`).
- Siap untuk spike: tambahkan `web/hand_tracking_web.js` dan isi `platform/web/` & `platform/android/` tanpa mengubah kontrak.
