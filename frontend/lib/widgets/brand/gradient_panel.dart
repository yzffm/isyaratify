import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Panel gradien dekoratif merek Isyaratify (dipakai pada kolom kiri Login & Register).
class GradientBrandPanel extends StatelessWidget {
  const GradientBrandPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(40),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerIndigo,
            AppColors.primary,
            AppColors.cameraBackdrop,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentYellow.withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryFixedDim.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
