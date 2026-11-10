/// Model metadata satu percobaan latihan (`public.practice_attempts`).
///
/// Tidak pernah menyimpan gambar atau frame video kamera (`AGENTS.md` §7.3).
class PracticeAttemptModel {
  const PracticeAttemptModel({
    required this.id,
    required this.userId,
    this.targetLetter,
    required this.predictedLetter,
    required this.confidence,
    required this.isCorrect,
    this.inferenceMs,
    this.platform = 'unknown',
    required this.createdAt,
  });

  factory PracticeAttemptModel.fromJson(Map<String, Object?> json) {
    final rawConf = json['confidence'] ?? 0.0;
    final rawMs = json['inference_ms'] ?? json['inferenceMs'];
    final rawCreated = (json['created_at'] ?? json['createdAt'])?.toString();
    return PracticeAttemptModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      targetLetter: (json['target_letter'] ?? json['targetLetter'])?.toString(),
      predictedLetter:
          (json['predicted_letter'] ?? json['predictedLetter'] ?? 'A')
              .toString()
              .toUpperCase(),
      confidence: rawConf is num ? rawConf.toDouble() : 0.0,
      isCorrect: (json['is_correct'] ?? json['isCorrect']) == true,
      inferenceMs: rawMs is num ? rawMs.toInt() : null,
      platform: (json['platform'] ?? 'unknown').toString(),
      createdAt:
          (rawCreated != null ? DateTime.tryParse(rawCreated) : null) ??
          DateTime.now(),
    );
  }

  final String id;
  final String userId;
  final String? targetLetter;
  final String predictedLetter;
  final double confidence;
  final bool isCorrect;
  final int? inferenceMs;
  final String platform;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'user_id': userId,
    'target_letter': targetLetter,
    'predicted_letter': predictedLetter,
    'confidence': confidence,
    'is_correct': isCorrect,
    if (inferenceMs != null) 'inference_ms': inferenceMs,
    'platform': platform,
    'created_at': createdAt.toIso8601String(),
  };

  Map<String, Object?> toRpcPayload() => {
    'p_target_letter': targetLetter,
    'p_predicted_letter': predictedLetter,
    'p_confidence': confidence,
    'p_is_correct': isCorrect,
    'p_inference_ms': inferenceMs,
    'p_platform': platform,
  };
}

/// Ringkasan quest yang baru diselesaikan pada respons RPC `record_practice_attempt`.
class CompletedQuestSummary {
  const CompletedQuestSummary({
    required this.code,
    required this.title,
    required this.xpReward,
  });

  factory CompletedQuestSummary.fromJson(Map<String, Object?> json) {
    final rawReward = json['xp_reward'] ?? json['xpReward'] ?? 0;
    return CompletedQuestSummary(
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      xpReward: rawReward is num ? rawReward.toInt() : 0,
    );
  }

  final String code;
  final String title;
  final int xpReward;
}

/// Ringkasan badge yang baru diperoleh pada respons RPC `record_practice_attempt`.
class EarnedBadgeSummary {
  const EarnedBadgeSummary({
    required this.code,
    required this.title,
    required this.iconKey,
  });

  factory EarnedBadgeSummary.fromJson(Map<String, Object?> json) {
    return EarnedBadgeSummary(
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      iconKey: (json['icon_key'] ?? json['iconKey'] ?? 'emoji_events')
          .toString(),
    );
  }

  final String code;
  final String title;
  final String iconKey;
}

/// Hasil kembalian atomik dari endpoint RPC `record_practice_attempt`.
class AttemptSubmissionResult {
  AttemptSubmissionResult({
    required this.attemptId,
    required this.xpGained,
    required this.questXpGained,
    required this.totalXpGained,
    required this.newXp,
    required this.newLevel,
    required this.leveledUp,
    required this.currentStreak,
    required this.isLetterMastered,
    required this.masteredLettersCount,
    List<CompletedQuestSummary> completedQuests = const [],
    List<EarnedBadgeSummary> earnedBadges = const [],
  }) : completedQuests = List.unmodifiable(completedQuests),
       earnedBadges = List.unmodifiable(earnedBadges);

  factory AttemptSubmissionResult.fromJson(Map<String, Object?> json) {
    int intField(String key, [int fallback = 0]) {
      final v = json[key];
      return v is num ? v.toInt() : fallback;
    }

    final rawQuests = json['completed_quests'];
    final quests = rawQuests is List
        ? rawQuests
              .whereType<Map>()
              .map(
                (m) => CompletedQuestSummary.fromJson(
                  Map<String, Object?>.from(m),
                ),
              )
              .toList()
        : const <CompletedQuestSummary>[];

    final rawBadges = json['earned_badges'];
    final badges = rawBadges is List
        ? rawBadges
              .whereType<Map>()
              .map(
                (m) =>
                    EarnedBadgeSummary.fromJson(Map<String, Object?>.from(m)),
              )
              .toList()
        : const <EarnedBadgeSummary>[];

    final xpGained = intField('xp_gained');
    final questXp = intField('quest_xp_gained');

    return AttemptSubmissionResult(
      attemptId: (json['attempt_id'] ?? '').toString(),
      xpGained: xpGained,
      questXpGained: questXp,
      totalXpGained: intField('total_xp_gained', xpGained + questXp),
      newXp: intField('new_xp'),
      newLevel: intField('new_level', 1),
      leveledUp: json['leveled_up'] == true,
      currentStreak: intField('current_streak', 1),
      isLetterMastered: json['is_letter_mastered'] == true,
      masteredLettersCount: intField('mastered_letters_count'),
      completedQuests: quests,
      earnedBadges: badges,
    );
  }

  final String attemptId;
  final int xpGained;
  final int questXpGained;
  final int totalXpGained;
  final int newXp;
  final int newLevel;
  final bool leveledUp;
  final int currentStreak;
  final bool isLetterMastered;
  final int masteredLettersCount;
  final List<CompletedQuestSummary> completedQuests;
  final List<EarnedBadgeSummary> earnedBadges;
}
