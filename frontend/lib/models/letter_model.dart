import '../core/errors/app_exceptions.dart';

/// Tingkat kesulitan peragaan huruf BISINDO.
enum LetterDifficulty {
  easy,
  medium,
  hard;

  static LetterDifficulty parse(Object? raw) =>
      switch (raw?.toString().toLowerCase()) {
        'easy' || 'mudah' => LetterDifficulty.easy,
        'medium' || 'sedang' => LetterDifficulty.medium,
        'hard' || 'sulit' => LetterDifficulty.hard,
        _ => LetterDifficulty.easy,
      };

  String get labelId => switch (this) {
    LetterDifficulty.easy => 'Mudah',
    LetterDifficulty.medium => 'Sedang',
    LetterDifficulty.hard => 'Sulit',
  };
}

/// Model materi satu huruf alfabet BISINDO A–Z (tabel `public.letters`).
class LetterModel {
  LetterModel({
    required this.letter,
    required this.handCount,
    required this.difficulty,
    required this.description,
    required List<String> stepByStepGuides,
    this.commonMistakes = '',
    this.imageUrl,
    required this.sortOrder,
  }) : stepByStepGuides = List.unmodifiable(stepByStepGuides) {
    if (!RegExp(r'^[A-Z]$').hasMatch(letter)) {
      throw LandmarkContractException('Huruf harus A–Z, diterima: $letter');
    }
    if (handCount != 1 && handCount != 2) {
      throw LandmarkContractException(
        'handCount harus 1 atau 2, diterima: $handCount',
      );
    }
  }

  factory LetterModel.fromJson(Map<String, Object?> json) {
    final rawLetter = (json['letter'] ?? '').toString().trim().toUpperCase();
    final rawHandCount = json['hand_count'] ?? json['handCount'] ?? 1;
    final rawGuides = json['step_by_step_guides'] ?? json['stepByStepGuides'];
    final guides = rawGuides is List
        ? rawGuides.map((e) => e.toString()).toList()
        : const <String>[];
    final rawSort = json['sort_order'] ?? json['sortOrder'] ?? 1;
    return LetterModel(
      letter: rawLetter,
      handCount: rawHandCount is num ? rawHandCount.toInt() : 1,
      difficulty: LetterDifficulty.parse(json['difficulty']),
      description: (json['description'] ?? '').toString(),
      stepByStepGuides: guides,
      commonMistakes: (json['common_mistakes'] ?? json['commonMistakes'] ?? '')
          .toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'])?.toString(),
      sortOrder: rawSort is num ? rawSort.toInt() : 1,
    );
  }

  final String letter;
  final int handCount;
  final LetterDifficulty difficulty;
  final String description;
  final List<String> stepByStepGuides;
  final String commonMistakes;
  final String? imageUrl;
  final int sortOrder;

  bool get requiresTwoHands => handCount == 2;

  Map<String, Object?> toJson() => {
    'letter': letter,
    'hand_count': handCount,
    'difficulty': difficulty.name,
    'description': description,
    'step_by_step_guides': stepByStepGuides,
    'common_mistakes': commonMistakes,
    if (imageUrl != null) 'image_url': imageUrl,
    'sort_order': sortOrder,
  };
}

/// Model modul panduan belajar & tips kamera (tabel `public.learning_guides`).
class LearningGuideModel {
  const LearningGuideModel({
    required this.slug,
    required this.category,
    required this.title,
    required this.summary,
    required this.content,
    this.iconKey = 'school',
    this.sortOrder = 1,
  });

  factory LearningGuideModel.fromJson(Map<String, Object?> json) {
    final rawSort = json['sort_order'] ?? json['sortOrder'] ?? 1;
    return LearningGuideModel(
      slug: (json['slug'] ?? '').toString(),
      category: (json['category'] ?? 'bisindo_intro').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      iconKey: (json['icon_key'] ?? json['iconKey'] ?? 'school').toString(),
      sortOrder: rawSort is num ? rawSort.toInt() : 1,
    );
  }

  final String slug;
  final String category;
  final String title;
  final String summary;
  final String content;
  final String iconKey;
  final int sortOrder;

  Map<String, Object?> toJson() => {
    'slug': slug,
    'category': category,
    'title': title,
    'summary': summary,
    'content': content,
    'icon_key': iconKey,
    'sort_order': sortOrder,
  };
}

/// Data kamus lokal A–Z sebagai fallback offline (selaras dengan `supabase/seed/seed.sql`).
final List<LetterModel> kDefaultBisindoLetters = List.unmodifiable([
  LetterModel(
    letter: 'A',
    handCount: 2,
    difficulty: LetterDifficulty.easy,
    description:
        'Membentuk puncak segitiga seperti huruf A kapital menggunakan kedua tangan.',
    stepByStepGuides: const [
      'Pertemukan ujung jari telunjuk dan jari tengah tangan kiri dan kanan membentuk puncak segitiga.',
      'Tempelkan kedua ibu jari secara horizontal di bagian tengah sebagai garis lintang huruf A.',
      'Lipat jari manis dan kelingking ke arah telapak tangan.',
    ],
    commonMistakes:
        'Kedua tangan terlalu renggang atau ibu jari tidak membentuk garis horizontal yang jelas.',
    sortOrder: 1,
  ),
  LetterModel(
    letter: 'B',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Membentuk garis tegak dengan satu tangan dan dua lengkungan huruf B dengan tangan lainnya.',
    stepByStepGuides: const [
      'Tegakkan jari telunjuk tangan kiri sebagai tiang vertikal huruf B.',
      'Bentuk lengkungan ganda dengan jari-jari tangan kanan menempel pada sisi tiang jari tangan kiri.',
      'Pastikan kedua tangan menghadap jelas ke arah kamera.',
    ],
    commonMistakes:
        'Posisi tangan saling menutupi seluruh jari sehingga kamera hanya mendeteksi satu tangan.',
    sortOrder: 2,
  ),
  LetterModel(
    letter: 'C',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description:
        'Membentuk lengkungan menyerupai huruf C menggunakan satu tangan.',
    stepByStepGuides: const [
      'Buka telapak tangan dominan menghadap ke samping.',
      'Lengkungkan keempat jari bersama ibu jari membentuk setengah lingkaran seperti huruf C.',
      'Jaga jarak antar ujung jari telunjuk dan ibu jari agar tetap terbuka.',
    ],
    commonMistakes:
        'Jari telunjuk dan ibu jari menempel penuh sehingga terbaca sebagai huruf O.',
    sortOrder: 3,
  ),
  LetterModel(
    letter: 'D',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Membentuk tiang vertikal dengan satu tangan dan lengkungan perut huruf D dengan tangan lainnya.',
    stepByStepGuides: const [
      'Tegakkan jari telunjuk tangan kiri secara vertikal.',
      'Bentuk lengkungan huruf C dengan jari telunjuk dan ibu jari tangan kanan.',
      'Tempelkan ujung lengkungan tangan kanan ke sisi tiang jari tangan kiri.',
    ],
    commonMistakes:
        'Lengkungan menghadap ke arah yang terbalik atau tertutup oleh telapak tangan.',
    sortOrder: 4,
  ),
  LetterModel(
    letter: 'E',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description:
        'Menekuk jari-jari satu tangan ke arah dalam membentuk kontur huruf E.',
    stepByStepGuides: const [
      'Hadapkan telapak tangan ke arah kamera.',
      'Tekuk keempat jari bagian atas ke arah tengah telapak tangan.',
      'Lipat ibu jari di bagian bawah menyentuh ujung jari atau melintang di depan telapak.',
    ],
    commonMistakes:
        'Kepalan tangan tertutup terlalu rapat seperti tinju penuh.',
    sortOrder: 5,
  ),
  LetterModel(
    letter: 'F',
    handCount: 2,
    difficulty: LetterDifficulty.easy,
    description:
        'Menyilangkan atau menempelkan jari dari kedua tangan membentuk palang huruf F.',
    stepByStepGuides: const [
      'Tegakkan jari telunjuk tangan non-dominan sebagai tiang vertikal.',
      'Rapatkan jari telunjuk dan jari tengah tangan dominan secara horizontal.',
      'Tempelkan kedua jari horizontal tersebut pada bagian atas tiang vertikal.',
    ],
    commonMistakes:
        'Hanya menggunakan satu jari horizontal sehingga menyerupai huruf T.',
    sortOrder: 6,
  ),
  LetterModel(
    letter: 'G',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description: 'Membentuk lengkungan huruf G dengan kombinasi kedua tangan.',
    stepByStepGuides: const [
      'Bentuk lengkungan huruf C pada tangan kiri.',
      'Arahkan jari telunjuk atau kepalan tangan kanan di ujung bawah lengkungan.',
      'Jaga agar kedua tangan berada pada bidang yang sejajar terhadap kamera.',
    ],
    commonMistakes:
        'Sudut tangan terlalu miring sehingga lengkungan C tidak terlihat oleh kamera.',
    sortOrder: 7,
  ),
  LetterModel(
    letter: 'H',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Membentuk dua tiang sejajar dengan garis penghubung di tengah seperti huruf H.',
    stepByStepGuides: const [
      'Tegakkan jari pada kedua tangan atau kombinasikan jari vertikal dan penghubung horizontal.',
      'Hubungkan bagian tengah kedua tiang sehingga siluet huruf H terlihat jelas.',
    ],
    commonMistakes:
        'Jarak kedua tangan terlalu jauh sehingga tidak terbaca sebagai satu kesatuan gestur H.',
    sortOrder: 8,
  ),
  LetterModel(
    letter: 'I',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description: 'Menegakkan jari kelingking ke atas menggunakan satu tangan.',
    stepByStepGuides: const [
      'Kepalkan jari telunjuk, jari tengah, dan jari manis ke arah telapak tangan.',
      'Kunci dengan ibu jari di bagian depan.',
      'Tegakkan jari kelingking lurus ke atas.',
    ],
    commonMistakes:
        'Jari manis ikut terangkat sebagian sehingga bentuk kelingking tidak tegas.',
    sortOrder: 9,
  ),
  LetterModel(
    letter: 'J',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description:
        'Menampilkan posisi akhir kurva huruf J dengan jari kelingking satu tangan.',
    stepByStepGuides: const [
      'Mulai dari bentuk jari kelingking tegak seperti huruf I.',
      'Arahkan kemiringan tangan/kelingking membentuk kait bawah huruf J secara statis.',
    ],
    commonMistakes:
        'Menggerakkan tangan terlalu cepat hingga gambar kamera menjadi kabur.',
    sortOrder: 10,
  ),
  LetterModel(
    letter: 'K',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Membentuk tiang vertikal dengan satu tangan dan sudut miring huruf K dengan tangan lainnya.',
    stepByStepGuides: const [
      'Tegakkan jari telunjuk tangan kiri secara lurus vertikal.',
      'Bentuk sudut V menggunakan jari telunjuk dan jari tengah tangan kanan.',
      'Tempelkan pangkal sudut V tersebut pada bagian tengah tiang vertikal tangan kiri.',
    ],
    commonMistakes:
        'Sudut jari telunjuk dan jari tengah tangan kanan terlalu rapat.',
    sortOrder: 11,
  ),
  LetterModel(
    letter: 'L',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description:
        'Membentuk siku-siku 90 derajat seperti huruf L dengan ibu jari dan telunjuk satu tangan.',
    stepByStepGuides: const [
      'Lipat jari tengah, jari manis, dan kelingking ke dalam telapak tangan.',
      'Tegakkan jari telunjuk lurus ke atas.',
      'Rentangkan ibu jari lurus ke samping membentuk sudut siku-siku.',
    ],
    commonMistakes:
        'Ibu jari tidak direntangkan ke samping melainkan menempel di dekat telunjuk.',
    sortOrder: 12,
  ),
  LetterModel(
    letter: 'M',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Menempatkan tiga jari di atas telapak/jari tangan lain untuk membentuk tiga kaki huruf M.',
    stepByStepGuides: const [
      'Buka tiga jari (telunjuk, tengah, manis) pada tangan dominan.',
      'Tempelkan ketiga jari tersebut pada punggung/jari tangan non-dominan membentuk tiga kaki huruf M.',
    ],
    commonMistakes:
        'Hanya menempelkan dua jari sehingga terbaca sebagai huruf N.',
    sortOrder: 13,
  ),
  LetterModel(
    letter: 'N',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Menempatkan dua jari di atas tangan lain untuk membentuk dua kaki huruf N.',
    stepByStepGuides: const [
      'Rapatkan jari telunjuk dan jari tengah pada tangan dominan.',
      'Tempelkan kedua jari tersebut pada tangan non-dominan membentuk siluet huruf N.',
    ],
    commonMistakes: 'Jari manis ikut terbuka sehingga tertukar dengan huruf M.',
    sortOrder: 14,
  ),
  LetterModel(
    letter: 'O',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description:
        'Mempertemukan ujung jari-jari dan ibu jari satu tangan membentuk lingkaran O.',
    stepByStepGuides: const [
      'Lengkungkan keempat jari tangan dominan ke arah depan.',
      'Tempelkan ujung jari telunjuk dan tengah dengan ujung ibu jari membentuk lubang lingkaran O.',
      'Arahkan sisi lubang lingkaran agar terlihat oleh kamera.',
    ],
    commonMistakes: 'Lubang lingkaran tertutup rapat seperti kepalan tangan.',
    sortOrder: 15,
  ),
  LetterModel(
    letter: 'P',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Membentuk tiang vertikal dengan satu tangan dan satu lengkungan atas huruf P dengan tangan lainnya.',
    stepByStepGuides: const [
      'Tegakkan jari telunjuk tangan kiri sebagai tiang vertikal.',
      'Bentuk setengah lingkaran menggunakan jari telunjuk dan ibu jari tangan kanan.',
      'Tempelkan lengkungan tersebut pada bagian atas tiang vertikal tangan kiri.',
    ],
    commonMistakes:
        'Lengkungan ditempelkan terlalu rendah di bagian bawah tiang.',
    sortOrder: 16,
  ),
  LetterModel(
    letter: 'Q',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Membentuk lingkaran dengan satu tangan dan garis ekor huruf Q dengan jari tangan lainnya.',
    stepByStepGuides: const [
      'Bentuk lingkaran huruf O menggunakan salah satu tangan.',
      'Arahkan jari telunjuk tangan lainnya memotong bagian bawah lingkaran sebagai ekor huruf Q.',
    ],
    commonMistakes:
        'Jari ekor menutupi seluruh lingkaran sehingga landmark tangan pertama hilang.',
    sortOrder: 17,
  ),
  LetterModel(
    letter: 'R',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description:
        'Menyilangkan jari tengah di atas jari telunjuk pada satu tangan.',
    stepByStepGuides: const [
      'Lipat jari manis dan kelingking ke telapak tangan dengan ditahan ibu jari.',
      'Angkat jari telunjuk dan jari tengah, lalu silangkan jari tengah dengan jari telunjuk.',
    ],
    commonMistakes:
        'Jari telunjuk dan jari tengah terbuka lebar seperti huruf V.',
    sortOrder: 18,
  ),
  LetterModel(
    letter: 'S',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Mengaitkan lengkungan jari dari kedua tangan membentuk lekukan huruf S.',
    stepByStepGuides: const [
      'Bentuk lengkungan huruf C kecil pada masing-masing tangan.',
      'Kaitkan kedua lengkungan secara berlawanan sehingga membentuk alur huruf S.',
    ],
    commonMistakes:
        'Kedua tangan saling menggenggam rapat hingga jari-jari tidak terlihat.',
    sortOrder: 19,
  ),
  LetterModel(
    letter: 'T',
    handCount: 2,
    difficulty: LetterDifficulty.easy,
    description:
        'Membentuk tiang vertikal dan garis atap horizontal seperti huruf T menggunakan kedua tangan.',
    stepByStepGuides: const [
      'Tegakkan jari telunjuk tangan non-dominan secara vertikal.',
      'Letakkan jari telunjuk atau telapak tangan dominan secara mendatar tepat di atas ujung jari vertikal.',
    ],
    commonMistakes:
        'Garis horizontal berada di tengah tiang sehingga menyerupai tanda tambah.',
    sortOrder: 20,
  ),
  LetterModel(
    letter: 'U',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description:
        'Menegakkan jari telunjuk dan jari tengah secara rapat sejajar ke atas pada satu tangan.',
    stepByStepGuides: const [
      'Lipat jari manis dan jari kelingking ke dalam telapak tangan dan tahan dengan ibu jari.',
      'Tegakkan jari telunjuk dan jari tengah lurus ke atas dalam posisi rapat menyatu.',
    ],
    commonMistakes:
        'Jari telunjuk dan jari tengah merenggang membentuk sudut V.',
    sortOrder: 21,
  ),
  LetterModel(
    letter: 'V',
    handCount: 1,
    difficulty: LetterDifficulty.easy,
    description:
        'Merenggangkan jari telunjuk dan jari tengah membentuk huruf V pada satu tangan.',
    stepByStepGuides: const [
      'Lipat jari manis dan kelingking ke telapak tangan dengan ditahan ibu jari.',
      'Angkat jari telunjuk dan jari tengah lalu buka keduanya membentuk huruf V.',
    ],
    commonMistakes:
        'Jari telunjuk dan jari tengah terlalu rapat sehingga terbaca sebagai huruf U.',
    sortOrder: 22,
  ),
  LetterModel(
    letter: 'W',
    handCount: 2,
    difficulty: LetterDifficulty.medium,
    description:
        'Menggabungkan sudut jari dari kedua tangan membentuk puncak ganda huruf W.',
    stepByStepGuides: const [
      'Bentuk huruf V pada kedua tangan atau rentangkan tiga jari.',
      'Pertemukan sisi dalam kedua tangan sehingga membentuk siluet huruf W yang simetris.',
    ],
    commonMistakes:
        'Posisi salah satu tangan berada jauh di belakang tangan lainnya.',
    sortOrder: 23,
  ),
  LetterModel(
    letter: 'X',
    handCount: 2,
    difficulty: LetterDifficulty.easy,
    description:
        'Menyilangkan kedua jari telunjuk membentuk tanda silang huruf X.',
    stepByStepGuides: const [
      'Kepalkan jari tengah, manis, dan kelingking pada kedua tangan.',
      'Tegakkan jari telunjuk kiri dan kanan.',
      'Silangkan kedua jari telunjuk tepat di bagian tengah membentuk huruf X.',
    ],
    commonMistakes: 'Kedua jari telunjuk hanya sejajar dan tidak bersilangan.',
    sortOrder: 24,
  ),
  LetterModel(
    letter: 'Y',
    handCount: 2,
    difficulty: LetterDifficulty.hard,
    description:
        'Membentuk percabangan huruf Y menggunakan kombinasi jari kedua tangan.',
    stepByStepGuides: const [
      'Bentuk sudut V pada bagian atas dan tiang penopang di bagian bawah menggunakan kombinasi jari.',
      'Tahan posisi secara stabil di tengah bidang kamera.',
    ],
    commonMistakes:
        'Posisi jari miring menjauhi kamera sehingga ujung jari tidak terdeteksi.',
    sortOrder: 25,
  ),
  LetterModel(
    letter: 'Z',
    handCount: 1,
    difficulty: LetterDifficulty.medium,
    description:
        'Membentuk sudut zig-zag huruf Z menggunakan posisi telapak/jari secara tegas di depan kamera.',
    stepByStepGuides: const [
      'Arahkan jari telunjuk atau bidang telapak tangan membentuk sudut patahan huruf Z.',
      'Tahan posisi tangan dengan stabil agar landmark terdeteksi penuh.',
    ],
    commonMistakes:
        'Menggerakkan tangan terlalu cepat keluar dari area bingkai kamera.',
    sortOrder: 26,
  ),
]);

/// Data panduan belajar lokal sebagai fallback offline.
const List<LearningGuideModel> kDefaultLearningGuides = [
  LearningGuideModel(
    slug: 'mengenal-alfabet-bisindo',
    category: 'bisindo_intro',
    title: 'Mengenal Alfabet BISINDO (A–Z)',
    summary:
        'Karakteristik huruf 1 tangan dan 2 tangan pada Bahasa Isyarat Indonesia.',
    content:
        'BISINDO menggunakan kombinasi huruf 1 tangan (C, E, I, J, L, O, R, U, V, Z) dan 2 tangan (A, B, D, F, G, H, K, M, N, P, Q, S, T, W, X, Y).',
    iconKey: 'sign_language',
    sortOrder: 1,
  ),
  LearningGuideModel(
    slug: 'panduan-posisi-kamera',
    category: 'camera_setup',
    title: 'Panduan Framing Kamera & Pencahayaan',
    summary:
        'Cara memposisikan tangan agar pelacakan 21 titik landmark MediaPipe akurat.',
    content:
        'Pastikan sumber cahaya berada di depan Anda dan jaga jarak tangan sekitar 40–70 cm dari kamera.',
    iconKey: 'videocam',
    sortOrder: 2,
  ),
  LearningGuideModel(
    slug: 'tips-prediksi-stabil',
    category: 'practice_tips',
    title: 'Cara Mendapatkan Prediksi Stabil & XP',
    summary:
        'Mengenal cara kerja temporal smoothing saat latihan target huruf.',
    content:
        'Tahan bentuk gestur huruf selama kurang lebih 1 detik hingga indikator stabil terpenuhi untuk memperoleh XP.',
    iconKey: 'tips_and_updates',
    sortOrder: 3,
  ),
];
