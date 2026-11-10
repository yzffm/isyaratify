# Isyaratify

Aplikasi pembelajaran **alfabet BISINDO** (huruf A–Z, gestur statis) berbasis kamera, hand tracking MediaPipe, dan klasifikasi on-device. Target: Flutter Web dan Android APK.

> Cakupan MVP: latihan dan pengenalan alfabet statis. Isyaratify bukan alat komunikasi dan tidak mengenali kalimat, tata bahasa, atau gerakan dinamis.

## Struktur repository

| Folder | Isi |
|---|---|
| `frontend/` | Aplikasi Flutter (Web + Android) |
| `ml/` | Notebook dan skrip training model (Python) |
| `supabase/` | Migrasi dan seed database |
| `docs/` | Dokumen teknis dan catatan keputusan (`docs/decisions/`) |
| `.github/workflows/` | CI |

## Menjalankan frontend

CI menggunakan **Flutter 3.38.6 (Dart 3.10.7)**. Gunakan versi yang sama agar hasil format dan analisis konsisten.

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Sebelum melakukan `git push` atau membuka Pull Request, jalankan pemeriksaan berikut dari folder `frontend/`:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

> **Tip editor:** Aktifkan fitur *format-on-save* untuk bahasa Dart di editor Anda (misalnya `"editor.formatOnSave": true` untuk `[dart]` pada pengaturan VS Code lokal; folder `.vscode/` diabaikan oleh `.gitignore`).

Build:

```bash
flutter build web
flutter build apk   # butuh Android SDK (cmdline-tools + lisensi)
```

## Konfigurasi

Salin `.env.example` ke `.env` dan isi sendiri. Jangan commit `.env`. Jangan pernah menaruh `service_role` key di client.

## Status

Baseline Minggu 1: fondasi Flutter, kontrak data landmark, dan platform adapter. MediaPipe, Supabase, dan classifier belum diimplementasikan.

