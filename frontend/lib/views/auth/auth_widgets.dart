import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/brand/brand_logo.dart';
import '../../widgets/brand/gradient_panel.dart';
import '../../widgets/common/status_pill.dart';

/// Tata letak split 2-kolom pada layar lebar (>= 960 px) dan 1-kolom pada layar sempit.
class AuthSplitLayout extends StatelessWidget {
  const AuthSplitLayout({
    super.key,
    required this.showcase,
    required this.form,
  });

  final Widget showcase;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    return Scaffold(
      backgroundColor: ext.surfaceCanvas,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;
          if (!isWide) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: form,
                  ),
                ),
              ),
            );
          }

          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: GradientBrandPanel(
                    padding: const EdgeInsets.all(40),
                    child: SingleChildScrollView(child: showcase),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: constraints.maxHeight,
                  color: Theme.of(context).colorScheme.surface,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: form,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Konten showcase merek Isyaratify pada kolom kiri halaman Login & Register.
class AuthBrandShowcase extends StatelessWidget {
  const AuthBrandShowcase({
    super.key,
    required this.badgeLabel,
    required this.headline,
    required this.description,
    required this.highlights,
    this.footerNote =
        'Kamera diproses lokal di perangkat tanpa mengirim rekaman video.',
  });

  final String badgeLabel;
  final String headline;
  final String description;
  final List<AuthShowcaseHighlight> highlights;
  final String footerNote;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            const BrandLogo(onDark: true, subtitle: 'BISINDO INTERAKTIF'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeLabel,
                style: AppTextStyles.labelSm.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Text(
          headline,
          style: AppTextStyles.headlineXl.copyWith(
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: AppTextStyles.bodyLg.copyWith(
            color: Colors.white.withValues(alpha: 0.86),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ext.cameraBackdrop,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.front_hand_rounded,
                      color: ext.success,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pelacak 21 Landmark Tangan',
                          style: AppTextStyles.headlineSm.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mendukung evaluasi gestur 1 atau 2 tangan untuk alfabet A–Z BISINDO.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: highlights
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.icon, size: 16, color: ext.accentYellow),
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: AppTextStyles.labelMd.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: ext.primaryFixed,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                footerNote,
                style: AppTextStyles.bodySm.copyWith(
                  color: ext.primaryFixed.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Item fitur ringkas pada panel showcase autentikasi.
class AuthShowcaseHighlight {
  const AuthShowcaseHighlight({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Banner error konsisten untuk halaman Login dan Register.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ext.feedbackErrorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.feedbackError.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySm.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pembungkus label field form dengan gaya Stitch.
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Tombol fitur SSO/Tamu yang dinonaktifkan pada MVP dengan status eksplisit "Segera hadir".
class AuthDisabledActionButton extends StatelessWidget {
  const AuthDisabledActionButton({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMd.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const StatusPill(
            label: 'Segera hadir',
            tone: StatusPillTone.neutral,
            icon: Icons.schedule_rounded,
          ),
        ],
      ),
    );
  }
}
