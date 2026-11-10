import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/practice_controller.dart';
import '../../models/letter_model.dart';
import '../../platform/hand_tracking_platform.dart';
import '../../services/hand_tracking_service.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
import '../../widgets/placeholder_scaffold.dart';

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
    final theme = Theme.of(context);
    final prediction = c.latestPrediction;

    final (icon, text) = switch (c.status) {
      PracticeStatus.idle || PracticeStatus.initializing => (
        Icons.hourglass_top,
        c.message ?? 'Menyiapkan pelacakan tangan…',
      ),
      PracticeStatus.ready => (Icons.check_circle, 'Pelacakan tangan siap.'),
      PracticeStatus.unavailable => (
        Icons.info_outline,
        c.message ?? 'Pelacakan tangan belum tersedia.',
      ),
    };

    return PlaceholderScaffold(
      title: c.isTargetPractice
          ? 'Latihan Target: Huruf ${c.targetLetter}'
          : 'Latihan',
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
        if (c.recoveryHint != null) ...[
          const SizedBox(height: 8),
          Text(
            c.recoveryHint!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Target huruf: '),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: c.targetLetter,
                hint: const Text('Bebas (A–Z)'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Bebas (Semua Huruf)'),
                  ),
                  ...kDefaultBisindoLetters.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item.letter,
                      child: Text(
                        'Huruf ${item.letter} (${item.handCount} tangan)',
                      ),
                    ),
                  ),
                ],
                onChanged: c.setTargetLetter,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              c.buildCameraPreview(context),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Tangan terdeteksi: ${c.detectedHandCount}/2',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        prediction != null
                            ? 'Prediksi: Huruf ${prediction.letter}'
                            : 'Prediksi: Menunggu gestur tangan…',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (prediction != null)
                      Chip(
                        avatar: Icon(
                          prediction.isStable
                              ? Icons.verified
                              : Icons.timelapse,
                          size: 16,
                        ),
                        label: Text(
                          '${(prediction.score * 100).toStringAsFixed(0)}%',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  prediction == null
                      ? 'Arahkan satu atau dua tangan ke dalam bingkai kamera.'
                      : (prediction.isStable
                            ? 'Gestur ${prediction.letter} terdeteksi stabil!'
                            : 'Tahan posisi tangan agar hasil prediksi stabil…'),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Sesi ini: ${c.sessionCorrect}/${c.sessionAttempts} benar • '
                  '+${c.sessionXpEarned} XP',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (c.status == PracticeStatus.ready)
              OutlinedButton.icon(
                onPressed: c.stopSession,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Hentikan Kamera'),
              )
            else
              FilledButton.icon(
                onPressed: c.initialize,
                icon: const Icon(Icons.refresh),
                label: const Text('Mulai / Coba Lagi Kamera'),
              ),
          ],
        ),
      ],
    );
  }
}
