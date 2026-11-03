import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/practice_controller.dart';
import '../../platform/hand_tracking_platform.dart';
import '../../widgets/placeholder_scaffold.dart';

/// Placeholder practice. Menyiapkan alur lifecycle (initialize/dispose) yang
/// akan dipakai spike kamera + MediaPipe. Belum ada preview kamera.
class PracticeView extends StatelessWidget {
  const PracticeView({super.key, this.controllerFactory});

  /// Untuk test; default memakai service platform.
  final PracticeController Function()? controllerFactory;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PracticeController>(
      create: (_) =>
          (controllerFactory?.call() ??
                PracticeController(createPlatformHandTrackingService()))
            ..initialize(),
      child: const _PracticeBody(),
    );
  }
}

class _PracticeBody extends StatelessWidget {
  const _PracticeBody();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PracticeController>();
    final (icon, text) = switch (c.status) {
      PracticeStatus.idle || PracticeStatus.initializing => (
        Icons.hourglass_top,
        'Menyiapkan pelacakan tangan…',
      ),
      PracticeStatus.ready => (Icons.check_circle, 'Pelacakan tangan siap.'),
      PracticeStatus.unavailable => (
        Icons.info_outline,
        c.message ?? 'Pelacakan tangan belum tersedia.',
      ),
    };
    return PlaceholderScaffold(
      title: 'Latihan',
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Preview kamera dan pengenalan huruf akan ditambahkan pada spike '
          'kamera + MediaPipe.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
