/// Profil publik pengguna (`public.profiles`).
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio = '',
  });

  factory UserProfileModel.fromJson(Map<String, Object?> json) {
    return UserProfileModel(
      id: (json['id'] ?? '').toString(),
      username: json['username']?.toString(),
      displayName: (json['display_name'] ?? json['displayName'] ?? 'Pelajar')
          .toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl'])?.toString(),
      bio: (json['bio'] ?? '').toString(),
    );
  }

  final String id;
  final String? username;
  final String displayName;
  final String? avatarUrl;
  final String bio;

  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

  Map<String, Object?> toJson() => {
    'id': id,
    if (username != null) 'username': username,
    'display_name': displayName,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    'bio': bio,
  };
}

/// Ringkasan XP, level, dan streak pengguna (`public.user_progress`).
class UserProgressModel {
  const UserProgressModel({
    required this.userId,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.lastPracticeDate,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
  });

  factory UserProgressModel.empty(String userId) =>
      UserProgressModel(userId: userId);

  static int levelForXp(int xp) => 1 + ((xp < 0 ? 0 : xp) ~/ 100);

  factory UserProgressModel.fromJson(Map<String, Object?> json) {
    int intField(String key, [int fallback = 0]) {
      final v = json[key];
      return v is num ? v.toInt() : fallback;
    }

    final rawDate = (json['last_practice_date'] ?? json['lastPracticeDate'])
        ?.toString();
    final xp = intField('xp');
    final level = intField('level', 1 + (xp ~/ 100));

    return UserProgressModel(
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      xp: xp,
      level: level < 1 ? 1 : level,
      currentStreak: intField('current_streak'),
      lastPracticeDate: rawDate != null ? DateTime.tryParse(rawDate) : null,
      totalAttempts: intField('total_attempts'),
      correctAttempts: intField('correct_attempts'),
    );
  }

  final String userId;
  final int xp;
  final int level;
  final int currentStreak;
  final DateTime? lastPracticeDate;
  final int totalAttempts;
  final int correctAttempts;

  /// Persentase ketepatan latihan (0..100).
  double get accuracyPct =>
      totalAttempts <= 0 ? 0.0 : (correctAttempts / totalAttempts) * 100.0;

  /// XP di dalam level saat ini (0..99).
  int get xpInCurrentLevel => xp % 100;

  /// Fraksi progres menuju level berikutnya (0.0..1.0).
  double get xpProgressFraction => (xpInCurrentLevel / 100.0).clamp(0.0, 1.0);

  /// Sisa XP untuk naik ke level berikutnya.
  int get xpToNextLevel => 100 - xpInCurrentLevel;
}

/// Statistik penguasaan satu huruf A–Z oleh pengguna (`public.user_letter_mastery`).
class LetterMasteryModel {
  const LetterMasteryModel({
    required this.letter,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    this.bestConfidence = 0.0,
    this.isMastered = false,
    this.lastPracticedAt,
  });

  factory LetterMasteryModel.fromJson(Map<String, Object?> json) {
    final rawTotal = json['total_attempts'] ?? json['totalAttempts'] ?? 0;
    final rawCorrect = json['correct_attempts'] ?? json['correctAttempts'] ?? 0;
    final rawBest = json['best_confidence'] ?? json['bestConfidence'] ?? 0.0;
    final rawLast = (json['last_practiced_at'] ?? json['lastPracticedAt'])
        ?.toString();
    return LetterMasteryModel(
      letter: (json['letter'] ?? 'A').toString().toUpperCase(),
      totalAttempts: rawTotal is num ? rawTotal.toInt() : 0,
      correctAttempts: rawCorrect is num ? rawCorrect.toInt() : 0,
      bestConfidence: rawBest is num ? rawBest.toDouble() : 0.0,
      isMastered: (json['is_mastered'] ?? json['isMastered']) == true,
      lastPracticedAt: rawLast != null ? DateTime.tryParse(rawLast) : null,
    );
  }

  final String letter;
  final int totalAttempts;
  final int correctAttempts;
  final double bestConfidence;
  final bool isMastered;
  final DateTime? lastPracticedAt;

  double get accuracyPct =>
      totalAttempts <= 0 ? 0.0 : (correctAttempts / totalAttempts) * 100.0;
}

/// Satu baris peringkat pada `public.leaderboard_view` (tanpa email).
class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    this.username,
    required this.displayName,
    this.avatarUrl,
    required this.xp,
    required this.level,
    this.currentStreak = 0,
    this.masteredLettersCount = 0,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, Object?> json) {
    int intField(String key, [int fallback = 0]) {
      final v = json[key];
      return v is num ? v.toInt() : fallback;
    }

    return LeaderboardEntryModel(
      rank: intField('rank', 1),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      username: json['username']?.toString(),
      displayName: (json['display_name'] ?? json['displayName'] ?? 'Pelajar')
          .toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl'])?.toString(),
      xp: intField('xp'),
      level: intField('level', 1),
      currentStreak: intField('current_streak'),
      masteredLettersCount: intField('mastered_letters_count'),
    );
  }

  final int rank;
  final String userId;
  final String? username;
  final String displayName;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int currentStreak;
  final int masteredLettersCount;

  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();
}

/// Model lencana pencapaian (`public.badges` + `public.user_badges`).
class BadgeModel {
  const BadgeModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.iconKey = 'emoji_events',
    this.sortOrder = 1,
    this.isEarned = false,
    this.earnedAt,
  });

  factory BadgeModel.fromJson(
    Map<String, Object?> json, {
    bool isEarned = false,
    DateTime? earnedAt,
  }) {
    final rawSort = json['sort_order'] ?? json['sortOrder'] ?? 1;
    return BadgeModel(
      id: (json['id'] ?? json['code'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      iconKey: (json['icon_key'] ?? json['iconKey'] ?? 'emoji_events')
          .toString(),
      sortOrder: rawSort is num ? rawSort.toInt() : 1,
      isEarned: isEarned,
      earnedAt: earnedAt,
    );
  }

  final String id;
  final String code;
  final String title;
  final String description;
  final String iconKey;
  final int sortOrder;
  final bool isEarned;
  final DateTime? earnedAt;

  BadgeModel copyWith({bool? isEarned, DateTime? earnedAt}) => BadgeModel(
    id: id,
    code: code,
    title: title,
    description: description,
    iconKey: iconKey,
    sortOrder: sortOrder,
    isEarned: isEarned ?? this.isEarned,
    earnedAt: earnedAt ?? this.earnedAt,
  );
}

/// Daftar badge fallback lokal (selaras dengan `supabase/seed/seed.sql`).
const List<BadgeModel> kDefaultBadges = [
  BadgeModel(
    id: 'first_step',
    code: 'first_step',
    title: 'Langkah Pertama',
    description: 'Berhasil mengenali huruf BISINDO pertama melalui kamera.',
    iconKey: 'waving_hand',
    sortOrder: 1,
  ),
  BadgeModel(
    id: 'vowel_explorer',
    code: 'vowel_explorer',
    title: 'Penjelajah Vokal',
    description: 'Berhasil memperagakan seluruh huruf vokal A, I, U, E, dan O.',
    iconKey: 'record_voice_over',
    sortOrder: 2,
  ),
  BadgeModel(
    id: 'two_hands_adept',
    code: 'two_hands_adept',
    title: 'Terampil Dua Tangan',
    description: 'Berhasil menyelesaikan 5 latihan huruf BISINDO dua tangan.',
    iconKey: 'pan_tool',
    sortOrder: 3,
  ),
  BadgeModel(
    id: 'alphabet_scholar',
    code: 'alphabet_scholar',
    title: 'Pelajar Tekun (10 Huruf)',
    description: 'Menguasai (Mastered) minimal 10 huruf alfabet BISINDO.',
    iconKey: 'school',
    sortOrder: 4,
  ),
  BadgeModel(
    id: 'bisindo_master',
    code: 'bisindo_master',
    title: 'Master Alfabet BISINDO',
    description: 'Menguasai seluruh 26 huruf alfabet statis BISINDO A–Z.',
    iconKey: 'workspace_premium',
    sortOrder: 5,
  ),
];
