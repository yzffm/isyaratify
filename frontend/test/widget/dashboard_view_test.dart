import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isyaratify/controllers/auth_controller.dart';
import 'package:isyaratify/controllers/dictionary_controller.dart';
import 'package:isyaratify/controllers/progress_controller.dart';
import 'package:isyaratify/controllers/quest_controller.dart';
import 'package:isyaratify/core/routing/app_routes.dart';
import 'package:isyaratify/core/theme/app_theme.dart';
import 'package:isyaratify/models/letter_model.dart';
import 'package:isyaratify/models/progress_model.dart';
import 'package:isyaratify/models/quest_model.dart';
import 'package:isyaratify/services/supabase_service.dart';
import 'package:isyaratify/views/home/dashboard_view.dart';
import 'package:provider/provider.dart';

class _EmptySupabaseService extends SupabaseService {
  _EmptySupabaseService() : super(supabaseUrl: '', publishableKey: '');

  @override
  Future<List<LetterModel>> fetchLetters() async => const [];

  @override
  Future<List<QuestModel>> fetchQuestsWithCompletion() async => const [];

  @override
  Future<Map<String, LetterMasteryModel>> fetchLetterMastery() async =>
      const {};
}

Widget _buildDashboardTestHarness({required SupabaseService supabaseService}) {
  final auth = AuthController(supabaseService: supabaseService)
    ..signInPlaceholder();
  final dictionary = DictionaryController(supabaseService: supabaseService);
  final progress = ProgressController(supabaseService: supabaseService);
  final quest = QuestController(supabaseService: supabaseService);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: DashboardView()),
      ),
      GoRoute(
        path: AppRoutes.practice,
        builder: (context, state) => const Scaffold(body: Text('Practice Uji')),
      ),
      GoRoute(
        path: AppRoutes.dictionary,
        builder: (context, state) => const Scaffold(body: Text('Kamus Uji')),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const Scaffold(body: Text('About Uji')),
      ),
      GoRoute(
        path: AppRoutes.quest,
        builder: (context, state) => const Scaffold(body: Text('Quest Uji')),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) => const Scaffold(body: Text('Progres Uji')),
      ),
    ],
  );

  return MultiProvider(
    providers: [
      Provider<SupabaseService>.value(value: supabaseService),
      ChangeNotifierProvider<AuthController>.value(value: auth),
      ChangeNotifierProvider<DictionaryController>.value(value: dictionary),
      ChangeNotifierProvider<ProgressController>.value(value: progress),
      ChangeNotifierProvider<QuestController>.value(value: quest),
    ],
    child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
}

void main() {
  testWidgets(
    'DashboardView menampilkan kartu bento lengkap dan BarChart pada desktop',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final supabase = SupabaseService(supabaseUrl: '', publishableKey: '');
      await tester.pumpWidget(
        _buildDashboardTestHarness(supabaseService: supabase),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.textContaining('Halo,'), findsOneWidget);
      expect(find.text('Ringkasan Alfabet BISINDO'), findsOneWidget);
      expect(find.text('Aktivitas Latihan Mingguan'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Misi Harian'), findsOneWidget);
      expect(find.text('Tips Belajar Hari Ini'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('DashboardView menampilkan empty state aman saat data kosong', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildDashboardTestHarness(supabaseService: _EmptySupabaseService()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar Huruf Belum Tersedia'), findsOneWidget);
    expect(find.text('Belum Ada Misi Aktif'), findsOneWidget);
    expect(find.textContaining('Belum ada riwayat sesi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
