import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isyaratify/controllers/auth_controller.dart';
import 'package:isyaratify/core/routing/app_routes.dart';
import 'package:isyaratify/core/theme/app_theme.dart';
import 'package:isyaratify/views/auth/login_view.dart';
import 'package:isyaratify/views/auth/register_view.dart';
import 'package:isyaratify/views/onboarding/onboarding_view.dart';
import 'package:provider/provider.dart';

Widget _buildAuthTestApp({String initialLocation = AppRoutes.onboarding}) {
  final auth = AuthController();
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: Text('Beranda Uji')),
      ),
    ],
  );

  return ChangeNotifierProvider.value(
    value: auth,
    child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
}

void main() {
  testWidgets(
    'OnboardingView 3 slide navigasi berurutan dan Lewati menuju Login',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildAuthTestApp());
      await tester.pumpAndSettle();

      expect(find.text('BISINDO Interaktif'), findsOneWidget);
      await tester.tap(find.text('Mulai Sekarang'));
      await tester.pumpAndSettle();

      expect(find.text('Pelacakan On-Device'), findsOneWidget);
      await tester.tap(find.text('Lanjut ke Misi'));
      await tester.pumpAndSettle();

      expect(find.text('Gamifikasi & Progres'), findsOneWidget);
      await tester.tap(find.text('Lewati'));
      await tester.pumpAndSettle();

      expect(find.text('Selamat Datang Kembali'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('LoginView validasi input, toggle sandi, dan navigasi Register', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildAuthTestApp(initialLocation: AppRoutes.login),
    );
    await tester.pumpAndSettle();

    expect(find.text('Segera hadir'), findsNWidgets(2));

    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(find.text('Kata sandi minimal 6 karakter.'), findsOneWidget);

    await tester.tap(find.byTooltip('Tampilkan kata sandi'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);

    final registerLink = find.text('Daftar gratis di sini');
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();
    expect(find.text('Buat Akun Isyaratify Baru'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'RegisterView memvalidasi form, indikator kekuatan sandi, dan checkbox persetujuan',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildAuthTestApp(initialLocation: AppRoutes.register),
      );
      await tester.pumpAndSettle();

      final passwordField = find.widgetWithText(
        TextFormField,
        'Minimal 6 karakter',
      );
      await tester.enterText(passwordField, 'Abc123!@#XYZ');
      await tester.pumpAndSettle();
      expect(find.text('Kekuatan: Sangat Kuat'), findsOneWidget);

      final cta = find.text('Daftar Sekarang & Mulai Belajar');
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.text('Nama tampilan wajib diisi.'), findsOneWidget);
      expect(find.text('Centang persetujuan terlebih dahulu.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
