## Ringkasan Perubahan
- 

## Area Terdampak
- [ ] `frontend/` (UI / routing / state / service / model)
- [ ] `ml/` (dataset / notebook / training / artefak)
- [ ] `supabase/` (migrasi / RLS / seed)
- [ ] `docs/` atau `.github/` (dokumentasi / CI)

## Cara Menguji
1. 
2. 

## Checklist Kualitas (dari `frontend/`)
- [ ] Menggunakan Flutter **3.38.6** (Dart **3.10.7**)
- [ ] `dart format --output=none --set-exit-if-changed lib test` lulus (exit 0)
- [ ] `flutter analyze` lulus (`No issues found!`)
- [ ] `flutter test` lulus
- [ ] `flutter build web --release` berhasil (jika menyentuh `frontend/`)
- [ ] `flutter build apk --debug` berhasil atau dicatat jika tidak dijalankan

## Screenshot / Rekaman (bila UI berubah)
<!-- Tempel screenshot atau tulis "Tidak ada perubahan UI" -->

## Risiko / Pekerjaan Tersisa
- 
