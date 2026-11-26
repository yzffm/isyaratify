import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../models/team_member_model.dart';
import '../../widgets/brand/brand_logo.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/status_pill.dart';

/// Halaman Tentang Kami yang memuat visi produk dan profil 7 pengembang Isyaratify.
class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  static const List<TeamMember> _teamMembers = [
    TeamMember(
      name: 'Yusuf Maulana',
      role: 'Project Lead, Requirement, Dokumentasi',
      githubUrl: 'https://github.com/yzffm',
    ),
    TeamMember(
      name: 'Salsabila',
      role: 'Flutter UI/UX & Design System',
      githubUrl: 'https://github.com/sllsav',
    ),
    TeamMember(
      name: 'Ayesha',
      role: 'Flutter App Logic & State Management',
      githubUrl: 'https://github.com/ayeshahumayranadrarafianti-png',
    ),
    TeamMember(
      name: 'Siska',
      role: 'Web Camera & MediaPipe JS',
      githubUrl: 'https://github.com/siskanurf11',
    ),
    TeamMember(
      name: 'Wishang',
      role: 'Android Camera & MediaPipe Native',
      githubUrl: 'https://github.com/wsaktih',
    ),
    TeamMember(
      name: 'Muhammad Nur Ilham',
      role: 'ML & Data Engineer',
      // Aktifkan baris di bawah setelah menambahkan foto ke assets/images/ilham.png:
      // imageAsset: 'assets/images/ilham.png',
      githubUrl: 'https://github.com/ilhaammm18',
    ),
    TeamMember(
      name: 'Ellyka',
      role: 'Supabase, QA, DevOps',
      githubUrl: 'https://github.com/ellykaAl',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;
    final layoutSize = AppBreakpoints.of(context);
    final horizontalPad = layoutSize == AppLayoutSize.compact ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: ext.surfaceCanvas,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _VisionHeroCard(memberCount: _teamMembers.length),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Tim Pengembang (${_teamMembers.length} Anggota)',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const StatusPill(
                        label: 'Web & Android • Lokal',
                        tone: StatusPillTone.info,
                        icon: Icons.groups_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 960 ? 3 : (width >= 600 ? 2 : 1);
                      const spacing = 14.0;
                      final cardWidth =
                          (width - spacing * (columns - 1)) / columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (var i = 0; i < _teamMembers.length; i++)
                            SizedBox(
                              width: cardWidth,
                              child: _TeamMemberCard(
                                member: _teamMembers[i],
                                index: i,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: ext.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ext.borderSubtle),
                      ),
                      child: Text(
                        'Isyaratify — Belajar dan berlatih alfabet BISINDO dengan kamera',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VisionHeroCard extends StatelessWidget {
  const _VisionHeroCard({required this.memberCount});

  final int memberCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.headerIndigo, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const BrandLogoBadge(
                size: 38,
                borderRadius: 12,
                padding: 5,
                onDark: true,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: ext.accentYellow,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tentang ${AppStrings.appName}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ext.accentYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'MVP Pengenalan Alfabet Statis A–Z',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ext.accentYellow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Visi Produk',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'Membuat pengalaman belajar alfabet BISINDO yang '
              'interaktif, mudah dicoba, dan memberi umpan balik '
              'langsung melalui kamera.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _ScopeBadge(
                icon: Icons.groups_outlined,
                label: '$memberCount Anggota Pengembang',
              ),
              const _ScopeBadge(
                icon: Icons.privacy_tip_outlined,
                label: 'Kamera & Model On-Device (Tanpa Upload Frame)',
              ),
              const _ScopeBadge(
                icon: Icons.pan_tool_outlined,
                label: 'Fokus Gestur Statis A–Z',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScopeBadge extends StatelessWidget {
  const _ScopeBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({required this.member, required this.index});

  final TeamMember member;
  final int index;

  Future<void> _openGitHubUrl(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format tautan GitHub tidak valid.')),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka tautan: $rawUrl')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka tautan: $rawUrl')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;
    final isAccent = index % 2 == 0;
    final hasImage =
        member.imageAsset != null && member.imageAsset!.trim().isNotEmpty;
    final hasGithub =
        member.githubUrl != null && member.githubUrl!.trim().isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isAccent
                ? ext.primaryFixed
                : ext.accentYellowLight,
            // Untuk mengganti foto profil dengan gambar aset asli (misal:
            // 'assets/images/ilham.png'), isi `imageAsset` pada TeamMember atau
            // ganti `backgroundImage` menjadi:
            // backgroundImage: const AssetImage('assets/images/ilham.png'),
            backgroundImage: hasImage ? AssetImage(member.imageAsset!) : null,
            child: hasImage
                ? null
                : Text(
                    member.initial,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isAccent
                          ? ext.onPrimaryFixed
                          : ext.onAccentYellowContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (hasGithub) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        key: ValueKey('github-btn-${member.name}'),
                        tooltip: 'Buka GitHub ${member.name}',
                        onPressed: () =>
                            _openGitHubUrl(context, member.githubUrl!),
                        style: IconButton.styleFrom(
                          backgroundColor: ext.surfaceCanvas,
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(color: ext.borderSubtle),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(34, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: _GitHubIcon(
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ext.surfaceCanvas,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ext.borderSubtle),
                  ),
                  child: Text(
                    member.role,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
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

/// Ikon vektor GitHub (Octocat) kustom agar tidak bergantung pada paket ikon eksternal.
class _GitHubIcon extends StatelessWidget {
  const _GitHubIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GitHubIconPainter(color: color)),
    );
  }
}

class _GitHubIconPainter extends CustomPainter {
  const _GitHubIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(12 * s, 2 * s)
      ..cubicTo(6.477 * s, 2 * s, 2 * s, 6.484 * s, 2 * s, 12.017 * s)
      ..cubicTo(2 * s, 16.442 * s, 4.865 * s, 20.197 * s, 8.839 * s, 21.521 * s)
      ..cubicTo(9.339 * s, 21.613 * s, 9.521 * s, 21.304 * s, 9.521 * s, 21.038 * s)
      ..cubicTo(9.521 * s, 20.801 * s, 9.512 * s, 20.174 * s, 9.508 * s, 19.342 * s)
      ..cubicTo(6.726 * s, 19.947 * s, 6.139 * s, 17.999 * s, 6.139 * s, 17.999 * s)
      ..cubicTo(5.685 * s, 16.842 * s, 5.029 * s, 16.534 * s, 5.029 * s, 16.534 * s)
      ..cubicTo(4.121 * s, 15.913 * s, 5.098 * s, 15.926 * s, 5.098 * s, 15.926 * s)
      ..cubicTo(6.101 * s, 15.996 * s, 6.629 * s, 16.958 * s, 6.629 * s, 16.958 * s)
      ..cubicTo(7.521 * s, 18.487 * s, 8.97 * s, 18.045 * s, 9.539 * s, 17.789 * s)
      ..cubicTo(9.631 * s, 17.142 * s, 9.889 * s, 16.701 * s, 10.175 * s, 16.451 * s)
      ..cubicTo(7.955 * s, 16.198 * s, 5.62 * s, 15.339 * s, 5.62 * s, 11.503 * s)
      ..cubicTo(5.62 * s, 10.41 * s, 6.01 * s, 9.516 * s, 6.649 * s, 8.816 * s)
      ..cubicTo(6.546 * s, 8.563 * s, 6.203 * s, 7.545 * s, 6.747 * s, 6.167 * s)
      ..cubicTo(6.747 * s, 6.167 * s, 7.586 * s, 5.898 * s, 9.497 * s, 7.194 * s)
      ..cubicTo(10.295 * s, 6.972 * s, 11.15 * s, 6.861 * s, 12 * s, 6.857 * s)
      ..cubicTo(12.85 * s, 6.861 * s, 13.705 * s, 6.972 * s, 14.505 * s, 7.194 * s)
      ..cubicTo(16.414 * s, 5.898 * s, 17.251 * s, 6.167 * s, 17.251 * s, 6.167 * s)
      ..cubicTo(17.797 * s, 7.545 * s, 17.454 * s, 8.563 * s, 17.351 * s, 8.816 * s)
      ..cubicTo(17.992 * s, 9.516 * s, 18.379 * s, 10.41 * s, 18.379 * s, 11.503 * s)
      ..cubicTo(18.379 * s, 15.349 * s, 16.04 * s, 16.195 * s, 13.813 * s, 16.443 * s)
      ..cubicTo(14.172 * s, 16.753 * s, 14.492 * s, 17.365 * s, 14.492 * s, 18.301 * s)
      ..cubicTo(14.492 * s, 19.642 * s, 14.48 * s, 20.724 * s, 14.48 * s, 21.038 * s)
      ..cubicTo(14.48 * s, 21.306 * s, 14.66 * s, 21.618 * s, 15.168 * s, 21.52 * s)
      ..cubicTo(19.138 * s, 20.193 * s, 22 * s, 16.44 * s, 22 * s, 12.017 * s)
      ..cubicTo(22 * s, 6.484 * s, 17.522 * s, 2 * s, 12 * s, 2 * s)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GitHubIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
