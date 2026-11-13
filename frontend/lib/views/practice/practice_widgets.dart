import 'package:flutter/material.dart';

import '../../controllers/practice_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/letter_model.dart';
import '../../models/prediction_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/progress_bar.dart';
import '../../widgets/common/status_pill.dart';

/// Header studio Live Practice beserta status koneksi pelacakan dan pilihan mode target.
class PracticeStudioHeader extends StatelessWidget {
  const PracticeStudioHeader({
    super.key,
    required this.status,
    required this.statusMessage,
    required this.targetLetter,
    required this.letters,
    required this.onSelectTarget,
  });

  final PracticeStatus status;
  final String statusMessage;
  final String? targetLetter;
  final List<LetterModel> letters;
  final ValueChanged<String?> onSelectTarget;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isTarget = targetLetter != null;

    final (pillTone, pillLabel, pillIcon) = switch (status) {
      PracticeStatus.idle => (
        StatusPillTone.neutral,
        'Kamera Nonaktif',
        Icons.videocam_outlined,
      ),
      PracticeStatus.initializing => (
        StatusPillTone.warning,
        'Menyiapkan Kamera',
        Icons.hourglass_top_rounded,
      ),
      PracticeStatus.ready => (
        StatusPillTone.success,
        'Pelacakan Lokal Aktif',
        Icons.verified_user_outlined,
      ),
      PracticeStatus.unavailable => (
        StatusPillTone.error,
        'Kamera Belum Siap',
        Icons.videocam_off_outlined,
      ),
    };

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 780;
          final titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusPill(label: pillLabel, tone: pillTone, icon: pillIcon),
                  StatusPill(
                    label: isTarget
                        ? 'Mode Target: Huruf $targetLetter'
                        : 'Mode Latihan Bebas',
                    tone: isTarget
                        ? StatusPillTone.info
                        : StatusPillTone.neutral,
                    icon: isTarget
                        ? Icons.my_location_rounded
                        : Icons.explore_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isTarget
                    ? 'Latihan Target: Huruf $targetLetter'
                    : 'Live Practice BISINDO',
                style: AppTextStyles.headlineLg.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    status == PracticeStatus.ready
                        ? Icons.check_circle_rounded
                        : status == PracticeStatus.unavailable
                        ? Icons.info_outline
                        : status == PracticeStatus.initializing
                        ? Icons.hourglass_top_rounded
                        : Icons.pause_circle_outline_rounded,
                    size: 16,
                    color: status == PracticeStatus.ready
                        ? ext.success
                        : status == PracticeStatus.unavailable
                        ? scheme.error
                        : status == PracticeStatus.initializing
                        ? scheme.secondary
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          final targetPicker = Container(
            width: isWide ? 280 : double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ext.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: targetLetter,
                hint: const Text('Bebas (A–Z)'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Bebas (Semua Huruf A–Z)'),
                  ),
                  ...letters.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item.letter,
                      child: Text(
                        'Huruf ${item.letter} (${item.handCount} tangan)',
                      ),
                    ),
                  ),
                ],
                onChanged: onSelectTarget,
              ),
            ),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [titleBlock, const SizedBox(height: 14), targetPicker],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 16),
              targetPicker,
            ],
          );
        },
      ),
    );
  }
}

/// Panggung pratinjau kamera dengan overlay status tangan, feedback langsung,
/// dan state fallback jika kamera bermasalah atau izin belum diberikan.
class PracticeCameraStage extends StatelessWidget {
  const PracticeCameraStage({
    super.key,
    required this.controller,
    required this.stageHeight,
    required this.statusMessage,
  });

  final PracticeController controller;
  final double stageHeight;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final prediction = controller.latestPrediction;
    final isReady = controller.status == PracticeStatus.ready;
    final hasLowScore = prediction != null && prediction.score < 0.60;

    final String liveBannerText;
    final Color liveBannerColor;
    if (!isReady) {
      liveBannerText = statusMessage;
      liveBannerColor = Colors.white70;
    } else if (!controller.hasAnyHand) {
      liveBannerText = 'Arahkan satu atau dua tangan ke dalam bingkai kamera.';
      liveBannerColor = Colors.white.withValues(alpha: 0.9);
    } else if (prediction == null) {
      liveBannerText = 'Mendeteksi landmark tangan pada bingkai kamera…';
      liveBannerColor = Colors.white.withValues(alpha: 0.9);
    } else if (hasLowScore) {
      liveBannerText =
          'Belum yakin / coba lagi — rapikan posisi tangan & pencahayaan.';
      liveBannerColor = ext.accentYellow;
    } else if (!prediction.isStable) {
      liveBannerText = 'Tahan posisi tangan agar hasil prediksi stabil…';
      liveBannerColor = ext.accentYellow;
    } else {
      liveBannerText = 'Gestur ${prediction.letter} terdeteksi stabil!';
      liveBannerColor = const Color(0xFF6EE7B7);
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: stageHeight,
              color: AppColors.cameraBackdrop,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isReady)
                    controller.buildCameraPreview(context)
                  else
                    _CameraUnavailableOverlay(
                      status: controller.status,
                      recoveryHint: controller.recoveryHint,
                      onRetry: controller.initialize,
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _CameraOverlayPill(
                      icon: Icons.pan_tool_alt_outlined,
                      label:
                          'Tangan terdeteksi: ${controller.detectedHandCount}/2',
                      highlight: controller.hasAnyHand,
                    ),
                  ),
                  if (prediction != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _CameraOverlayPill(
                        icon: prediction.isStable
                            ? Icons.verified_rounded
                            : Icons.timelapse_rounded,
                        label:
                            'Huruf ${prediction.letter} • ${(prediction.score * 100).round()}%',
                        highlight: prediction.isStable,
                      ),
                    ),
                  if (isReady)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              prediction?.isStable == true
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.center_focus_weak_rounded,
                              size: 18,
                              color: liveBannerColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                liveBannerText,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: liveBannerColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Strip pemilihan huruf cepat A–Z di bawah panggung kamera.
class PracticeQuickLetterStrip extends StatelessWidget {
  const PracticeQuickLetterStrip({
    super.key,
    required this.letters,
    required this.selectedTarget,
    required this.onSelectTarget,
  });

  final List<LetterModel> letters;
  final String? selectedTarget;
  final ValueChanged<String?> onSelectTarget;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.keyboard_alt_outlined,
                size: 18,
                color: ext.headerIndigo,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pilih Cepat Target Huruf (A–Z)',
                  style: AppTextStyles.labelLg.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (selectedTarget != null)
                TextButton(
                  onPressed: () => onSelectTarget(null),
                  child: const Text('Mode Bebas'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: letters.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final active = selectedTarget == null;
                  return ChoiceChip(
                    label: const Text('Bebas'),
                    selected: active,
                    onSelected: (_) => onSelectTarget(null),
                  );
                }
                final letter = letters[index - 1];
                final active = selectedTarget == letter.letter;
                return ChoiceChip(
                  label: Text('${letter.letter} (${letter.handCount}T)'),
                  selected: active,
                  onSelected: (_) => onSelectTarget(letter.letter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel kanan Studio Practice berisi panduan huruf target, prediksi real-time,
/// telemetri nyata sesi, kontrol kamera, dan jaminan privasi lokal.
class PracticeAnalysisSidebar extends StatelessWidget {
  const PracticeAnalysisSidebar({
    super.key,
    required this.controller,
    required this.targetMeta,
    required this.onClearTarget,
    required this.onOpenDictionary,
  });

  final PracticeController controller;
  final LetterModel? targetMeta;
  final VoidCallback onClearTarget;
  final VoidCallback onOpenDictionary;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final prediction = controller.latestPrediction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TargetGuideCard(
          targetMeta: targetMeta,
          onClearTarget: onClearTarget,
          onOpenDictionary: onOpenDictionary,
        ),
        const SizedBox(height: 16),
        _LivePredictionCard(
          prediction: prediction,
          targetLetter: controller.targetLetter,
        ),
        const SizedBox(height: 16),
        _SessionTelemetryCard(
          controller: controller,
          inferenceMs: prediction?.inferenceMs,
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kontrol Sesi & Kamera',
                style: AppTextStyles.labelLg.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: 12),
              if (controller.status == PracticeStatus.ready) ...[
                IsyaratifyPrimaryButton(
                  label: 'Periksa & Catat Gestur',
                  icon: Icons.check_circle_outline_rounded,
                  expand: true,
                  onPressed: controller.latestPrediction != null
                      ? () => controller.submitManualCheck(
                          predictedLetter: controller.latestPrediction!.letter,
                          confidence: controller.latestPrediction!.score,
                          inferenceTimeMs:
                              controller.latestPrediction!.inferenceMs ?? 0,
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: controller.stopSession,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Hentikan Kamera'),
                ),
              ] else
                IsyaratifyPrimaryButton(
                  label: 'Mulai / Coba Lagi Kamera',
                  icon: Icons.refresh_rounded,
                  expand: true,
                  onPressed: controller.initialize,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ext.accentYellowLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ext.accentYellow.withValues(alpha: 0.45)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: ext.onAccentYellowContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pemrosesan On-Device: Pelacakan landmark dan klasifikasi gestur berjalan lokal di perangkat Anda. Frame video tidak pernah dikirim ke server.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CameraUnavailableOverlay extends StatelessWidget {
  const _CameraUnavailableOverlay({
    required this.status,
    required this.recoveryHint,
    required this.onRetry,
  });

  final PracticeStatus status;
  final String? recoveryHint;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final isLoading = status == PracticeStatus.initializing;
    final headline = switch (status) {
      PracticeStatus.initializing => 'Mengaktifkan Pratinjau Kamera…',
      PracticeStatus.idle => 'Kamera Sedang Dijeda / Dihentikan',
      PracticeStatus.unavailable => 'Pratinjau Kamera Nonaktif',
      PracticeStatus.ready => 'Kamera Aktif',
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.videocam_off_outlined,
                        size: 30,
                        color: ext.accentYellow,
                      ),
              ),
              const SizedBox(height: 14),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
              ),
              if (recoveryHint != null) ...[
                const SizedBox(height: 8),
                Text(
                  recoveryHint!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(
                    color: ext.accentYellowLight,
                  ),
                ),
              ],
              if (!isLoading) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Aktifkan Kamera'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraOverlayPill extends StatelessWidget {
  const _CameraOverlayPill({
    required this.icon,
    required this.label,
    required this.highlight,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlight
              ? ext.accentYellow.withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight ? ext.accentYellow : Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TargetGuideCard extends StatelessWidget {
  const _TargetGuideCard({
    required this.targetMeta,
    required this.onClearTarget,
    required this.onOpenDictionary,
  });

  final LetterModel? targetMeta;
  final VoidCallback onClearTarget;
  final VoidCallback onOpenDictionary;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (targetMeta == null) {
      return AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gesture_rounded, color: ext.headerIndigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mode Bebas (A–Z)',
                    style: AppTextStyles.headlineSm.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tunjukkan gestur alfabet statis apa saja di depan kamera, atau pilih huruf target dari bilah A–Z untuk latihan terfokus.',
              style: AppTextStyles.bodySm.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onOpenDictionary,
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: const Text('Lihat Referensi Kamus'),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ext.primaryFixed,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  targetMeta!.letter,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: ext.headerIndigo,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target: Huruf ${targetMeta!.letter}',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      targetMeta!.requiresTwoHands
                          ? 'Membutuhkan 2 Tangan'
                          : 'Membutuhkan 1 Tangan',
                      style: AppTextStyles.bodySm.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onClearTarget, child: const Text('Bebas')),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            targetMeta!.description,
            style: AppTextStyles.bodySm.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (targetMeta!.stepByStepGuides.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '• ${targetMeta!.stepByStepGuides.first}',
              style: AppTextStyles.bodySm.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LivePredictionCard extends StatelessWidget {
  const _LivePredictionCard({
    required this.prediction,
    required this.targetLetter,
  });

  final GesturePrediction? prediction;
  final String? targetLetter;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final pct = prediction == null ? 0 : (prediction!.score * 100).round();
    final isLowScore = prediction != null && prediction!.score < 0.60;
    final matchesTarget =
        targetLetter != null &&
        prediction != null &&
        prediction!.letter == targetLetter;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prediction != null
                      ? 'Prediksi: Huruf ${prediction!.letter}'
                      : 'Prediksi: Menunggu gestur tangan…',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (prediction != null)
                StatusPill(
                  label: prediction!.isStable
                      ? 'Stabil'
                      : isLowScore
                      ? 'Belum yakin'
                      : 'Menstabilkan',
                  tone: prediction!.isStable
                      ? StatusPillTone.success
                      : isLowScore
                      ? StatusPillTone.neutral
                      : StatusPillTone.warning,
                  icon: prediction!.isStable
                      ? Icons.verified_rounded
                      : Icons.timelapse_rounded,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor Keyakinan Model',
                style: AppTextStyles.bodySm.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                prediction != null ? '$pct%' : '–',
                style: AppTextStyles.labelLg.copyWith(
                  color: ext.headerIndigo,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppProgressBar(
            value: prediction?.score ?? 0.0,
            fillColor: prediction?.isStable == true
                ? ext.success
                : isLowScore
                ? scheme.outline
                : ext.headerIndigo,
          ),
          const SizedBox(height: 8),
          Text(
            'Skor confidence adalah keluaran classifier lokal (belum melalui kalibrasi probabilitas statistik).',
            style: AppTextStyles.bodySm.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          if (targetLetter != null && prediction != null) ...[
            const SizedBox(height: 10),
            StatusPill(
              label: matchesTarget
                  ? 'Cocok dengan Target $targetLetter'
                  : 'Terbaca ${prediction!.letter} • Target $targetLetter',
              tone: matchesTarget
                  ? StatusPillTone.success
                  : StatusPillTone.warning,
              icon: matchesTarget
                  ? Icons.check_circle_rounded
                  : Icons.compare_arrows_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionTelemetryCard extends StatelessWidget {
  const _SessionTelemetryCard({
    required this.controller,
    required this.inferenceMs,
  });

  final PracticeController controller;
  final int? inferenceMs;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Sesi Nyata',
            style: AppTextStyles.labelLg.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TelemetryStatTile(
                  label: 'Tangan',
                  value: '${controller.detectedHandCount}/2',
                  color: ext.headerIndigo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TelemetryStatTile(
                  label: 'Benar',
                  value:
                      '${controller.sessionCorrect}/${controller.sessionAttempts}',
                  color: ext.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TelemetryStatTile(
                  label: 'XP Sesi',
                  value: '+${controller.sessionXpEarned}',
                  color: ext.onAccentYellowContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TelemetryStatTile(
                  label: 'Inferensi',
                  value: inferenceMs != null ? '${inferenceMs}ms' : '–',
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryStatTile extends StatelessWidget {
  const _TelemetryStatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.labelLg.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
