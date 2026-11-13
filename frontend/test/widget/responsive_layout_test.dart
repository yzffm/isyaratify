import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isyaratify/controllers/auth_controller.dart';
import 'package:isyaratify/controllers/dictionary_controller.dart';
import 'package:isyaratify/controllers/progress_controller.dart';
import 'package:isyaratify/controllers/quest_controller.dart';
import 'package:isyaratify/core/routing/app_routes.dart';
import 'package:isyaratify/core/theme/app_theme.dart';
import 'package:isyaratify/models/attempt_model.dart';
import 'package:isyaratify/models/progress_model.dart';
import 'package:isyaratify/models/quest_model.dart';
import 'package:isyaratify/views/home/dashboard_view.dart';
import 'package:isyaratify/views/leaderboard/leaderboard_view.dart';
import 'package:isyaratify/views/profile/about_us_view.dart';
import 'package:isyaratify/views/profile/profile_view.dart';
import 'package:isyaratify/views/progress/progress_view.dart';
import 'package:isyaratify/views/quest/quest_view.dart';
import 'package:provider/provider.dart';

class _StubAuthController extends ChangeNotifier implements AuthController {
  @override
  bool get isAuthenticated => true;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  String get displayName => 'Pembelajar Uji';

  @override
  String get userEmail => 'uji@example.com';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubQuestController extends ChangeNotifier implements QuestController {
  @override
  List<QuestModel> get quests => [
    QuestModel(
      id: 'q-1',
      code: 'misi_dasar',
      title: 'Misi Huruf A',
      description: 'Berlatih gestur statis huruf A.',
      questType: QuestType.values.first,
      targetValue: 3,
      targetLetters: const ['A'],
      xpReward: 30,
      currentProgress: 1,
    ),
  ];

  @override
  bool get isLoading => false;

  @override
  int get completedCount => 0;

  @override
  int get totalAvailableXp => 30;

  @override
  Future<void> loadQuests() async {}
}

class _StubProgressController extends ChangeNotifier
    implements ProgressController {
  @override
  UserProgressModel get progress => const UserProgressModel(
    userId: 'u-1',
    xp: 120,
    level: 2,
    currentStreak: 3,
  );

  @override
  Map<String, LetterMasteryModel> get mastery => const {
    'A': LetterMasteryModel(
      letter: 'A',
      totalAttempts: 2,
      correctAttempts: 2,
      bestConfidence: 0.9,
      isMastered: true,
    ),
  };

  @override
  List<BadgeModel> get badges => const [
    BadgeModel(
      id: 'b-1',
      code: 'starter',
      title: 'Pemula Aktif',
      description: 'Mulai berlatih huruf BISINDO.',
      iconKey: 'star',
      sortOrder: 1,
      isEarned: true,
    ),
  ];

  @override
  List<LeaderboardEntryModel> get leaderboard => const [];

  @override
  List<PracticeAttemptModel> get recentAttempts => [
    PracticeAttemptModel(
      id: 'at-1',
      userId: 'u-1',
      targetLetter: 'A',
      predictedLetter: 'A',
      confidence: 0.9,
      isCorrect: true,
      inferenceMs: 12,
      platform: 'web',
      createdAt: DateTime(2026, 11, 12, 9, 0),
    ),
  ];

  @override
  bool get isLoading => false;

  @override
  int get masteredLettersCount => 1;

  @override
  int get earnedBadgesCount => 1;

  @override
  Future<void> refreshAll() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _wrapView(Widget child) {
  final wrapped = Material(color: Colors.transparent, child: child);
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => wrapped),
      GoRoute(
        path: AppRoutes.dictionary,
        builder: (_, _) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.practice,
        builder: (_, _) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.quest,
        builder: (_, _) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (_, _) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (_, _) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, _) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (_, _) => const SizedBox.shrink(),
      ),
    ],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>(
        create: (_) => _StubAuthController(),
      ),
      ChangeNotifierProvider<DictionaryController>(
        create: (_) => DictionaryController(),
      ),
      ChangeNotifierProvider<QuestController>(
        create: (_) => _StubQuestController(),
      ),
      ChangeNotifierProvider<ProgressController>(
        create: (_) => _StubProgressController(),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
}

void main() {
  final viewports = <String, Size>{
    'compact 390x844': const Size(390, 844),
    'medium 800x600': const Size(800, 600),
    'desktop 1280x800': const Size(1280, 800),
  };

  final views = <String, Widget>{
    'DashboardView': const DashboardView(),
    'QuestView': const QuestView(),
    'LeaderboardView': const LeaderboardView(),
    'ProfileView': const ProfileView(),
    'ProgressView': const ProgressView(),
    'AboutUsView': const AboutUsView(),
  };

  for (final vp in viewports.entries) {
    testWidgets('Semua halaman utama bebas overflow pada viewport ${vp.key}', (
      tester,
    ) async {
      tester.view.physicalSize = vp.value;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final entry in views.entries) {
        await tester.pumpWidget(_wrapView(entry.value));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.key} gagal atau overflow pada ${vp.key}',
        );
      }
    });
  }
}
