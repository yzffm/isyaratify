# Supabase Backend — Isyaratify

Direktori ini menyimpan skema database PostgreSQL, kebijakan Row Level Security (RLS), fungsi RPC atomik, serta seed data materi alfabet BISINDO A–Z, panduan belajar, quest, dan badge untuk proyek **Isyaratify**.

---

## 1. Struktur Folder

```text
supabase/
├── README.md
├── migrations/
│   └── 20261110000001_initial_schema.sql
└── seed/
    └── seed.sql
```

---

## 2. Daftar Tabel, View, dan Fungsi RPC

| Objek | Jenis | Akses RLS (`authenticated`) | Deskripsi |
|---|---|---|---|
| `public.profiles` | Table | `SELECT`, `INSERT`, `UPDATE` baris milik sendiri (`id = auth.uid()`) | Profil publik pengguna (`username`, `display_name`, `avatar_url`, `bio`) tanpa mengekspos email. |
| `public.letters` | Table | `SELECT` semua baris | Materi kamus 26 huruf alfabet statis BISINDO (`A`–`Z`), jumlah tangan (`1`/`2`), tingkat kesulitan, langkah peragaan (`step_by_step_guides`), dan kesalahan umum (`common_mistakes`). |
| `public.learning_guides` | Table | `SELECT` baris terpublikasi | Modul panduan belajar BISINDO, setup posisi kamera, dan tips temporal smoothing yang dipanggil melalui REST API. |
| `public.quests` | Table | `SELECT` semua baris | Definisi misi pembelajaran bertahap (`practice_count`, `correct_count`, `master_letters`, `specific_letters`, `two_hands_correct`). |
| `public.badges` | Table | `SELECT` semua baris | Katalog lencana pencapaian. |
| `public.user_progress` | Table | `SELECT` baris milik sendiri (`user_id = auth.uid()`) | Ringkasan XP, level, streak harian, dan total percobaan pengguna (diperbarui secara atomik melalui RPC). |
| `public.user_letter_mastery` | Table | `SELECT` baris milik sendiri (`user_id = auth.uid()`) | Statistik penguasaan per huruf A–Z (`total_attempts`, `correct_attempts`, `best_confidence`, `is_mastered`). |
| `public.practice_attempts` | Table | `SELECT`, `INSERT` baris milik sendiri (`user_id = auth.uid()`) | Riwayat metadata latihan (tanpa menyimpan foto/frame kamera). |
| `public.quest_completions` | Table | `SELECT` baris milik sendiri (`user_id = auth.uid()`) | Catatan penyelesaian quest per pengguna. |
| `public.user_badges` | Table | `SELECT` baris milik sendiri (`user_id = auth.uid()`) | Catatan badge yang telah diperoleh pengguna. |
| `public.leaderboard_entries` | Table | `SELECT` semua baris | Tabel ringkasan peringkat publik (tanpa email) yang disinkronkan otomatis oleh trigger dan RPC. |
| `public.leaderboard_view` | View (`security_invoker = true`) | `SELECT` semua baris | View peringkat pengguna terurut berdasarkan `xp DESC, mastered_letters_count DESC`. |
| `public.record_practice_attempt` | RPC Function | `EXECUTE` oleh `authenticated` | Mencatat attempt, memperbarui `user_letter_mastery`, menambah XP/level/streak, mengevaluasi penyelesaian quest & badge secara atomik, dan mengembalikan ringkasan JSON. |

---

## 3. Cara Menjalankan Migrasi & Seed

1. Pastikan proyek Supabase telah aktif dan jalankan file migrasi `supabase/migrations/20261110000001_initial_schema.sql` melalui Supabase SQL Editor, Supabase CLI, atau Supabase MCP (`apply_migration`).
2. Jalankan `supabase/seed/seed.sql` untuk mengisi 26 huruf alfabet BISINDO A–Z, 3 modul panduan belajar, 6 quest awal, dan 5 badge.
3. Salin `.env.example` menjadi `.env` di root repository (jangan pernah di-commit) dan isi `SUPABASE_URL` serta `SUPABASE_PUBLISHABLE_KEY` (`sb_publishable_...`).
4. Jangan pernah menaruh `service_role` atau `sb_secret_...` key di aplikasi Flutter.
