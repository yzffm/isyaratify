# Isyaratify

Aplikasi pembelajaran **alfabet BISINDO** (huruf A–Z, gestur statis) berbasis kamera, hand tracking MediaPipe, dan klasifikasi Machine Learning *on-device*. Target platform: **Flutter Web** dan **Android APK**.

> **Cakupan MVP:** Latihan dan pengenalan alfabet statis BISINDO A–Z. Isyaratify bukan alat komunikasi atau penerjemah bahasa isyarat real-time dan tidak mengenali kalimat, tata bahasa, atau gerakan dinamis.

---

## Struktur Repository

| Folder | Isi |
|---|---|
| `frontend/` | Aplikasi Flutter satu codebase (Web + Android, MVC + Provider, `go_router`, `dio`) |
| `ml/` | Notebook riset, laporan audit dataset & evaluasi model, serta skrip modular Python (`ml/src/`) |
| `supabase/` | Migrasi database PostgreSQL, kebijakan RLS, fungsi RPC atomik `record_practice_attempt`, & `seed.sql` |
| `scripts/` | Skrip build otomatis (`cloudflare-build.sh`) untuk integrasi Git Cloudflare |
| `docs/` | Kontrak API (`api-contract.md`), Model Card (`ml-model-card.md`), dan ADR (`docs/decisions/`) |
| `.github/workflows/` | Pipeline CI GitHub Actions (`flutter-ci.yml`) |

---

## Menjalankan Frontend secara Lokal

Proyek dan CI menggunakan **Flutter 3.38.6 (Dart 3.10.7)**. Salin `.env.example` menjadi `.env` di root repository (jangan pernah di-commit) dan isi `SUPABASE_URL` serta `SUPABASE_PUBLISHABLE_KEY`.

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define-from-file=../.env
```

Sebelum melakukan `git push` atau membuka Pull Request, jalankan pemeriksaan berikut dari folder `frontend/`:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Build produksi (Web & Android APK):

```bash
cd frontend
flutter build web --release --dart-define-from-file=../.env
flutter build apk --release --dart-define-from-file=../.env
```

---

## Deployment Otomatis ke Cloudflare (Connect GitHub)

Repository ini telah dilengkapi `scripts/cloudflare-build.sh`, `wrangler.jsonc`, `frontend/web/_redirects`, dan `frontend/web/_headers`:

- **Build command:** `bash scripts/cloudflare-build.sh`
- **Build output directory (Pages):** `frontend/build/web`
- **Deploy command (Workers Static Assets):** `npx wrangler deploy`
- **Environment variables:** `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY`

---

## Status Milestone

- **UI/UX & Navigasi (`go_router` + Material 3):** Seluruh rute utama (`/splash`, `/onboarding`, `/login`, `/register`, `/home`, `/dictionary`, `/practice`, `/quest`, `/leaderboard`, `/progress`, `/profile`, `/about`) aktif dan responsif.
- **Computer Vision & On-Device ML:** Adapter Web (`hand_tracking_web.js`) dan Android (`CameraX` + MediaPipe Tasks Vision `0.10.14` di `MainActivity.kt`) terhubung ke model MLP 126-fitur (`1.0.0-mlp-unimal`, Test Accuracy `95.76%`, Macro F1 `95.72%`) di `frontend/assets/ml/classifier.json`.
- **Backend & Gamifikasi:** Terintegrasi dengan Supabase Auth, PostgreSQL RLS, dan RPC `record_practice_attempt` melalui `DioPlatformHttpClient` dengan fallback offline/demo lokal.
