-- =============================================================================
-- Seed Data: supabase/seed/seed.sql
-- Proyek   : Isyaratify (Kamus Alfabet Statis BISINDO A-Z, Panduan Belajar,
--            Quest Bertahap, dan Katalog Badge)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Materi Kamus Alfabet BISINDO A-Z (26 Kelas Gestur Statis)
-- -----------------------------------------------------------------------------
insert into public.letters (
  letter, hand_count, difficulty, description, step_by_step_guides, common_mistakes, sort_order
) values
(
  'A', 2, 'easy',
  'Membentuk puncak segitiga seperti huruf A kapital menggunakan kedua tangan.',
  '["Pertemukan ujung jari telunjuk dan jari tengah tangan kiri dan kanan membentuk puncak segitiga.", "Tempelkan kedua ibu jari secara horizontal di bagian tengah sebagai garis lintang huruf A.", "Lipat jari manis dan kelingking ke arah telapak tangan."]'::jsonb,
  'Kedua tangan terlalu renggang atau ibu jari tidak membentuk garis horizontal yang jelas.',
  1
),
(
  'B', 2, 'medium',
  'Membentuk garis tegak dengan satu tangan dan dua lengkungan huruf B dengan tangan lainnya.',
  '["Tegakkan jari telunjuk tangan kiri sebagai tiang vertikal huruf B.", "Bentuk lengkungan ganda dengan jari-jari tangan kanan menempel pada sisi tiang jari tangan kiri.", "Pastikan kedua tangan menghadap jelas ke arah kamera."]'::jsonb,
  'Posisi tangan saling menutupi seluruh jari sehingga kamera hanya mendeteksi satu tangan.',
  2
),
(
  'C', 1, 'easy',
  'Membentuk lengkungan menyerupai huruf C menggunakan satu tangan.',
  '["Buka telapak tangan dominan menghadap ke samping.", "Lengkungkan keempat jari (telunjuk hingga kelingking) bersama ibu jari membentuk setengah lingkaran seperti huruf C.", "Jaga jarak antar ujung jari telunjuk dan ibu jari agar tetap terbuka."]'::jsonb,
  'Jari telunjuk dan ibu jari menempel penuh sehingga terbaca sebagai huruf O.',
  3
),
(
  'D', 2, 'medium',
  'Membentuk tiang vertikal dengan satu tangan dan lengkungan perut huruf D dengan tangan lainnya.',
  '["Tegakkan jari telunjuk tangan kiri secara vertikal.", "Bentuk lengkungan huruf C dengan jari telunjuk dan ibu jari tangan kanan.", "Tempelkan ujung lengkungan tangan kanan ke sisi tiang jari tangan kiri membentuk huruf D kapital."]'::jsonb,
  'Lengkungan menghadap ke arah yang terbalik atau tertutup oleh telapak tangan.',
  4
),
(
  'E', 1, 'easy',
  'Menekuk jari-jari satu tangan ke arah dalam membentuk kontur huruf E.',
  '["Hadapkan telapak tangan ke arah kamera.", "Tekuk keempat jari bagian atas ke arah tengah telapak tangan.", "Lipat ibu jari di bagian bawah menyentuh ujung jari atau melintang di depan telapak."]'::jsonb,
  'Kepalan tangan tertutup terlalu rapat seperti tinju penuh.',
  5
),
(
  'F', 2, 'easy',
  'Menyilangkan atau menempelkan jari dari kedua tangan membentuk palang huruf F.',
  '["Tegakkan jari telunjuk tangan non-dominan sebagai tiang vertikal.", "Rapatkan jari telunjuk dan jari tengah tangan dominan secara horizontal.", "Tempelkan kedua jari horizontal tersebut pada bagian atas tiang vertikal membentuk huruf F."]'::jsonb,
  'Hanya menggunakan satu jari horizontal sehingga menyerupai huruf T.',
  6
),
(
  'G', 2, 'medium',
  'Membentuk lengkungan huruf G dengan kombinasi kedua tangan.',
  '["Bentuk lengkungan huruf C pada tangan kiri.", "Arahkan jari telunjuk atau kepalan tangan kanan di ujung bawah lengkungan untuk membentuk kait dalam huruf G.", "Jaga agar kedua tangan berada pada bidang yang sejajar terhadap kamera."]'::jsonb,
  'Sudut tangan terlalu miring sehingga lengkungan C tidak terlihat oleh kamera.',
  7
),
(
  'H', 2, 'medium',
  'Membentuk dua tiang sejajar dengan garis penghubung di tengah seperti huruf H.',
  '["Tegakkan jari telunjuk pada kedua tangan atau kombinasikan jari vertikal dan jari penghubung horizontal.", "Hubungkan bagian tengah kedua tiang sehingga siluet huruf H terlihat jelas dari depan kamera."]'::jsonb,
  'Jarak kedua tangan terlalu jauh sehingga tidak terbaca sebagai satu kesatuan gestur H.',
  8
),
(
  'I', 1, 'easy',
  'Menegakkan jari kelingking ke atas menggunakan satu tangan.',
  '["Kepalkan jari telunjuk, jari tengah, dan jari manis ke arah telapak tangan.", "Kunci dengan ibu jari di bagian depan.", "Tegakkan jari kelingking lurus ke atas."]'::jsonb,
  'Jari manis ikut terangkat sebagian sehingga bentuk kelingking tidak tegas.',
  9
),
(
  'J', 1, 'easy',
  'Menampilkan posisi akhir kurva huruf J dengan jari kelingking satu tangan.',
  '["Mulai dari bentuk jari kelingking tegak seperti huruf I.", "Arahkan kemiringan tangan/kelingking membentuk kait bawah huruf J secara statis di depan kamera."]'::jsonb,
  'Menggerakkan tangan terlalu cepat hingga gambar kamera menjadi kabur (motion blur).',
  10
),
(
  'K', 2, 'medium',
  'Membentuk tiang vertikal dengan satu tangan dan sudut miring huruf K dengan tangan lainnya.',
  '["Tegakkan jari telunjuk tangan kiri secara lurus vertikal.", "Bentuk sudut V menggunakan jari telunjuk dan jari tengah tangan kanan.", "Tempelkan pangkal sudut V tersebut pada bagian tengah tiang vertikal tangan kiri."]'::jsonb,
  'Sudut jari telunjuk dan jari tengah tangan kanan terlalu rapat.',
  11
),
(
  'L', 1, 'easy',
  'Membentuk siku-siku 90 derajat seperti huruf L dengan ibu jari dan telunjuk satu tangan.',
  '["Lipat jari tengah, jari manis, dan kelingking ke dalam telapak tangan.", "Tegakkan jari telunjuk lurus ke atas.", "Rentangkan ibu jari lurus ke samping membentuk sudut siku-siku."]'::jsonb,
  'Ibu jari tidak direntangkan ke samping melainkan tetap menempel di dekat telunjuk.',
  12
),
(
  'M', 2, 'medium',
  'Menempatkan tiga jari di atas telapak/jari tangan lain untuk membentuk tiga kaki huruf M.',
  '["Buka tiga jari (telunjuk, tengah, manis) pada tangan dominan.", "Tempelkan atau tumpangkan ketiga jari tersebut pada punggung/jari tangan non-dominan sehingga membentuk tiga kaki huruf M."]'::jsonb,
  'Hanya menempelkan dua jari sehingga terbaca sebagai huruf N.',
  13
),
(
  'N', 2, 'medium',
  'Menempatkan dua jari di atas tangan lain untuk membentuk dua kaki huruf N.',
  '["Rapatkan jari telunjuk dan jari tengah pada tangan dominan.", "Tempelkan kedua jari tersebut pada tangan non-dominan membentuk siluet huruf N."]'::jsonb,
  'Jari manis ikut terbuka sehingga tertukar dengan huruf M.',
  14
),
(
  'O', 1, 'easy',
  'Mempertemukan ujung jari-jari dan ibu jari satu tangan membentuk lingkaran O.',
  '["Lengkungkan keempat jari tangan dominan ke arah depan.", "Tempelkan ujung jari telunjuk dan tengah dengan ujung ibu jari sehingga membentuk lubang lingkaran O yang jelas.", "Arahkan sisi lubang lingkaran agar terlihat oleh kamera."]'::jsonb,
  'Lubang lingkaran tertutup rapat seperti kepalan tangan.',
  15
),
(
  'P', 2, 'medium',
  'Membentuk tiang vertikal dengan satu tangan dan satu lengkungan atas huruf P dengan tangan lainnya.',
  '["Tegakkan jari telunjuk tangan kiri sebagai tiang vertikal.", "Bentuk setengah lingkaran menggunakan jari telunjuk dan ibu jari tangan kanan.", "Tempelkan lengkungan tersebut pada bagian atas tiang vertikal tangan kiri."]'::jsonb,
  'Lengkungan ditempelkan terlalu rendah di bagian bawah tiang.',
  16
),
(
  'Q', 2, 'medium',
  'Membentuk lingkaran dengan satu tangan dan garis ekor huruf Q dengan jari tangan lainnya.',
  '["Bentuk lingkaran huruf O menggunakan salah satu tangan.", "Arahkan jari telunjuk tangan lainnya memotong bagian bawah lingkaran sebagai ekor huruf Q."]'::jsonb,
  'Jari ekor menutupi seluruh lingkaran sehingga landmark tangan pertama hilang.',
  17
),
(
  'R', 1, 'easy',
  'Menyilangkan jari tengah di atas jari telunjuk atau menjentikkan posisi statis huruf R pada satu tangan.',
  '["Lipat jari manis dan kelingking ke telapak tangan dengan ditahan ibu jari.", "Angkat jari telunjuk dan jari tengah, lalu silangkan/tumpukkan jari tengah dengan jari telunjuk."]'::jsonb,
  'Jari telunjuk dan jari tengah terbuka lebar seperti huruf V.',
  18
),
(
  'S', 2, 'medium',
  'Mengaitkan lengkungan jari dari kedua tangan membentuk lekukan huruf S.',
  '["Bentuk lengkungan huruf C kecil pada masing-masing tangan.", "Kaitkan kedua lengkungan secara berlawanan (atas dan bawah) sehingga membentuk alur huruf S."]'::jsonb,
  'Kedua tangan saling menggenggam rapat hingga jari-jari tidak terlihat.',
  19
),
(
  'T', 2, 'easy',
  'Membentuk tiang vertikal dan garis atap horizontal seperti huruf T menggunakan kedua tangan.',
  '["Tegakkan jari telunjuk tangan non-dominan secara vertikal.", "Letakkan jari telunjuk atau telapak tangan dominan secara mendatar (horizontal) tepat di atas ujung jari vertikal."]'::jsonb,
  'Garis horizontal berada di tengah tiang sehingga menyerupai tanda tambah.',
  20
),
(
  'U', 1, 'easy',
  'Menegakkan jari telunjuk dan jari tengah secara rapat sejajar ke atas pada satu tangan.',
  '["Lipat jari manis dan jari kelingking ke dalam telapak tangan dan tahan dengan ibu jari.", "Tegakkan jari telunjuk dan jari tengah lurus ke atas dalam posisi rapat menyatu."]'::jsonb,
  'Jari telunjuk dan jari tengah merenggang membentuk sudut V.',
  21
),
(
  'V', 1, 'easy',
  'Merenggangkan jari telunjuk dan jari tengah membentuk huruf V pada satu tangan.',
  '["Lipat jari manis dan kelingking ke telapak tangan dengan ditahan ibu jari.", "Angkat jari telunjuk dan jari tengah lalu buka keduanya membentuk huruf V."]'::jsonb,
  'Jari telunjuk dan jari tengah terlalu rapat sehingga terbaca sebagai huruf U.',
  22
),
(
  'W', 2, 'medium',
  'Menggabungkan sudut jari dari kedua tangan membentuk puncak ganda huruf W.',
  '["Bentuk huruf V pada kedua tangan atau rentangkan tiga jari.", "Pertemukan sisi dalam kedua tangan sehingga membentuk siluet huruf W yang simetris."]'::jsonb,
  'Posisi salah satu tangan berada jauh di belakang tangan lainnya.',
  23
),
(
  'X', 2, 'easy',
  'Menyilangkan kedua jari telunjuk membentuk tanda silang huruf X.',
  '["Kepalkan jari tengah, manis, dan kelingking pada kedua tangan.", "Tegakkan jari telunjuk kiri dan kanan.", "Silangkan kedua jari telunjuk tepat di bagian tengah membentuk huruf X."]'::jsonb,
  'Kedua jari telunjuk hanya sejajar dan tidak bersilangan.',
  24
),
(
  'Y', 2, 'hard',
  'Membentuk percabangan huruf Y menggunakan kombinasi jari kedua tangan atau rentangan ibu jari dan kelingking.',
  '["Bentuk sudut V pada bagian atas dan tiang penopang di bagian bawah menggunakan kombinasi jari, atau rentangkan ibu jari dan kelingking dengan jelas ke kamera.", "Tahan posisi secara stabil di tengah bidang kamera."]'::jsonb,
  'Posisi jari miring menjauhi kamera sehingga ujung jari tidak terdeteksi.',
  25
),
(
  'Z', 1, 'medium',
  'Membentuk sudut zig-zag huruf Z menggunakan posisi telapak/jari secara tegas di depan kamera.',
  '["Arahkan jari telunjuk atau bidang telapak tangan membentuk sudut patahan huruf Z sesuai referensi visual.", "Tahan posisi tangan dengan stabil agar landmark terdeteksi penuh."]'::jsonb,
  'Menggerakkan tangan terlalu cepat keluar dari area bingkai kamera.',
  26
)
on conflict (letter) do update
  set hand_count = excluded.hand_count,
      difficulty = excluded.difficulty,
      description = excluded.description,
      step_by_step_guides = excluded.step_by_step_guides,
      common_mistakes = excluded.common_mistakes,
      sort_order = excluded.sort_order;

-- -----------------------------------------------------------------------------
-- 2. Modul Panduan Belajar (learning_guides)
-- -----------------------------------------------------------------------------
insert into public.learning_guides (
  slug, category, title, summary, content, icon_key, sort_order, is_published
) values
(
  'mengenal-alfabet-bisindo',
  'bisindo_intro',
  'Mengenal Alfabet BISINDO (A–Z)',
  'Karakteristik huruf 1 tangan dan 2 tangan pada Bahasa Isyarat Indonesia.',
  'BISINDO (Bahasa Isyarat Indonesia) merupakan bahasa isyarat yang tumbuh secara alami di komunitas Tuli Indonesia. Pada alfabet jari BISINDO, sebagian huruf diperagakan menggunakan 1 tangan (seperti C, E, I, J, L, O, R, U, V, Z) dan sebagian lainnya menggunakan koordinasi 2 tangan (seperti A, B, D, F, G, H, K, M, N, P, Q, S, T, W, X, Y). Isyaratify membantu Anda melatih bentuk statis ke-26 huruf tersebut secara bertahap.',
  'sign_language',
  1,
  true
),
(
  'panduan-posisi-kamera',
  'camera_setup',
  'Panduan Framing Kamera & Pencahayaan',
  'Cara memposisikan tangan agar pelacakan 21 titik landmark MediaPipe akurat.',
  '1. Pastikan sumber cahaya berada di depan Anda (jangan membelakangi jendela terang).\n2. Jaga jarak tangan sekitar 40–70 cm dari kamera agar pergelangan hingga ujung jari masuk sepenuhnya ke dalam bingkai.\n3. Untuk huruf 2 tangan, usahakan kedua tangan sejajar menghadap kamera dan tidak saling menutupi secara penuh.',
  'videocam',
  2,
  true
),
(
  'tips-prediksi-stabil',
  'practice_tips',
  'Cara Mendapatkan Prediksi Stabil & XP',
  'Mengenal cara kerja temporal smoothing saat latihan target huruf.',
  'Saat berlatih di mode Target Practice, tahan bentuk gestur huruf selama kurang lebih 1 detik hingga indikator stabil terpenuhi. Sistem menggunakan temporal smoothing agar gerakan transisi jari tidak langsung dianggap salah. Setiap target huruf yang berhasil dicapai secara stabil akan memberikan XP dan memperbarui progres penguasaan huruf Anda di cloud.',
  'tips_and_updates',
  3,
  true
)
on conflict (slug) do update
  set category = excluded.category,
      title = excluded.title,
      summary = excluded.summary,
      content = excluded.content,
      icon_key = excluded.icon_key,
      sort_order = excluded.sort_order,
      is_published = excluded.is_published;

-- -----------------------------------------------------------------------------
-- 3. Daftar Quest Pembelajaran Bertahap (quests)
-- -----------------------------------------------------------------------------
insert into public.quests (
  code, title, description, quest_type, target_value, target_letters, xp_reward, is_active, sort_order
) values
(
  'quest_first_practice',
  'Langkah Pertama',
  'Selesaikan 1 kali percobaan latihan gestur menggunakan kamera.',
  'practice_count',
  1,
  '{}',
  25,
  true,
  1
),
(
  'quest_vowels_aiueo',
  'Penguasaan Huruf Vokal',
  'Peragakan kelima huruf vokal (A, I, U, E, O) dengan benar minimal satu kali.',
  'specific_letters',
  5,
  '{A,I,U,E,O}',
  50,
  true,
  2
),
(
  'quest_one_hand_basics',
  'Gestur Satu Tangan Dasar',
  'Peragakan huruf satu tangan C, L, O, U, dan V dengan benar.',
  'specific_letters',
  5,
  '{C,L,O,U,V}',
  50,
  true,
  3
),
(
  'quest_two_hands_coord',
  'Koordinasi Dua Tangan',
  'Berhasil memperagakan gestur huruf 2 tangan sebanyak 5 kali.',
  'two_hands_correct',
  5,
  '{}',
  60,
  true,
  4
),
(
  'quest_master_5_letters',
  'Kolektor 5 Huruf',
  'Capai status Mastered pada minimal 5 huruf alfabet BISINDO.',
  'master_letters',
  5,
  '{}',
  80,
  true,
  5
),
(
  'quest_master_all_26',
  'Tuntas Alfabet A–Z',
  'Capai status Mastered pada seluruh 26 huruf alfabet BISINDO.',
  'master_letters',
  26,
  '{}',
  250,
  true,
  6
)
on conflict (code) do update
  set title = excluded.title,
      description = excluded.description,
      quest_type = excluded.quest_type,
      target_value = excluded.target_value,
      target_letters = excluded.target_letters,
      xp_reward = excluded.xp_reward,
      is_active = excluded.is_active,
      sort_order = excluded.sort_order;

-- -----------------------------------------------------------------------------
-- 4. Katalog Badge Pencapaian (badges)
-- -----------------------------------------------------------------------------
insert into public.badges (
  code, title, description, icon_key, sort_order
) values
(
  'first_step',
  'Langkah Pertama',
  'Berhasil mengenali huruf BISINDO pertama melalui kamera.',
  'waving_hand',
  1
),
(
  'vowel_explorer',
  'Penjelajah Vokal',
  'Berhasil memperagakan seluruh huruf vokal A, I, U, E, dan O.',
  'record_voice_over',
  2
),
(
  'two_hands_adept',
  'Terampil Dua Tangan',
  'Berhasil menyelesaikan 5 latihan huruf BISINDO dua tangan.',
  'pan_tool',
  3
),
(
  'alphabet_scholar',
  'Pelajar Tekun (10 Huruf)',
  'Menguasai (Mastered) minimal 10 huruf alfabet BISINDO.',
  'school',
  4
),
(
  'bisindo_master',
  'Master Alfabet BISINDO',
  'Menguasai seluruh 26 huruf alfabet statis BISINDO A–Z.',
  'workspace_premium',
  5
)
on conflict (code) do update
  set title = excluded.title,
      description = excluded.description,
      icon_key = excluded.icon_key,
      sort_order = excluded.sort_order;
