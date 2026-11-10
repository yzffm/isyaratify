import 'dart:convert';

import '../core/config/app_config.dart';
import '../core/errors/app_exceptions.dart';
import '../models/attempt_model.dart';
import '../models/letter_model.dart';
import '../models/progress_model.dart';
import '../models/quest_model.dart';
import '../platform/http_client_platform.dart';

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.displayName,
    this.accessToken,
    this.refreshToken,
    this.isLocalDemo = false,
  });

  final String userId;
  final String email;
  final String displayName;
  final String? accessToken;
  final String? refreshToken;
  final bool isLocalDemo;
}

/// Service utama untuk komunikasi ke Supabase Auth, PostgREST, dan RPC
/// (`record_practice_attempt`).
class SupabaseService {
  SupabaseService({
    String? supabaseUrl,
    String? publishableKey,
    PlatformHttpClient? httpClient,
  }) : _supabaseUrl = (supabaseUrl ?? AppConfig.supabaseUrl).trim(),
       _publishableKey = (publishableKey ?? AppConfig.supabasePublishableKey)
           .trim(),
       _httpClient = httpClient ?? createPlatformHttpClient();

  final String _supabaseUrl;
  final String _publishableKey;
  final PlatformHttpClient _httpClient;

  AuthSession? _session;

  // State lokal untuk fallback offline/demo agar seluruh fitur tetap responsif.
  UserProgressModel _localProgress = UserProgressModel.empty('demo-user');
  final Map<String, LetterMasteryModel> _localMastery =
      <String, LetterMasteryModel>{};
  final List<PracticeAttemptModel> _localAttempts = <PracticeAttemptModel>[];
  final Map<String, int> _localQuestProgress = <String, int>{};
  final Set<String> _localEarnedBadgeIds = <String>{};

  AuthSession? get currentSession => _session;
  bool get isAuthenticated => _session != null;

  bool get isRemoteConfigured =>
      _supabaseUrl.isNotEmpty &&
      _publishableKey.isNotEmpty &&
      !_supabaseUrl.contains('<project-ref>');

  bool get _canCallRemoteWithAuth =>
      isRemoteConfigured &&
      _session != null &&
      !_session!.isLocalDemo &&
      (_session!.accessToken?.isNotEmpty ?? false);

  Map<String, String> _buildHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_publishableKey.isNotEmpty) {
      headers['apikey'] = _publishableKey;
    }
    final token = _session?.accessToken;
    if (includeAuth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else if (includeAuth && _publishableKey.startsWith('eyJ')) {
      headers['Authorization'] = 'Bearer $_publishableKey';
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final base = _supabaseUrl.endsWith('/')
        ? _supabaseUrl.substring(0, _supabaseUrl.length - 1)
        : _supabaseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$base$cleanPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  Future<AuthSession> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const ApiException('Email dan kata sandi wajib diisi.');
    }

    if (!isRemoteConfigured) {
      return signInDemo(
        email: normalizedEmail,
        displayName: normalizedEmail.split('@').first,
      );
    }

    final uri = _buildUri('/auth/v1/token', const <String, String>{
      'grant_type': 'password',
    });
    final response = await _httpClient.request(
      method: 'POST',
      uri: uri,
      headers: _buildHeaders(includeAuth: false),
      body: jsonEncode(<String, dynamic>{
        'email': normalizedEmail,
        'password': password,
      }),
    );

    if (!response.isSuccess) {
      throw ApiException(
        _extractErrorMessage(
          response.body,
          fallback: 'Gagal masuk. Periksa kembali email dan kata sandi Anda.',
        ),
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final session = _parseAuthSession(data, fallbackEmail: normalizedEmail);
    _session = session;
    return session;
  }

  Future<AuthSession> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim();
    final cleanName = displayName.trim().isNotEmpty
        ? displayName.trim()
        : normalizedEmail.split('@').first;

    if (normalizedEmail.isEmpty || password.length < 6) {
      throw const ApiException(
        'Masukkan email yang valid dan kata sandi minimal 6 karakter.',
      );
    }

    if (!isRemoteConfigured) {
      return signInDemo(email: normalizedEmail, displayName: cleanName);
    }

    final uri = _buildUri('/auth/v1/signup');
    final response = await _httpClient.request(
      method: 'POST',
      uri: uri,
      headers: _buildHeaders(includeAuth: false),
      body: jsonEncode(<String, dynamic>{
        'email': normalizedEmail,
        'password': password,
        'data': <String, dynamic>{'display_name': cleanName},
      }),
    );

    if (!response.isSuccess) {
      throw ApiException(
        _extractErrorMessage(
          response.body,
          fallback: 'Gagal mendaftarkan akun baru.',
        ),
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['access_token'] is String) {
      final session = _parseAuthSession(data, fallbackEmail: normalizedEmail);
      _session = session;
      return session;
    }

    return signInWithPassword(email: normalizedEmail, password: password);
  }

  AuthSession signInDemo({
    String email = 'demo@isyaratify.local',
    String displayName = 'Pembelajar BISINDO',
  }) {
    final session = AuthSession(
      userId: 'demo-user',
      email: email,
      displayName: displayName,
      isLocalDemo: true,
    );
    _session = session;
    _localProgress = UserProgressModel(
      userId: session.userId,
      xp: _localProgress.xp,
      level: _localProgress.level,
      currentStreak: _localProgress.currentStreak == 0
          ? 1
          : _localProgress.currentStreak,
      lastPracticeDate: DateTime.now(),
      totalAttempts: _localProgress.totalAttempts,
      correctAttempts: _localProgress.correctAttempts,
    );
    return session;
  }

  Future<void> signOut() async {
    if (_canCallRemoteWithAuth) {
      try {
        await _httpClient.request(
          method: 'POST',
          uri: _buildUri('/auth/v1/logout'),
          headers: _buildHeaders(),
        );
      } catch (_) {}
    }
    _session = null;
  }

  Future<List<LetterModel>> fetchLetters() async {
    if (!isRemoteConfigured) {
      return kDefaultBisindoLetters;
    }
    try {
      final uri = _buildUri('/rest/v1/letters', const <String, String>{
        'select': '*',
        'order': 'sort_order.asc',
      });
      final response = await _httpClient.request(
        method: 'GET',
        uri: uri,
        headers: _buildHeaders(includeAuth: _canCallRemoteWithAuth),
      );
      if (!response.isSuccess) {
        return kDefaultBisindoLetters;
      }
      final rows = jsonDecode(response.body) as List<dynamic>;
      if (rows.isEmpty) {
        return kDefaultBisindoLetters;
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(LetterModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return kDefaultBisindoLetters;
    }
  }

  Future<List<LearningGuideModel>> fetchLearningGuides() async {
    if (!isRemoteConfigured) {
      return kDefaultLearningGuides;
    }
    try {
      final uri = _buildUri('/rest/v1/learning_guides', const <String, String>{
        'select': '*',
        'is_published': 'eq.true',
        'order': 'sort_order.asc',
      });
      final response = await _httpClient.request(
        method: 'GET',
        uri: uri,
        headers: _buildHeaders(includeAuth: _canCallRemoteWithAuth),
      );
      if (!response.isSuccess) {
        return kDefaultLearningGuides;
      }
      final rows = jsonDecode(response.body) as List<dynamic>;
      if (rows.isEmpty) {
        return kDefaultLearningGuides;
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(LearningGuideModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return kDefaultLearningGuides;
    }
  }

  Future<UserProgressModel> fetchUserProgress() async {
    final userId = _session?.userId ?? 'demo-user';
    if (!_canCallRemoteWithAuth) {
      return _localProgress;
    }
    try {
      final uri = _buildUri('/rest/v1/user_progress', <String, String>{
        'select': '*',
        'user_id': 'eq.$userId',
        'limit': '1',
      });
      final response = await _httpClient.request(
        method: 'GET',
        uri: uri,
        headers: _buildHeaders(),
      );
      if (!response.isSuccess) {
        return _localProgress;
      }
      final rows = jsonDecode(response.body) as List<dynamic>;
      if (rows.isEmpty) {
        return UserProgressModel.empty(userId);
      }
      final model = UserProgressModel.fromJson(
        rows.first as Map<String, dynamic>,
      );
      _localProgress = model;
      return model;
    } catch (_) {
      return _localProgress;
    }
  }

  Future<Map<String, LetterMasteryModel>> fetchLetterMastery() async {
    final userId = _session?.userId ?? 'demo-user';
    if (!_canCallRemoteWithAuth) {
      return Map<String, LetterMasteryModel>.unmodifiable(_localMastery);
    }
    try {
      final uri = _buildUri('/rest/v1/user_letter_mastery', <String, String>{
        'select': '*',
        'user_id': 'eq.$userId',
      });
      final response = await _httpClient.request(
        method: 'GET',
        uri: uri,
        headers: _buildHeaders(),
      );
      if (!response.isSuccess) {
        return Map<String, LetterMasteryModel>.unmodifiable(_localMastery);
      }
      final rows = jsonDecode(response.body) as List<dynamic>;
      final map = <String, LetterMasteryModel>{};
      for (final item in rows.whereType<Map<String, dynamic>>()) {
        final model = LetterMasteryModel.fromJson(item);
        map[model.letter] = model;
      }
      _localMastery
        ..clear()
        ..addAll(map);
      return Map<String, LetterMasteryModel>.unmodifiable(_localMastery);
    } catch (_) {
      return Map<String, LetterMasteryModel>.unmodifiable(_localMastery);
    }
  }

  Future<List<QuestModel>> fetchQuestsWithCompletion() async {
    final userId = _session?.userId ?? 'demo-user';
    if (!_canCallRemoteWithAuth) {
      return _buildLocalQuests();
    }
    try {
      final questsResp = await _httpClient.request(
        method: 'GET',
        uri: _buildUri('/rest/v1/quests', const <String, String>{
          'select': '*',
          'is_active': 'eq.true',
          'order': 'sort_order.asc',
        }),
        headers: _buildHeaders(),
      );

      final completionsResp = await _httpClient.request(
        method: 'GET',
        uri: _buildUri('/rest/v1/quest_completions', <String, String>{
          'select': '*',
          'user_id': 'eq.$userId',
        }),
        headers: _buildHeaders(),
      );

      if (!questsResp.isSuccess) {
        return _buildLocalQuests();
      }

      final questRows = jsonDecode(questsResp.body) as List<dynamic>;
      final completedQuestIds = <String>{};
      if (completionsResp.isSuccess) {
        final compRows = jsonDecode(completionsResp.body) as List<dynamic>;
        for (final row in compRows.whereType<Map<String, dynamic>>()) {
          final qId = row['quest_id']?.toString() ?? '';
          if (qId.isNotEmpty) {
            completedQuestIds.add(qId);
          }
        }
      }

      return questRows
          .whereType<Map<String, dynamic>>()
          .map((raw) {
            final base = QuestModel.fromJson(raw);
            final done =
                completedQuestIds.contains(base.id) ||
                completedQuestIds.contains(base.code);
            return base.copyWith(
              isCompleted: done,
              currentProgress: done
                  ? base.targetValue
                  : (_localQuestProgress[base.code] ?? 0),
            );
          })
          .toList(growable: false);
    } catch (_) {
      return _buildLocalQuests();
    }
  }

  List<QuestModel> _buildLocalQuests() {
    return kDefaultQuests
        .map((quest) {
          final count = _localQuestProgress[quest.code] ?? 0;
          return quest.copyWith(
            currentProgress: count.clamp(0, quest.targetValue),
            isCompleted: count >= quest.targetValue,
          );
        })
        .toList(growable: false);
  }

  Future<List<BadgeModel>> fetchBadgesWithEarnedStatus() async {
    final userId = _session?.userId ?? 'demo-user';
    if (!_canCallRemoteWithAuth) {
      return kDefaultBadges
          .map(
            (badge) => badge.copyWith(
              isEarned:
                  _localEarnedBadgeIds.contains(badge.id) ||
                  _localEarnedBadgeIds.contains(badge.code),
            ),
          )
          .toList(growable: false);
    }
    try {
      final badgesResp = await _httpClient.request(
        method: 'GET',
        uri: _buildUri('/rest/v1/badges', const <String, String>{
          'select': '*',
        }),
        headers: _buildHeaders(),
      );
      final userBadgesResp = await _httpClient.request(
        method: 'GET',
        uri: _buildUri('/rest/v1/user_badges', <String, String>{
          'select': '*',
          'user_id': 'eq.$userId',
        }),
        headers: _buildHeaders(),
      );

      if (!badgesResp.isSuccess) {
        return kDefaultBadges;
      }

      final earnedMap = <String, DateTime?>{};
      if (userBadgesResp.isSuccess) {
        final ubRows = jsonDecode(userBadgesResp.body) as List<dynamic>;
        for (final row in ubRows.whereType<Map<String, dynamic>>()) {
          final bId = row['badge_id']?.toString() ?? '';
          if (bId.isNotEmpty) {
            earnedMap[bId] = row['earned_at'] != null
                ? DateTime.tryParse(row['earned_at'].toString())
                : DateTime.now();
          }
        }
      }

      final badgeRows = jsonDecode(badgesResp.body) as List<dynamic>;
      return badgeRows
          .whereType<Map<String, dynamic>>()
          .map((raw) {
            final base = BadgeModel.fromJson(raw);
            if (earnedMap.containsKey(base.id)) {
              return base.copyWith(
                isEarned: true,
                earnedAt: earnedMap[base.id],
              );
            }
            return base;
          })
          .toList(growable: false);
    } catch (_) {
      return kDefaultBadges;
    }
  }

  Future<List<LeaderboardEntryModel>> fetchLeaderboard({int limit = 25}) async {
    if (!isRemoteConfigured) {
      return _buildLocalLeaderboard();
    }
    try {
      final uri = _buildUri('/rest/v1/leaderboard_view', <String, String>{
        'select': '*',
        'limit': '$limit',
      });
      final response = await _httpClient.request(
        method: 'GET',
        uri: uri,
        headers: _buildHeaders(includeAuth: _canCallRemoteWithAuth),
      );
      if (!response.isSuccess) {
        return _buildLocalLeaderboard();
      }
      final rows = jsonDecode(response.body) as List<dynamic>;
      if (rows.isEmpty) {
        return _buildLocalLeaderboard();
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(LeaderboardEntryModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return _buildLocalLeaderboard();
    }
  }

  List<LeaderboardEntryModel> _buildLocalLeaderboard() {
    final session = _session;
    return <LeaderboardEntryModel>[
      LeaderboardEntryModel(
        rank: 1,
        userId: session?.userId ?? 'demo-user',
        displayName: session?.displayName ?? 'Pembelajar BISINDO',
        xp: _localProgress.xp,
        level: _localProgress.level,
        currentStreak: _localProgress.currentStreak,
        masteredLettersCount: _localMastery.values
            .where((m) => m.isMastered)
            .length,
      ),
    ];
  }

  Future<List<PracticeAttemptModel>> fetchRecentAttempts({
    int limit = 20,
  }) async {
    final userId = _session?.userId ?? 'demo-user';
    if (!_canCallRemoteWithAuth) {
      return _localAttempts.take(limit).toList(growable: false);
    }
    try {
      final uri = _buildUri('/rest/v1/practice_attempts', <String, String>{
        'select': '*',
        'user_id': 'eq.$userId',
        'order': 'created_at.desc',
        'limit': '$limit',
      });
      final response = await _httpClient.request(
        method: 'GET',
        uri: uri,
        headers: _buildHeaders(),
      );
      if (!response.isSuccess) {
        return _localAttempts.take(limit).toList(growable: false);
      }
      final rows = jsonDecode(response.body) as List<dynamic>;
      return rows
          .whereType<Map<String, dynamic>>()
          .map(PracticeAttemptModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return _localAttempts.take(limit).toList(growable: false);
    }
  }

  Future<AttemptSubmissionResult> recordPracticeAttempt(
    PracticeAttemptModel attempt,
  ) async {
    _localAttempts.insert(0, attempt);

    if (_canCallRemoteWithAuth) {
      try {
        final uri = _buildUri('/rest/v1/rpc/record_practice_attempt');
        final response = await _httpClient.request(
          method: 'POST',
          uri: uri,
          headers: _buildHeaders(),
          body: jsonEncode(attempt.toRpcPayload()),
        );
        if (response.isSuccess) {
          final map = jsonDecode(response.body) as Map<String, dynamic>;
          final result = AttemptSubmissionResult.fromJson(map);
          _localProgress = UserProgressModel(
            userId: _session!.userId,
            xp: result.newXp,
            level: result.newLevel,
            currentStreak: result.currentStreak,
            lastPracticeDate: DateTime.now(),
            totalAttempts: _localProgress.totalAttempts + 1,
            correctAttempts:
                _localProgress.correctAttempts + (attempt.isCorrect ? 1 : 0),
          );
          return result;
        }
      } catch (_) {}
    }

    return _applyLocalAttempt(attempt);
  }

  AttemptSubmissionResult _applyLocalAttempt(PracticeAttemptModel attempt) {
    final xpEarned = attempt.isCorrect
        ? (attempt.targetLetter != null && attempt.targetLetter!.isNotEmpty
              ? 15
              : 10)
        : 2;

    final letterKey = (attempt.targetLetter ?? attempt.predictedLetter)
        .toUpperCase();
    var isMasteredNow = false;

    if (RegExp(r'^[A-Z]$').hasMatch(letterKey)) {
      final prev =
          _localMastery[letterKey] ??
          LetterMasteryModel(
            letter: letterKey,
            totalAttempts: 0,
            correctAttempts: 0,
            bestConfidence: 0.0,
            isMastered: false,
          );
      final nextAttempts = prev.totalAttempts + 1;
      final nextCorrect = prev.correctAttempts + (attempt.isCorrect ? 1 : 0);
      final nextBestConf = attempt.confidence > prev.bestConfidence
          ? attempt.confidence
          : prev.bestConfidence;
      isMasteredNow =
          prev.isMastered || (nextCorrect >= 3 && nextBestConf >= 0.65);

      _localMastery[letterKey] = LetterMasteryModel(
        letter: letterKey,
        totalAttempts: nextAttempts,
        correctAttempts: nextCorrect,
        bestConfidence: nextBestConf,
        isMastered: isMasteredNow,
        lastPracticedAt: DateTime.now(),
      );
    }

    final masteredCount = _localMastery.values
        .where((item) => item.isMastered)
        .length;
    final completedQuests = <CompletedQuestSummary>[];
    var bonusXp = 0;

    for (final quest in kDefaultQuests) {
      final prevCount = _localQuestProgress[quest.code] ?? 0;
      if (prevCount >= quest.targetValue) continue;

      var increment = 0;
      switch (quest.questType) {
        case QuestType.practiceCount:
          increment = 1;
        case QuestType.correctCount:
          if (attempt.isCorrect) increment = 1;
        case QuestType.specificLetters:
          if (attempt.isCorrect && quest.targetLetters.contains(letterKey)) {
            increment = 1;
          }
        case QuestType.twoHandsCorrect:
          final letterMeta = kDefaultBisindoLetters.where(
            (l) => l.letter == letterKey,
          );
          if (attempt.isCorrect &&
              letterMeta.isNotEmpty &&
              letterMeta.first.requiresTwoHands) {
            increment = 1;
          }
        case QuestType.masterLetters:
          if (isMasteredNow) increment = 1;
      }

      if (increment > 0) {
        final nextCount = prevCount + increment;
        _localQuestProgress[quest.code] = nextCount;
        if (nextCount >= quest.targetValue) {
          bonusXp += quest.xpReward;
          completedQuests.add(
            CompletedQuestSummary(
              code: quest.code,
              title: quest.title,
              xpReward: quest.xpReward,
            ),
          );
        }
      }
    }

    final prevLevel = _localProgress.level;
    final nextTotalXp = _localProgress.xp + xpEarned + bonusXp;
    final nextLevel = UserProgressModel.levelForXp(nextTotalXp);
    final nextStreak = _localProgress.currentStreak == 0
        ? 1
        : _localProgress.currentStreak;

    _localProgress = UserProgressModel(
      userId: _session?.userId ?? 'demo-user',
      xp: nextTotalXp,
      level: nextLevel,
      currentStreak: nextStreak,
      lastPracticeDate: DateTime.now(),
      totalAttempts: _localProgress.totalAttempts + 1,
      correctAttempts:
          _localProgress.correctAttempts + (attempt.isCorrect ? 1 : 0),
    );

    return AttemptSubmissionResult(
      attemptId: attempt.id,
      xpGained: xpEarned,
      questXpGained: bonusXp,
      totalXpGained: xpEarned + bonusXp,
      newXp: nextTotalXp,
      newLevel: nextLevel,
      leveledUp: nextLevel > prevLevel,
      currentStreak: nextStreak,
      isLetterMastered: isMasteredNow,
      masteredLettersCount: masteredCount,
      completedQuests: completedQuests,
      earnedBadges: const <EarnedBadgeSummary>[],
    );
  }

  AuthSession _parseAuthSession(
    Map<String, dynamic> data, {
    required String fallbackEmail,
  }) {
    final userObj = data['user'] as Map<String, dynamic>? ?? data;
    final userMeta =
        userObj['user_metadata'] as Map<String, dynamic>? ?? const {};
    final email = (userObj['email'] as String?) ?? fallbackEmail;
    final displayName =
        (userMeta['display_name'] as String?) ?? email.split('@').first;

    return AuthSession(
      userId: (userObj['id'] as String?) ?? 'unknown-user',
      email: email,
      displayName: displayName,
      accessToken: data['access_token'] as String?,
      refreshToken: data['refresh_token'] as String?,
    );
  }

  String _extractErrorMessage(String rawBody, {required String fallback}) {
    if (rawBody.isEmpty) return fallback;
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final msg =
            decoded['msg'] ??
            decoded['error_description'] ??
            decoded['message'] ??
            decoded['error'];
        if (msg is String && msg.trim().isNotEmpty) {
          return msg.trim();
        }
      }
    } catch (_) {}
    return fallback;
  }

  void dispose() {
    _httpClient.close();
  }
}
