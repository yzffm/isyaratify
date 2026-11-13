import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isyaratify/controllers/auth_controller.dart';
import 'package:isyaratify/controllers/progress_controller.dart';
import 'package:isyaratify/controllers/quest_controller.dart';
import 'package:isyaratify/core/routing/app_routes.dart';
import 'package:isyaratify/core/theme/app_theme.dart';
import 'package:isyaratify/models/attempt_model.dart';
import 'package:isyaratify/models/progress_model.dart';
import 'package:isyaratify/models/quest_model.dart';
import 'package:isyaratify/views/leaderboard/leaderboard_view.dart';
import 'package:isyaratify/views/quest/quest_view.dart';
import 'package:provider/provider.dart';

class _FakeAuthController extends ChangeNotifier implements AuthController {
  _FakeAuthController({
    this.displayName = 'Budi Santoso',
    this.userEmail = 'budi@example.com',
  });

  @override
  bool get isAuthenticated => true;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  final String displayName;

  @override
  final String userEmail;

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => true;

  @override
  Future<void> signOut() async {}

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeQuestController extends ChangeNotifier implements QuestController {
  _FakeQuestController({required this.quests});

  @override
  List<QuestModel> quests;

  @override
  bool get isLoading => false;

  @override
  int get completedCount => quests.where((q) => q.isCompleted).length;

  @override
  int get totalAvailableXp =>
      quests.fold(0, (sum, quest) => sum + quest.xpReward);

  int loadCalls = 0;

  @override
  Future<void> loadQuests() async {
    loadCalls += 1;
    notifyListeners();
  }
}

class _FakeProgressController extends ChangeNotifier
    implements ProgressController {
  _FakeProgressController({
    required this.progress,
    required this.badges,
    required this.leaderboard,
  });

  @override
  final UserProgressModel progress;

  @override
  Map<String, LetterMasteryModel> get mastery => const {};

  @override
  final List<BadgeModel> badges;

  @override
  final List<LeaderboardEntryModel> leaderboard;

  @override
  List<PracticeAttemptModel> get recentAttempts => const [];

  @override
  bool get isLoading => false;

  @override
  int get masteredLettersCount => 5;

  @override
  int get earnedBadgesCount => badges.where((b) => b.isEarned).length;

  int refreshCalls = 0;

  @override
  Future<void> refreshAll() async {
    refreshCalls += 1;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _wrapWithProviders({
  required Widget home,
  required String initialLocation,
  required AuthController authController,
  required QuestController questController,
  required ProgressController progressController,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: AppRoutes.quest, builder: (_, _) => home),
      GoRoute(path: AppRoutes.leaderboard, builder: (_, _) => home),
      GoRoute(
        path: AppRoutes.practice,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Practice'))),
      ),
    ],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: authController),
      ChangeNotifierProvider<QuestController>.value(value: questController),
      ChangeNotifierProvider<ProgressController>.value(
        value: progressController,
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
}

void main() {
  const defaultProgress = UserProgressModel(
    userId: 'user-1',
    xp: 220,
    level: 3,
    currentStreak: 4,
  );

  final sampleQuests = [
    QuestModel(
      id: 'q1',
      code: 'alpha_start',
      title: 'Latihan Huruf Vokal Dasar',
      description: 'Praktikkan gestur huruf A dan I di kamera.',
      questType: QuestType.values.first,
      targetValue: 2,
      targetLetters: const ['A', 'I'],
      xpReward: 40,
      currentProgress: 1,
      isCompleted: false,
    ),
    QuestModel(
      id: 'q2',
      code: 'first_streak',
      title: 'Konsistensi 3 Hari',
      description: 'Berlatih alfabet BISINDO selama 3 hari berturut-turut.',
      questType: QuestType.values.last,
      targetValue: 3,
      xpReward: 60,
      currentProgress: 3,
      isCompleted: true,
    ),
  ];

  const sampleBadges = [
    BadgeModel(
      id: 'b1',
      code: 'starter',
      title: 'Langkah Pertama',
      description: 'Menyelesaikan sesi latihan pertama.',
      iconKey: 'star',
      sortOrder: 1,
      isEarned: true,
    ),
    BadgeModel(
      id: 'b2',
      code: 'streak_7',
      title: 'Tekun Sepekan',
      description: 'Mencapai 7 hari streak latihan.',
      iconKey: 'streak',
      sortOrder: 2,
      isEarned: false,
    ),
  ];

  testWidgets(
    'QuestView menampilkan hero, filter misi, lencana, dan empty state pada desktop 1280x800',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final questCtrl = _FakeQuestController(quests: sampleQuests);
      final progressCtrl = _FakeProgressController(
        progress: defaultProgress,
        badges: sampleBadges,
        leaderboard: const [],
      );

      await tester.pumpWidget(
        _wrapWithProviders(
          home: const QuestView(),
          initialLocation: AppRoutes.quest,
          authController: _FakeAuthController(),
          questController: questCtrl,
          progressController: progressCtrl,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Tantangan Alfabet BISINDO'), findsOneWidget);
      expect(find.text('Latihan Huruf Vokal Dasar'), findsOneWidget);
      expect(find.text('Konsistensi 3 Hari'), findsOneWidget);
      expect(find.text('Koleksi Lencana'), findsOneWidget);
      expect(find.text('Langkah Pertama'), findsOneWidget);
      expect(find.text('Tekun Sepekan'), findsOneWidget);

      // Filter hanya misi selesai.
      await tester.tap(find.text('Selesai (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Konsistensi 3 Hari'), findsOneWidget);
      expect(find.text('Latihan Huruf Vokal Dasar'), findsNothing);

      // Empty state ketika daftar misi kosong.
      final emptyQuestCtrl = _FakeQuestController(quests: const []);
      await tester.pumpWidget(
        _wrapWithProviders(
          home: const QuestView(),
          initialLocation: AppRoutes.quest,
          authController: _FakeAuthController(),
          questController: emptyQuestCtrl,
          progressController: progressCtrl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada misi aktif'), findsOneWidget);
      expect(find.text('Latihan Bebas'), findsOneWidget);
    },
  );

  testWidgets(
    'LeaderboardView menampilkan podium, disclosure data contoh, menyembunyikan email, dan filter pencarian di 800x600',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final progressCtrl = _FakeProgressController(
        progress: defaultProgress,
        badges: sampleBadges,
        leaderboard: const [
          LeaderboardEntryModel(
            rank: 1,
            userId: 'user-1',
            username: 'budi_bisindo',
            displayName: 'budi@example.com',
            xp: 220,
            level: 3,
            currentStreak: 4,
            masteredLettersCount: 5,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithProviders(
          home: const LeaderboardView(),
          initialLocation: AppRoutes.leaderboard,
          authController: _FakeAuthController(
            displayName: 'budi@example.com',
            userEmail: 'budi@example.com',
          ),
          questController: _FakeQuestController(quests: sampleQuests),
          progressController: progressCtrl,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Papan Peringkat Komunitas'), findsOneWidget);
      expect(find.text('Data contoh lokal'), findsOneWidget);
      expect(find.text('Peringkat Kamu'), findsOneWidget);
      expect(find.text('Podium Teratas'), findsOneWidget);
      expect(find.text('Daftar Lengkap Pembelajar'), findsOneWidget);

      // Pastikan alamat email tidak pernah tampil di UI leaderboard.
      expect(find.textContaining('@'), findsNothing);

      // Uji pencarian pembelajar di daftar lengkap.
      final searchField = find.byType(TextField);
      await tester.ensureVisible(searchField);
      await tester.pumpAndSettle();
      await tester.enterText(searchField, 'Raka');
      await tester.pumpAndSettle();

      expect(find.text('Raka Pratama'), findsWidgets);
      expect(find.text('Dafa Wijaya'), findsNothing);
    },
  );
}
