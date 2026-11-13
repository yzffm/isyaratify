import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../models/team_member_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/status_pill.dart';

/// Halaman Tentang Kami yang memuat visi produk dan profil 7 pengembang Isyaratify.
class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  static const List<TeamMember> _teamMembers = [
    TeamMember(
      name: 'Yusuf Maulana',
      role: 'Project Lead, Requirement, Dokumentasi',
    ),
    TeamMember(name: 'Salsabila', role: 'Flutter UI/UX & Design System'),
    TeamMember(name: 'Ayesha', role: 'Flutter App Logic & State Management'),
    TeamMember(name: 'Siska', role: 'Web Camera & MediaPipe JS'),
    TeamMember(name: 'Wishang', role: 'Android Camera & MediaPipe Native'),
    TeamMember(name: 'Muhammad Ilham', role: 'ML/Data Engineer & Hugging Face'),
    TeamMember(name: 'Ellyka', role: 'Supabase, QA, DevOps'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;
    final isAccent = index % 2 == 0;

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
            child: Text(
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
                Text(
                  member.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
