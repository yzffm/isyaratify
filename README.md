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

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Build:

```bash
flutter build web
flutter build apk   # butuh Android SDK (cmdline-tools + lisensi)
```

## Konfigurasi

Salin `.env.example` ke `.env` dan isi sendiri. Jangan commit `.env`. Jangan pernah menaruh `service_role` key di client.

## Status

Baseline Minggu 1: fondasi Flutter, kontrak data landmark, dan platform adapter. MediaPipe, Supabase, dan classifier belum diimplementasikan.

