import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isyaratify/controllers/auth_controller.dart';
import 'package:isyaratify/controllers/progress_controller.dart';
import 'package:isyaratify/core/routing/app_routes.dart';
import 'package:isyaratify/core/theme/app_theme.dart';
import 'package:isyaratify/models/attempt_model.dart';
import 'package:isyaratify/models/progress_model.dart';
import 'package:isyaratify/views/profile/about_us_view.dart';
import 'package:isyaratify/views/profile/profile_view.dart';
import 'package:isyaratify/views/progress/progress_view.dart';
import 'package:provider/provider.dart';

class _FakeAuthController extends ChangeNotifier implements AuthController {
  @override
  bool get isAuthenticated => true;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  String get displayName => 'Salsabila';

  @override
  String get userEmail => 'salsabila@example.com';

  int signOutCalls = 0;

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    notifyListeners();
  }

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeProgressController extends ChangeNotifier
    implements ProgressController {
  _FakeProgressController({
    required this.progress,
    required this.mastery,
    required this.badges,
    required this.leaderboard,
    required this.recentAttempts,
  });

  @override
  final UserProgressModel progress;

  @override
  final Map<String, LetterMasteryModel> mastery;

  @override
  final List<BadgeModel> badges;

  @override
  final List<LeaderboardEntryModel> leaderboard;

  @override
  final List<PracticeAttemptModel> recentAttempts;

  @override
  bool get isLoading => false;

  @override
  int get masteredLettersCount =>
      mastery.values.where((m) => m.isMastered).length;

  @override
  int get earnedBadgesCount => badges.where((b) => b.isEarned).length;

  @override
  Future<void> refreshAll() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _buildRouterApp({
  required String initialLocation,
  required AuthController authController,
  required ProgressController progressController,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: AppRoutes.profile, builder: (_, _) => const ProfileView()),
      GoRoute(
        path: AppRoutes.progress,
        builder: (_, _) => const ProgressView(),
      ),
      GoRoute(path: AppRoutes.about, builder: (_, _) => const AboutUsView()),
      GoRoute(
        path: AppRoutes.practice,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Practice Page'))),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Leaderboard Page'))),
      ),
    ],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: authController),
      ChangeNotifierProvider<ProgressController>.value(
        value: progressController,
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
}

void main() {
  const progress = UserProgressModel(
    userId: 'u-1',
    xp: 310,
    level: 4,
    currentStreak: 5,
  );

  final sampleAttempts = [
    PracticeAttemptModel(
      id: 'a-1',
      userId: 'u-1',
      targetLetter: 'A',
      predictedLetter: 'A',
      confidence: 0.92,
      isCorrect: true,
      inferenceMs: 14,
      platform: 'web',
      createdAt: DateTime(2026, 11, 12, 10, 30),
    ),
    PracticeAttemptModel(
      id: 'a-2',
      userId: 'u-1',
      targetLetter: 'B',
      predictedLetter: 'C',
      confidence: 0.61,
      isCorrect: false,
      inferenceMs: 15,
      platform: 'web',
      createdAt: DateTime(2026, 11, 12, 10, 32),
    ),
  ];

  const sampleBadges = [
    BadgeModel(
      id: 'b-1',
      code: 'first_try',
      title: 'Langkah Awal',
      description: 'Menyelesaikan latihan pertama.',
      iconKey: 'star',
      sortOrder: 1,
      isEarned: true,
    ),
  ];

  testWidgets(
    'ProfileView menampilkan KPI, tab pengaturan, dialog logout, dan navigasi ke About Us & Progress',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final authCtrl = _FakeAuthController();
      final progressCtrl = _FakeProgressController(
        progress: progress,
        mastery: {
          'A': const LetterMasteryModel(
            letter: 'A',
            totalAttempts: 3,
            correctAttempts: 3,
            bestConfidence: 0.94,
            isMastered: true,
          ),
        },
        badges: sampleBadges,
        leaderboard: const [],
        recentAttempts: sampleAttempts,
      );

      await tester.pumpWidget(
        _buildRouterApp(
          initialLocation: AppRoutes.profile,
          authController: authCtrl,
          progressController: progressCtrl,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Salsabila'), findsOneWidget);
      expect(find.text('5 hari'), findsOneWidget);
      expect(find.text('310 XP'), findsOneWidget);
      expect(find.text('1 / 26'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      // Pindah tab pengaturan ke Akun & Keamanan.
      final accountTab = find.text('Akun & Keamanan');
      await tester.ensureVisible(accountTab);
      await tester.pumpAndSettle();
      await tester.tap(accountTab);
      await tester.pumpAndSettle();
      expect(find.text('Privasi Data & Row Level Security'), findsOneWidget);

      // Uji dialog konfirmasi Logout.
      final logoutBtn = find.text('Keluar Sesi (Logout)');
      await tester.ensureVisible(logoutBtn);
      await tester.pumpAndSettle();
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();
      expect(find.text('Keluar dari Isyaratify?'), findsOneWidget);

      await tester.tap(find.text('Ya, Keluar'));
      await tester.pumpAndSettle();
      expect(authCtrl.signOutCalls, 1);

      // Navigasi ke About Us melalui CTA Tentang Isyaratify.
      final aboutBtn = find.text('Tentang Isyaratify');
      await tester.ensureVisible(aboutBtn);
      await tester.pumpAndSettle();
      await tester.tap(aboutBtn);
      await tester.pumpAndSettle();
      expect(find.text('Visi Produk'), findsOneWidget);
      expect(find.text('Yusuf Maulana'), findsOneWidget);
    },
  );

  testWidgets(
    'ProgressView menampilkan peta huruf A-Z dan pergantian tab Riwayat, Lencana, Leaderboard',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final progressCtrl = _FakeProgressController(
        progress: progress,
        mastery: {
          'A': const LetterMasteryModel(
            letter: 'A',
            totalAttempts: 4,
            correctAttempts: 4,
            bestConfidence: 0.95,
            isMastered: true,
          ),
        },
        badges: sampleBadges,
        leaderboard: const [
          LeaderboardEntryModel(
            rank: 1,
            userId: 'u-1',
            username: 'salsa',
            displayName: 'Salsabila',
            xp: 310,
            level: 4,
            currentStreak: 5,
            masteredLettersCount: 1,
          ),
        ],
        recentAttempts: sampleAttempts,
      );

      await tester.pumpWidget(
        _buildRouterApp(
          initialLocation: AppRoutes.progress,
          authController: _FakeAuthController(),
          progressController: progressCtrl,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Progres Belajar Alfabet'), findsOneWidget);
      expect(find.text('Peta Penguasaan Alfabet A–Z'), findsOneWidget);
      expect(find.text('Target A • Prediksi A'), findsOneWidget);

      final badgeTab = find.text('Lencana');
      await tester.ensureVisible(badgeTab);
      await tester.pumpAndSettle();
      await tester.tap(badgeTab);
      await tester.pumpAndSettle();
      expect(find.text('Langkah Awal'), findsOneWidget);

      final leaderboardTab = find.text('Leaderboard');
      await tester.ensureVisible(leaderboardTab);
      await tester.pumpAndSettle();
      await tester.tap(leaderboardTab);
      await tester.pumpAndSettle();
      expect(find.text('Salsabila'), findsOneWidget);
    },
  );

  testWidgets(
    'AboutUsView menampilkan visi produk, 7 anggota tim, dan footer resmi',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const AboutUsView()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Visi Produk'), findsOneWidget);
      expect(find.text('Tim Pengembang (7 Anggota)'), findsOneWidget);
      expect(find.text('Yusuf Maulana'), findsOneWidget);
      expect(find.text('Salsabila'), findsOneWidget);
      expect(find.text('Ayesha'), findsOneWidget);
      expect(find.text('Siska'), findsOneWidget);
      expect(find.text('Wishang'), findsOneWidget);
      expect(find.text('Muhammad Ilham'), findsOneWidget);
      expect(find.text('Ellyka'), findsOneWidget);
      expect(
        find.text(
          'Isyaratify — Belajar dan berlatih alfabet BISINDO dengan kamera',
        ),
        findsOneWidget,
      );
    },
  );
}
