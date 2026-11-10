import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/dictionary_controller.dart';
import 'controllers/progress_controller.dart';
import 'controllers/quest_controller.dart';
import 'core/constants/app_strings.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'platform/hand_tracking_platform.dart';
import 'services/hand_tracking_service.dart';
import 'services/supabase_service.dart';
import 'services/sync_service.dart';

/// Root aplikasi: menyediakan service dan controller global serta konfigurasi router/tema.
class IsyaratifyApp extends StatefulWidget {
  const IsyaratifyApp({
    super.key,
    this.supabaseService,
    this.authController,
    this.handTrackingServiceFactory = createPlatformHandTrackingService,
  });

  /// Dapat disuntikkan pada test; default membuat instance baru.
  final SupabaseService? supabaseService;

  /// Dapat disuntikkan pada test; default membuat instance baru.
  final AuthController? authController;

  /// Dapat disuntikkan pada test; default memakai service platform.
  final HandTrackingService Function() handTrackingServiceFactory;

  @override
  State<IsyaratifyApp> createState() => _IsyaratifyAppState();
}

class _IsyaratifyAppState extends State<IsyaratifyApp> {
  late final SupabaseService _supabase =
      widget.supabaseService ?? SupabaseService();
  late final SyncService _sync = SyncService(supabaseService: _supabase);
  late final AuthController _auth =
      widget.authController ?? AuthController(supabaseService: _supabase);
  late final DictionaryController _dictionary = DictionaryController(
    supabaseService: _supabase,
  );
  late final QuestController _quest = QuestController(
    supabaseService: _supabase,
  );
  late final ProgressController _progress = ProgressController(
    supabaseService: _supabase,
  );

  late final GoRouter _router = AppRouter.create(
    _auth,
    handTrackingServiceFactory: widget.handTrackingServiceFactory,
  );

  @override
  void dispose() {
    _router.dispose();
    _dictionary.dispose();
    _quest.dispose();
    _progress.dispose();
    if (widget.authController == null) {
      _auth.dispose();
    }
    if (widget.supabaseService == null) {
      _supabase.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: _supabase),
        Provider<SyncService>.value(value: _sync),
        ChangeNotifierProvider<AuthController>.value(value: _auth),
        ChangeNotifierProvider<DictionaryController>.value(value: _dictionary),
        ChangeNotifierProvider<QuestController>.value(value: _quest),
        ChangeNotifierProvider<ProgressController>.value(value: _progress),
      ],
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
