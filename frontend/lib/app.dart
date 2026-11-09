import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'core/constants/app_strings.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'platform/hand_tracking_platform.dart';
import 'services/hand_tracking_service.dart';

/// Root aplikasi: menyediakan controller global dan konfigurasi router/tema.
class IsyaratifyApp extends StatefulWidget {
  const IsyaratifyApp({
    super.key,
    this.authController,
    this.handTrackingServiceFactory = createPlatformHandTrackingService,
  });

  /// Dapat disuntikkan pada test; default membuat instance baru.
  final AuthController? authController;

  /// Dapat disuntikkan pada test; default memakai service platform.
  final HandTrackingService Function() handTrackingServiceFactory;

  @override
  State<IsyaratifyApp> createState() => _IsyaratifyAppState();
}

class _IsyaratifyAppState extends State<IsyaratifyApp> {
  late final AuthController _auth = widget.authController ?? AuthController();
  late final GoRouter _router = AppRouter.create(
    _auth,
    handTrackingServiceFactory: widget.handTrackingServiceFactory,
  );

  @override
  void dispose() {
    _router.dispose();
    if (widget.authController == null) {
      _auth.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<AuthController>.value(value: _auth)],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: _router,
      ),
    );
  }
}
