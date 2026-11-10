# Kontrak API & Data (Supabase REST / PostgREST & RPC) — Isyaratify

Dokumen ini mendefinisikan kontrak integrasi API antara aplikasi Flutter (`frontend/lib/services/supabase_service.dart`) dan layanan backend Supabase PostgreSQL.

> **Prinsip Privasi & Real-Time (`AGENTS.md` §5 & §7):**
> - Kamera, ekstraksi landmark MediaPipe, dan klasifikasi alfabet berjalan **100% lokal (on-device)**.
> - Aplikasi **tidak pernah** mengirimkan frame gambar atau video kamera ke API.
> - Seluruh endpoint di bawah diakses menggunakan `SUPABASE_PUBLISHABLE_KEY` bersama token sesi pengguna (`authenticated`) karena aplikasi menerapkan kebijakan **Login Wajib**.

---

## 1. Autentikasi (Supabase Auth)

| Operasi | Method SDK / Endpoint | Keterangan |
|---|---|---|
| Register Akun Baru | `supabase.auth.signUp(email, password, data: {'display_name': ...})` | Memicu trigger `private.handle_new_user()` yang otomatis membuat baris di `profiles`, `user_progress`, dan `leaderboard_entries`. |
| Login | `supabase.auth.signInWithPassword(email, password)` | Mengembalikan sesi JWT `authenticated`. |
| Logout | `supabase.auth.signOut()` | Menghapus sesi lokal dan mengarahkan router ke `/login`. |

---

## 2. Endpoint Materi & Pembelajaran (REST / PostgREST)

### 2.1 Daftar Kamus Alfabet BISINDO (`GET /rest/v1/letters`)
- **Query:** `.from('letters').select().order('sort_order', ascending: true)`
- **Contoh Respons JSON (1 item):**
```json
{
  "id": 1,
  "letter": "A",
  "hand_count": 2,
  "difficulty": "easy",
  "description": "Membentuk puncak segitiga seperti huruf A kapital menggunakan kedua tangan.",
  "step_by_step_guides": [
    "Pertemukan ujung jari telunjuk dan jari tengah tangan kiri dan kanan membentuk puncak segitiga.",
    "Tempelkan kedua ibu jari secara horizontal di bagian tengah sebagai garis lintang huruf A.",
    "Lipat jari manis dan kelingking ke arah telapak tangan."
  ],
  "common_mistakes": "Kedua tangan terlalu renggang atau ibu jari tidak membentuk garis horizontal yang jelas.",
  "image_url": null,
  "sort_order": 1
}
```

### 2.2 Modul Panduan Belajar & Setup Kamera (`GET /rest/v1/learning_guides`)
- **Query:** `.from('learning_guides').select().eq('is_published', true).order('sort_order', ascending: true)`
- **Kategori (`category`):** `bisindo_intro` | `camera_setup` | `practice_tips`.

---

## 3. Endpoint Progres, Penguasaan Huruf, Quest, & Leaderboard

### 3.1 Ringkasan Progres Pengguna (`GET /rest/v1/user_progress`)
- **Query:** `.from('user_progress').select().eq('user_id', uid).maybeSingle()`
- **Field:** `user_id`, `xp`, `level`, `current_streak`, `last_practice_date`, `total_attempts`, `correct_attempts`, `updated_at`.

### 3.2 Penguasaan per Huruf A–Z (`GET /rest/v1/user_letter_mastery`)
- **Query:** `.from('user_letter_mastery').select().eq('user_id', uid).order('letter', ascending: true)`
- **Contoh Respons JSON:**
```json
{
  "user_id": "00000000-0000-0000-0000-000000000000",
  "letter": "A",
  "total_attempts": 4,
  "correct_attempts": 3,
  "best_confidence": 0.91,
  "is_mastered": true,
  "last_practiced_at": "2026-11-10T14:30:00Z"
}
```

### 3.3 Daftar Quest & Penyelesaian (`GET /rest/v1/quests` & `GET /rest/v1/quest_completions`)
- **Query Quest:** `.from('quests').select().eq('is_active', true).order('sort_order', ascending: true)`
- **Query Completion:** `.from('quest_completions').select('quest_id, completed_at').eq('user_id', uid)`

### 3.4 Leaderboard Publik (`GET /rest/v1/leaderboard_view`)
- **Query:** `.from('leaderboard_view').select().order('rank', ascending: true).limit(50)`
- **Keamanan:** View dibuat dengan `WITH (security_invoker = true)` di atas `leaderboard_entries` dan tidak pernah mengekspos alamat email pengguna.

---

## 4. Endpoint RPC Atomik Pencatatan Latihan (`POST /rest/v1/rpc/record_practice_attempt`)

Dipanggil setelah temporal smoothing menyatakan prediksi huruf pada sesi latihan sudah stabil.

- **Parameter Input:**
```json
{
  "p_target_letter": "A",
  "p_predicted_letter": "A",
  "p_confidence": 0.88,
  "p_is_correct": true,
  "p_inference_ms": 28,
  "p_platform": "web"
}
```
- **Contoh Respons JSON (dari server PostgreSQL):**
```json
{
  "attempt_id": "d290f1ee-6c54-4b01-90e6-d701748f0851",
  "xp_gained": 15,
  "quest_xp_gained": 25,
  "total_xp_gained": 40,
  "new_xp": 40,
  "new_level": 1,
  "leveled_up": false,
  "current_streak": 1,
  "is_letter_mastered": false,
  "mastered_letters_count": 0,
  "completed_quests": [
    {
      "code": "quest_first_practice",
      "title": "Langkah Pertama",
      "xp_reward": 25
    }
  ],
  "earned_badges": [
    {
      "code": "first_step",
      "title": "Langkah Pertama",
      "icon_key": "waving_hand"
    }
  ]
}
```
