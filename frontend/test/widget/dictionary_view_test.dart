import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isyaratify/controllers/dictionary_controller.dart';
import 'package:isyaratify/core/routing/app_routes.dart';
import 'package:isyaratify/core/theme/app_theme.dart';
import 'package:isyaratify/services/supabase_service.dart';
import 'package:isyaratify/views/dictionary/dictionary_view.dart';
import 'package:isyaratify/views/dictionary/dictionary_widgets.dart';
import 'package:provider/provider.dart';

Widget _buildDictionaryTestHarness({
  required SupabaseService supabaseService,
  ValueChanged<String>? onNavigatePractice,
}) {
  final dictionary = DictionaryController(supabaseService: supabaseService);

  final router = GoRouter(
    initialLocation: AppRoutes.dictionary,
    routes: [
      GoRoute(
        path: AppRoutes.dictionary,
        builder: (context, state) => const Scaffold(body: DictionaryView()),
      ),
      GoRoute(
        path: AppRoutes.practice,
        builder: (context, state) {
          final target = state.uri.queryParameters['target'] ?? '';
          onNavigatePractice?.call(target);
          return Scaffold(body: Text('Practice Target: $target'));
        },
      ),
    ],
  );

  return MultiProvider(
    providers: [
      Provider<SupabaseService>.value(value: supabaseService),
      ChangeNotifierProvider<DictionaryController>.value(value: dictionary),
    ],
    child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
}

void main() {
  testWidgets(
    'DictionaryView desktop menampilkan grid huruf, panel inspektor, filter, dan reset pencarian',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final supabase = SupabaseService(supabaseUrl: '', publishableKey: '');
      await tester.pumpWidget(
        _buildDictionaryTestHarness(supabaseService: supabase),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kamus Alfabet BISINDO'), findsOneWidget);
      expect(find.textContaining('A–Z'), findsOneWidget);
      expect(find.text('Semua (26)'), findsOneWidget);
      expect(find.text('Latih Huruf A di Kamera'), findsOneWidget);

      final tileB = find.ancestor(
        of: find.text('B'),
        matching: find.byType(DictionaryLetterTile),
      );
      expect(tileB, findsOneWidget);
      await tester.tap(tileB);
      await tester.pumpAndSettle();

      expect(find.text('Latih Huruf B di Kamera'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, '2 Tangan'));
      await tester.pumpAndSettle();
      final tileC = find.ancestor(
        of: find.text('C'),
        matching: find.byType(DictionaryLetterTile),
      );
      expect(tileC, findsNothing);

      await tester.enterText(find.byType(TextField), 'XYZ');
      await tester.pumpAndSettle();
      expect(find.text('Huruf Tidak Ditemukan'), findsOneWidget);

      await tester.ensureVisible(find.text('Reset Filter'));
      await tester.tap(find.text('Reset Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Latih Huruf B di Kamera'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('A'),
          matching: find.byType(DictionaryLetterTile),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DictionaryView layar sempit membuka bottom sheet inspektor dan navigasi ke Practice',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? navigatedTarget;
      final supabase = SupabaseService(supabaseUrl: '', publishableKey: '');
      await tester.pumpWidget(
        _buildDictionaryTestHarness(
          supabaseService: supabase,
          onNavigatePractice: (target) => navigatedTarget = target,
        ),
      );
      await tester.pumpAndSettle();

      // Pada layar < 1100, panel inspektor tidak ditampilkan inline.
      expect(find.text('Latih Huruf A di Kamera'), findsNothing);

      final tileB = find.ancestor(
        of: find.text('B'),
        matching: find.byType(DictionaryLetterTile),
      );
      await tester.ensureVisible(tileB);
      await tester.tap(tileB);
      await tester.pumpAndSettle();

      expect(find.text('Latih Huruf B di Kamera'), findsOneWidget);

      await tester.ensureVisible(find.text('Latih Huruf B di Kamera'));
      await tester.tap(find.text('Latih Huruf B di Kamera'));
      await tester.pumpAndSettle();

      expect(navigatedTarget, 'B');
      expect(find.text('Practice Target: B'), findsOneWidget);
    },
  );
}
