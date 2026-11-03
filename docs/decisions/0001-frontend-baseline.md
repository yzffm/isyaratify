# 0001 — Baseline frontend: Flutter, routing, state, platform adapter

Status: diterima (baseline Minggu 1) · Pemilik: Anggota 1

## Keputusan
- **Flutter 3.38.6 / Dart 3.10.7** (versi terpasang di mesin pengembangan). Platform `web` dan `android` saja (tanpa iOS/desktop).
- **Application ID Android:** `com.isyaratify.app` (namespace, `applicationId`, dan package `MainActivity` disesuaikan setelah `flutter create`). Sulit diubah setelah rilis pertama.
- **MVC pragmatis + Provider.** `main.dart` hanya `runApp`; `app.dart` memasang Provider, tema, dan router.
- **Routing: `go_router`** — deklaratif, redirect berbasis auth, siap untuk deep link Web.
- **Kontrak landmark:** `HandLandmarkFrame` (maks 2 tangan, 21 landmark/tangan, x/y/z, presence per tangan, urutan kanonik left lalu right, validasi ketat). Koordinat mentah 126 nilai; tangan yang tidak ada diisi 0.0 hanya pada representasi mentah. Penanganan missing hand, normalisasi, dan skala z untuk model ditetapkan di `FeatureService` (belum dibuat) bersama Anggota 4/5/6.
- **`HandTrackingService`** (abstract interface) dengan implementasi per platform di `lib/platform/{web,android}/`, dipilih lewat conditional import (`dart.library.js_interop` → Web, `dart.library.io` → Android). Tidak ada `dart:io` di kode lintas platform. Saat ini seluruhnya stub yang melempar `HandTrackingException`.
- **CI:** `dart format` (cek), `flutter analyze`, `flutter test` pada Flutter 3.38.6.

## Dependency (versi hasil resolusi `flutter pub`, tercatat di `pubspec.lock`)
| Package | Versi | Alasan | Web | Android |
|---|---|---|---|---|
| `provider` | 6.1.5+1 | State management (keputusan proyek) | Pure Dart/Flutter, build web lulus* | Pure Dart/Flutter* |
| `go_router` | 17.5.0 | Routing | Resmi Flutter, memakai `flutter_web_plugins` untuk Web* | Pure Dart/Flutter* |
| `flutter_lints` (dev) | ^6.0.0 | Lint | n/a | n/a |

\* Lihat laporan build: Web diverifikasi dengan `flutter build web`; Android belum dapat di-build (lihat Risiko).

Sengaja ditunda: `camera`, MediaPipe, `supabase_flutter`, `fl_chart`, `flutter_animate`, `shared_preferences` — dipilih setelah spike dan uji dukungan Web/Android.

## Risiko / catatan
- Toolchain Android di mesin ini belum lengkap (`cmdline-tools` hilang, lisensi belum diterima) sehingga `flutter build apk` belum teruji.
- `subosito/flutter-action@v2` dan `actions/checkout@v4` belum diverifikasi pada dokumentasi resmi saat ini; cek saat CI pertama dijalankan.
- Siap untuk spike: tambahkan `web/hand_tracking_web.js` dan isi `platform/web/` & `platform/android/` tanpa mengubah kontrak.
