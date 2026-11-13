import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Kartu permukaan standar Isyaratify sesuai gaya bento Stitch.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.color,
    this.borderColor,
    this.borderRadius = 24,
    this.onTap,
    this.showBorder = true,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final bgColor = color ?? ext.surfaceCard;
    final radius = BorderRadius.circular(borderRadius);

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: radius, onTap: onTap, child: content),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: showBorder
            ? Border.all(color: borderColor ?? ext.borderSubtle)
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
