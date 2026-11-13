import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Jenis status semantik untuk [StatusPill].
enum StatusPillTone { success, warning, error, info, neutral }

/// Lencana status yang selalu memadukan ikon dan teks (bukan warna saja).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final StatusPillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (bg, fg, defaultIcon) = switch (tone) {
      StatusPillTone.success => (
        ext.successLight,
        ext.onSuccessContainer,
        Icons.check_circle_outline_rounded,
      ),
      StatusPillTone.warning => (
        ext.accentYellowLight,
        ext.onAccentYellowContainer,
        Icons.schedule_rounded,
      ),
      StatusPillTone.error => (
        ext.feedbackErrorLight,
        scheme.onErrorContainer,
        Icons.error_outline_rounded,
      ),
      StatusPillTone.info => (
        ext.primaryFixed,
        ext.onPrimaryFixed,
        Icons.info_outline_rounded,
      ),
      StatusPillTone.neutral => (
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
        Icons.circle_outlined,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? defaultIcon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
