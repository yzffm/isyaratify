import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/app.dart';
import 'package:isyaratify/core/errors/app_exceptions.dart';
import 'package:isyaratify/core/routing/app_routes.dart';
import 'package:isyaratify/core/theme/app_colors.dart';
import 'package:isyaratify/core/theme/app_theme.dart';
import 'package:isyaratify/models/hand_landmark_model.dart';
import 'package:isyaratify/services/hand_tracking_service.dart';
import 'package:isyaratify/widgets/shell/app_shell.dart';

class _NoopTrackingService implements HandTrackingService {
  @override
  Future<void> initialize() async =>
      throw const HandTrackingException('Tidak dipakai pada uji shell.');

  @override
  Stream<HandLandmarkFrame> start() => const Stream.empty();

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Widget buildPreview(BuildContext context) => const SizedBox.shrink();
}

void main() {
  test('AppTheme.light menyertakan IsyaratifyColors dan PlusJakartaSans', () {
    final theme = AppTheme.light();
    final ext = theme.extension<IsyaratifyColors>();
    expect(ext, isNotNull);
    expect(ext!.headerIndigo, AppColors.headerIndigo);
    expect(theme.colorScheme.primary, AppColors.primary);
  });

  testWidgets('AppShell menampilkan Sidebar penuh pada layar desktop >= 1100', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const AppShell(
          location: AppRoutes.home,
          child: Center(child: Text('Konten Utama')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Kamus Alfabet'), findsOneWidget);
    expect(find.text('Live Practice'), findsOneWidget);
    expect(find.text('Quest & Tantangan'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Pengaturan / Profil'), findsOneWidget);
    expect(find.text('Tentang Tim Pengembang'), findsOneWidget);
    expect(find.text('TARGET HARIAN'), findsOneWidget);
    expect(find.text('Konten Utama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'AppShell menampilkan NavigationRail pada layar medium (800 px)',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const AppShell(
            location: AppRoutes.home,
            child: Center(child: Text('Konten Tablet')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Konten Tablet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AppShell menampilkan tombol drawer pada layar compact (390 px)',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const AppShell(
            location: AppRoutes.home,
            child: Center(child: Text('Konten Mobile')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Tentang Tim Pengembang'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('IsyaratifyApp memakai AppTheme.light dan dapat memuat /about', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      IsyaratifyApp(handTrackingServiceFactory: _NoopTrackingService.new),
    );
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lanjut (placeholder)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tentang Tim Pengembang'));
    await tester.pumpAndSettle();

    expect(find.text('Visi Produk'), findsOneWidget);
    expect(find.text('Tim Pengembang (7 Anggota)'), findsOneWidget);
  });
}
