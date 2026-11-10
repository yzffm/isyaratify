/// Jenis misi pembelajaran (`public.quests`).
enum QuestType {
  practiceCount,
  correctCount,
  masterLetters,
  specificLetters,
  twoHandsCorrect;

  static QuestType parse(Object? raw) => switch (raw?.toString()) {
    'practice_count' || 'practiceCount' => QuestType.practiceCount,
    'correct_count' || 'correctCount' => QuestType.correctCount,
    'master_letters' || 'masterLetters' => QuestType.masterLetters,
    'specific_letters' || 'specificLetters' => QuestType.specificLetters,
    'two_hands_correct' || 'twoHandsCorrect' => QuestType.twoHandsCorrect,
    _ => QuestType.correctCount,
  };
}

/// Model satu misi pembelajaran (`public.quests` + status penyelesaian pengguna).
class QuestModel {
  QuestModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.questType,
    required this.targetValue,
    List<String> targetLetters = const [],
    required this.xpReward,
    this.isActive = true,
    this.sortOrder = 1,
    this.isCompleted = false,
    this.completedAt,
    this.currentProgress = 0,
  }) : targetLetters = List.unmodifiable(targetLetters);

  factory QuestModel.fromJson(
    Map<String, Object?> json, {
    bool isCompleted = false,
    DateTime? completedAt,
    int currentProgress = 0,
  }) {
    final rawTarget = json['target_value'] ?? json['targetValue'] ?? 1;
    final rawReward = json['xp_reward'] ?? json['xpReward'] ?? 20;
    final rawSort = json['sort_order'] ?? json['sortOrder'] ?? 1;
    final rawLetters = json['target_letters'] ?? json['targetLetters'];
    final letters = rawLetters is List
        ? rawLetters.map((e) => e.toString().toUpperCase()).toList()
        : const <String>[];
    final targetVal = rawTarget is num && rawTarget > 0 ? rawTarget.toInt() : 1;

    return QuestModel(
      id: (json['id'] ?? json['code'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      questType: QuestType.parse(json['quest_type'] ?? json['questType']),
      targetValue: targetVal,
      targetLetters: letters,
      xpReward: rawReward is num ? rawReward.toInt() : 20,
      isActive: (json['is_active'] ?? json['isActive'] ?? true) == true,
      sortOrder: rawSort is num ? rawSort.toInt() : 1,
      isCompleted: isCompleted,
      completedAt: completedAt,
      currentProgress: isCompleted
          ? targetVal
          : currentProgress.clamp(0, targetVal),
    );
  }

  final String id;
  final String code;
  final String title;
  final String description;
  final QuestType questType;
  final int targetValue;
  final List<String> targetLetters;
  final int xpReward;
  final bool isActive;
  final int sortOrder;
  final bool isCompleted;
  final DateTime? completedAt;
  final int currentProgress;

  double get progressFraction =>
      targetValue <= 0 ? 1.0 : (currentProgress / targetValue).clamp(0.0, 1.0);

  QuestModel copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    int? currentProgress,
  }) => QuestModel(
    id: id,
    code: code,
    title: title,
    description: description,
    questType: questType,
    targetValue: targetValue,
    targetLetters: targetLetters,
    xpReward: xpReward,
    isActive: isActive,
    sortOrder: sortOrder,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt ?? this.completedAt,
    currentProgress: currentProgress ?? this.currentProgress,
  );
}

/// Daftar quest fallback lokal (selaras dengan `supabase/seed/seed.sql`).
final List<QuestModel> kDefaultQuests = List.unmodifiable([
  QuestModel(
    id: 'quest_first_practice',
    code: 'quest_first_practice',
    title: 'Langkah Pertama',
    description:
        'Selesaikan 1 kali percobaan latihan gestur menggunakan kamera.',
    questType: QuestType.practiceCount,
    targetValue: 1,
    xpReward: 25,
    sortOrder: 1,
  ),
  QuestModel(
    id: 'quest_vowels_aiueo',
    code: 'quest_vowels_aiueo',
    title: 'Penguasaan Huruf Vokal',
    description:
        'Peragakan kelima huruf vokal (A, I, U, E, O) dengan benar minimal satu kali.',
    questType: QuestType.specificLetters,
    targetValue: 5,
    targetLetters: const ['A', 'I', 'U', 'E', 'O'],
    xpReward: 50,
    sortOrder: 2,
  ),
  QuestModel(
    id: 'quest_one_hand_basics',
    code: 'quest_one_hand_basics',
    title: 'Gestur Satu Tangan Dasar',
    description: 'Peragakan huruf satu tangan C, L, O, U, dan V dengan benar.',
    questType: QuestType.specificLetters,
    targetValue: 5,
    targetLetters: const ['C', 'L', 'O', 'U', 'V'],
    xpReward: 50,
    sortOrder: 3,
  ),
  QuestModel(
    id: 'quest_two_hands_coord',
    code: 'quest_two_hands_coord',
    title: 'Koordinasi Dua Tangan',
    description: 'Berhasil memperagakan gestur huruf 2 tangan sebanyak 5 kali.',
    questType: QuestType.twoHandsCorrect,
    targetValue: 5,
    xpReward: 60,
    sortOrder: 4,
  ),
  QuestModel(
    id: 'quest_master_5_letters',
    code: 'quest_master_5_letters',
    title: 'Kolektor 5 Huruf',
    description: 'Capai status Mastered pada minimal 5 huruf alfabet BISINDO.',
    questType: QuestType.masterLetters,
    targetValue: 5,
    xpReward: 80,
    sortOrder: 5,
  ),
  QuestModel(
    id: 'quest_master_all_26',
    code: 'quest_master_all_26',
    title: 'Tuntas Alfabet A–Z',
    description: 'Capai status Mastered pada seluruh 26 huruf alfabet BISINDO.',
    questType: QuestType.masterLetters,
    targetValue: 26,
    xpReward: 250,
    sortOrder: 6,
  ),
]);
