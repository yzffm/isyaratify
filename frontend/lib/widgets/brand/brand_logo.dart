import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Lencana simbol resmi Isyaratify (buku terbuka ungu + bintang kuning).
class BrandLogoBadge extends StatelessWidget {
  const BrandLogoBadge({
    super.key,
    this.size = 42,
    this.borderRadius = 12,
    this.padding = 6,
    this.onDark = false,
  });

  final double size;
  final double borderRadius;
  final double padding;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.96) : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.35)
              : ext.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: onDark
                ? Colors.black.withValues(alpha: 0.14)
                : ext.headerIndigo.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Image.asset(
        BrandLogo.markAssetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Logo ${AppStrings.appName}',
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.sign_language_rounded,
          color: ext.headerIndigo,
          size: size * 0.56,
        ),
      ),
    );
  }
}

/// Logo merek Isyaratify untuk sidebar maupun panel autentikasi bergradien.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.onDark = false,
    this.subtitle = 'BISINDO AI',
    this.compact = false,
  });

  /// Path aset simbol logo resmi tanpa teks (untuk badge/ikon).
  static const String markAssetPath = 'assets/images/logo_mark.png';

  /// Path aset logo resmi utuh beserta teks "Isyaratify".
  static const String fullAssetPath = 'assets/images/logo_full.png';

  final bool onDark;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    final titleColor = onDark ? Colors.white : scheme.onSurface;
    final subtitleColor = onDark ? ext.primaryFixed : ext.headerIndigo;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandLogoBadge(
          size: compact ? 38 : 42,
          padding: compact ? 5 : 6,
          onDark: onDark,
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
