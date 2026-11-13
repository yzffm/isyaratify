import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Progress bar linear membulat dengan animasi halus.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.fillColor,
    this.trackColor,
    this.borderRadius = 999,
  });

  /// Nilai antara `0.0` hingga `1.0`.
  final double value;
  final double height;
  final Color? fillColor;
  final Color? trackColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final ext = IsyaratifyColors.of(context);
    final effectiveTrack =
        trackColor ?? Theme.of(context).colorScheme.surfaceContainerHigh;
    final effectiveFill = fillColor ?? ext.headerIndigo;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: double.infinity,
        color: effectiveTrack,
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          widthFactor: clamped,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: effectiveFill,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}
