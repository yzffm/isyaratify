import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/brand/brand_logo.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/status_pill.dart';

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.badge,
    required this.titlePrefix,
    required this.titleAccent,
    required this.description,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.visualIcon,
    required this.visualTag,
    required this.pills,
  });

  final String badge;
  final String titlePrefix;
  final String titleAccent;
  final String description;
  final String primaryLabel;
  final IconData primaryIcon;
  final IconData visualIcon;
  final String visualTag;
  final List<({IconData icon, String title, String desc, StatusPillTone tone})>
  pills;
}

const _slides = <_OnboardingSlideData>[
  _OnboardingSlideData(
    badge: 'BISINDO Interaktif',
    titlePrefix: 'Belajar Isyarat Lebih ',
    titleAccent: 'Seru & Mudah',
    description:
        'Kuasai gestur alfabet BISINDO A–Z langsung dari kameramu dengan panduan visual dan pengenalan lokal di perangkat.',
    primaryLabel: 'Mulai Sekarang',
    primaryIcon: Icons.rocket_launch_rounded,
    visualIcon: Icons.sign_language_rounded,
    visualTag: '26 Alfabet A–Z',
    pills: [
      (
        icon: Icons.videocam_outlined,
        title: 'Latihan Kamera Real-Time',
        desc: 'Panduan gestur tangan interaktif dengan umpan balik langsung',
        tone: StatusPillTone.success,
      ),
      (
        icon: Icons.menu_book_outlined,
        title: 'Kamus Visual A–Z',
        desc: 'Penjelasan bentuk tangan, jumlah tangan, dan kesalahan umum',
        tone: StatusPillTone.warning,
      ),
    ],
  ),
  _OnboardingSlideData(
    badge: 'Pelacakan On-Device',
    titlePrefix: 'Deteksi Kamera ',
    titleAccent: 'Real-Time & Privat',
    description:
        'Pelacakan 21 titik landmark per tangan berjalan lokal di perangkat tanpa mengirim frame video ke server.',
    primaryLabel: 'Lanjut ke Misi',
    primaryIcon: Icons.arrow_forward_rounded,
    visualIcon: Icons.front_hand_rounded,
    visualTag: '21 Titik Landmark',
    pills: [
      (
        icon: Icons.pan_tool_alt_outlined,
        title: 'Dukungan 1 atau 2 Tangan',
        desc: 'Menyesuaikan kebutuhan huruf alfabet BISINDO secara konsisten',
        tone: StatusPillTone.info,
      ),
      (
        icon: Icons.lock_outline_rounded,
        title: 'Privasi Terjaga di Perangkat',
        desc: 'Hanya metadata ringkas hasil latihan yang disinkronkan',
        tone: StatusPillTone.success,
      ),
    ],
  ),
  _OnboardingSlideData(
    badge: 'Gamifikasi & Progres',
    titlePrefix: 'Kuasai 26 Abjad & ',
    titleAccent: 'Kumpulkan XP',
    description:
        'Selesaikan misi latihan harian, kumpulkan XP serta lencana pencapaian, dan pantau konsistensi belajarmu.',
    primaryLabel: 'Masuk untuk Mulai',
    primaryIcon: Icons.celebration_rounded,
    visualIcon: Icons.military_tech_rounded,
    visualTag: 'Quest, XP & Lencana',
    pills: [
      (
        icon: Icons.flag_outlined,
        title: 'Misi Latihan Bertahap',
        desc: 'Target huruf terarah agar latihan lebih terstruktur setiap hari',
        tone: StatusPillTone.info,
      ),
      (
        icon: Icons.leaderboard_outlined,
        title: 'Progres & Papan Peringkat',
        desc: 'Pantau penguasaan tiap huruf dan bandingkan capaian XP',
        tone: StatusPillTone.warning,
      ),
    ],
  ),
];

/// Halaman onboarding interaktif 3 slide sebelum pengguna masuk/mendaftar.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    final target = index.clamp(0, _slides.length - 1);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _handlePrimaryAction() {
    if (_currentPage < _slides.length - 1) {
      _goToPage(_currentPage + 1);
      return;
    }
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: ext.surfaceCard,
                border: Border(bottom: BorderSide(color: ext.borderSubtle)),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Slide sebelumnya',
                    onPressed: _currentPage > 0
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  const SizedBox(width: 4),
                  const BrandLogo(compact: true, subtitle: 'PENGENALAN'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Lewati'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: AppCard(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusPill(
                            label: slide.badge,
                            tone: StatusPillTone.info,
                            icon: Icons.auto_awesome_rounded,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 316,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _slides.length,
                              onPageChanged: (index) {
                                setState(() => _currentPage = index);
                              },
                              itemBuilder: (context, index) {
                                final item = _slides[index];
                                return _OnboardingSlideContent(slide: item);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: _slides.length,
                            onDotClicked: _goToPage,
                            effect: ExpandingDotsEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              expansionFactor: 3,
                              activeDotColor: ext.headerIndigo,
                              dotColor: scheme.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 560;
                              if (isWide) {
                                return Row(
                                  children: [
                                    for (
                                      var i = 0;
                                      i < slide.pills.length;
                                      i++
                                    ) ...[
                                      Expanded(
                                        child: _FeatureHighlightTile(
                                          pill: slide.pills[i],
                                        ),
                                      ),
                                      if (i == 0) const SizedBox(width: 12),
                                    ],
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  for (
                                    var i = 0;
                                    i < slide.pills.length;
                                    i++
                                  ) ...[
                                    _FeatureHighlightTile(pill: slide.pills[i]),
                                    if (i == 0) const SizedBox(height: 10),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: IsyaratifyPrimaryButton(
                                  label: slide.primaryLabel,
                                  icon: slide.primaryIcon,
                                  expand: true,
                                  onPressed: _handlePrimaryAction,
                                ),
                              ),
                              if (_currentPage < _slides.length - 1) ...[
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        _goToPage(_currentPage + 1),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Sudah punya akun?',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go(AppRoutes.login),
                                child: const Text('Masuk di sini'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 14,
                                color: scheme.outline,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Deteksi kamera berjalan lokal di perangkat tanpa mengunggah video',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideContent extends StatelessWidget {
  const _OnboardingSlideContent({required this.slide});

  final _OnboardingSlideData slide;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ext.primaryFixed, scheme.surfaceContainerLow],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: ext.borderSubtle),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ext.headerIndigo.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  slide.visualIcon,
                  size: 40,
                  color: ext.headerIndigo,
                ),
              ),
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: ext.accentYellow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    slide.visualTag,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.headlineLg.copyWith(color: scheme.onSurface),
            children: [
              TextSpan(text: slide.titlePrefix),
              TextSpan(
                text: slide.titleAccent,
                style: TextStyle(color: ext.headerIndigo),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            slide.description,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureHighlightTile extends StatelessWidget {
  const _FeatureHighlightTile({required this.pill});

  final ({IconData icon, String title, String desc, StatusPillTone tone}) pill;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (pill.tone) {
      StatusPillTone.success => (ext.successLight, ext.onSuccessContainer),
      StatusPillTone.warning => (
        ext.accentYellowLight,
        ext.onAccentYellowContainer,
      ),
      _ => (ext.primaryFixed, ext.onPrimaryFixed),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(pill.icon, size: 20, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pill.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pill.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
