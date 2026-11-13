import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Logo merek Isyaratify untuk sidebar maupun panel autentikasi bergradien.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.onDark = false,
    this.subtitle = 'BISINDO AI',
    this.compact = false,
  });

  final bool onDark;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    final badgeBg = onDark
        ? Colors.white.withValues(alpha: 0.16)
        : ext.headerIndigo;
    final iconColor = onDark ? ext.accentYellow : AppColors.onPrimary;
    final titleColor = onDark ? Colors.white : scheme.onSurface;
    final subtitleColor = onDark ? ext.primaryFixed : ext.headerIndigo;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 42,
          height: compact ? 38 : 42,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: onDark
                ? null
                : [
                    BoxShadow(
                      color: ext.headerIndigo.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Icon(
            Icons.sign_language_rounded,
            color: iconColor,
            size: compact ? 22 : 24,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSm.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSm.copyWith(
                  color: subtitleColor,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
