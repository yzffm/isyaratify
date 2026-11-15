import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../controllers/dictionary_controller.dart';
import '../../controllers/practice_controller.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
  late final ShowcaseView _showcaseView;
  final GlobalKey _headerTourKey = GlobalKey();
  final GlobalKey _cameraTourKey = GlobalKey();
  final GlobalKey _letterStripTourKey = GlobalKey();
  final GlobalKey _sidebarTourKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(
      blurValue: 1.0,
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        gapBetweenContentAndAction: 12,
      ),
      globalTooltipActions: [
        const TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'Lewati',
          backgroundColor: Colors.transparent,
          textStyle: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Lanjut',
          backgroundColor: AppColors.accentYellow,
          textStyle: TextStyle(
            color: AppColors.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      ],
    );
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
    _showcaseView.unregister();
    _lifecycleListener?.dispose();
    super.dispose();
  }

  void _startTour() {
    _showcaseView.startShowCase([
      _headerTourKey,
      _cameraTourKey,
      _letterStripTourKey,
      _sidebarTourKey,
    ]);
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
        Showcase(
          key: _cameraTourKey,
          title: 'Studio Kamera AI Real-Time',
          description:
              'Posisikan tangan di dalam kotak kamera ini. MediaPipe dan model ML kami mendeteksi 21 koordinat sendi tangan dan mengklasifikasikan gestur.',
          tooltipBackgroundColor: AppColors.primary,
          textColor: Colors.white,
          titleTextStyle: AppTextStyles.headlineSm.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          descTextStyle: AppTextStyles.bodySm.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          targetBorderRadius: BorderRadius.circular(20),
          tooltipBorderRadius: BorderRadius.circular(16),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: PracticeCameraStage(
            controller: c,
            stageHeight: isWide
                ? 420
                : layout == AppLayoutSize.medium
                ? 340
                : 260,
            statusMessage: statusMessage,
          ),
        ),
        const SizedBox(height: 16),
        Showcase(
          key: _letterStripTourKey,
          title: 'Pilihan Cepat Alfabet',
          description:
              'Ketuk salah satu kartu huruf di strip ini untuk langsung beralih ke mode latihan target huruf tersebut.',
          tooltipBackgroundColor: AppColors.primary,
          textColor: Colors.white,
          titleTextStyle: AppTextStyles.headlineSm.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          descTextStyle: AppTextStyles.bodySm.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          targetBorderRadius: BorderRadius.circular(16),
          tooltipBorderRadius: BorderRadius.circular(16),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: PracticeQuickLetterStrip(
            letters: letters,
            selectedTarget: c.targetLetter,
            onSelectTarget: c.setTargetLetter,
          ),
        ),
      ],
    );

    final sidebarColumn = Showcase(
      key: _sidebarTourKey,
      title: 'Panduan Pose & Analisis Hasil',
      description:
          'Amati referensi visual bentuk tangan BISINDO, pantau skor kestabilan prediksi, dan catat progres XP latihanmu.',
      tooltipBackgroundColor: AppColors.primary,
      textColor: Colors.white,
      titleTextStyle: AppTextStyles.headlineSm.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: AppTextStyles.bodySm.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
      ),
      targetBorderRadius: BorderRadius.circular(16),
      tooltipBorderRadius: BorderRadius.circular(16),
      tooltipPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: PracticeAnalysisSidebar(
        controller: c,
        targetMeta: targetMeta,
        onClearTarget: () => c.setTargetLetter(null),
        onOpenDictionary: () {
          final router = GoRouter.maybeOf(context);
          if (router != null) {
            router.push(AppRoutes.dictionary);
          }
        },
      ),
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
                Showcase(
                  key: _headerTourKey,
                  title: 'Status & Mode Latihan',
                  description:
                      'Lihat kesiapan deteksi kamera dan ganti antara Mode Latihan Bebas atau Mode Target alfabet tertentu.',
                  tooltipBackgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  titleTextStyle: AppTextStyles.headlineSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  descTextStyle: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  targetBorderRadius: BorderRadius.circular(16),
                  tooltipBorderRadius: BorderRadius.circular(16),
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: PracticeStudioHeader(
                    status: c.status,
                    statusMessage: statusMessage,
                    targetLetter: c.targetLetter,
                    letters: letters,
                    onSelectTarget: c.setTargetLetter,
                    onStartTour: _startTour,
                  ),
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
