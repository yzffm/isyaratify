import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/dictionary_controller.dart';
import '../../controllers/practice_controller.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/letter_model.dart';
import '../../platform/hand_tracking_platform.dart';
import '../../services/hand_tracking_service.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
import 'practice_widgets.dart';

/// Halaman latihan real-time (Live Practice & Target Practice).
class PracticeView extends StatelessWidget {
  const PracticeView({
    super.key,
    this.serviceFactory = createPlatformHandTrackingService,
    this.controllerFactory,
    this.initialTargetLetter,
  });

  /// Factory untuk membuat [HandTrackingService]; default memakai service platform.
  final HandTrackingService Function() serviceFactory;

  /// Untuk test; default memakai [serviceFactory].
  final PracticeController Function()? controllerFactory;

  /// Huruf target opsional untuk mode Target Practice (misal `'A'`).
  final String? initialTargetLetter;

  @override
  Widget build(BuildContext context) {
    final supabase = context.read<SupabaseService?>();
    final sync = context.read<SyncService?>();

    return ChangeNotifierProvider<PracticeController>(
      create: (_) =>
          (controllerFactory?.call() ??
                PracticeController(
                  serviceFactory(),
                  supabaseService: supabase,
                  syncService: sync,
                  initialTargetLetter: initialTargetLetter,
                ))
            ..initialize(),
      child: const _PracticeBody(),
    );
  }
}

class _PracticeBody extends StatefulWidget {
  const _PracticeBody();

  @override
  State<_PracticeBody> createState() => _PracticeBodyState();
}

class _PracticeBodyState extends State<_PracticeBody> {
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onInactive: () {
        if (!mounted) return;
        unawaited(context.read<PracticeController>().pauseForBackground());
      },
      onResume: () {
        if (!mounted) return;
        unawaited(context.read<PracticeController>().resumeFromBackground());
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PracticeController>();
    final dictionary = context.watch<DictionaryController?>();
    final letters = dictionary?.allLetters ?? kDefaultBisindoLetters;
    final ext = IsyaratifyColors.of(context);
    final layout = AppBreakpoints.of(context);
    final isWide = layout == AppLayoutSize.expanded;

    final statusMessage = switch (c.status) {
      PracticeStatus.idle => c.message ?? 'Kamera belum aktif.',
      PracticeStatus.initializing =>
        c.message ?? 'Menyiapkan pelacakan tangan…',
      PracticeStatus.ready => 'Pelacakan tangan siap.',
      PracticeStatus.unavailable =>
        c.message ?? 'Pelacakan tangan belum tersedia.',
    };

    LetterModel? targetMeta;
    if (c.targetLetter != null) {
      for (final item in letters) {
        if (item.letter == c.targetLetter) {
          targetMeta = item;
          break;
        }
      }
    }

    final cameraColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PracticeCameraStage(
          controller: c,
          stageHeight: isWide
              ? 420
              : layout == AppLayoutSize.medium
              ? 340
              : 260,
          statusMessage: statusMessage,
        ),
        const SizedBox(height: 16),
        PracticeQuickLetterStrip(
          letters: letters,
          selectedTarget: c.targetLetter,
          onSelectTarget: c.setTargetLetter,
        ),
      ],
    );

    final sidebarColumn = PracticeAnalysisSidebar(
      controller: c,
      targetMeta: targetMeta,
      onClearTarget: () => c.setTargetLetter(null),
      onOpenDictionary: () {
        final router = GoRouter.maybeOf(context);
        if (router != null) {
          router.push(AppRoutes.dictionary);
        }
      },
    );

    return Scaffold(
      backgroundColor: ext.surfaceCanvas,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(layout == AppLayoutSize.compact ? 16 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.contentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PracticeStudioHeader(
                  status: c.status,
                  statusMessage: statusMessage,
                  targetLetter: c.targetLetter,
                  letters: letters,
                  onSelectTarget: c.setTargetLetter,
                ),
                const SizedBox(height: 20),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: cameraColumn),
                      const SizedBox(width: 20),
                      Expanded(flex: 5, child: sidebarColumn),
                    ],
                  )
                else ...[
                  cameraColumn,
                  const SizedBox(height: 20),
                  sidebarColumn,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
