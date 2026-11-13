import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/progress_model.dart';
import '../../models/quest_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/status_pill.dart';

/// Filter status tampilan misi pada halaman [QuestView].
enum QuestFilter { all, active, completed }

/// Banner hero di bagian atas halaman Quest & Badges.
class QuestHeroBanner extends StatelessWidget {
  const QuestHeroBanner({
    super.key,
    required this.progress,
    required this.completedQuestsCount,
    required this.totalQuestsCount,
    required this.earnedBadgesCount,
    required this.totalBadgesCount,
    required this.onStartPractice,
    required this.onOpenLeaderboard,
  });

  final UserProgressModel progress;
  final int completedQuestsCount;
  final int totalQuestsCount;
  final int earnedBadgesCount;
  final int totalBadgesCount;
  final VoidCallback onStartPractice;
  final VoidCallback onOpenLeaderboard;

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
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
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
                      Icons.emoji_events_outlined,
                      size: 16,
                      color: ext.accentYellow,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Misi & Lencana BISINDO',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
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
                  'Level ${progress.level} • ${progress.xp} XP',
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
            'Tantangan Alfabet BISINDO',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              'Selesaikan misi pengenalan gestur huruf statis A–Z melalui latihan kamera lokal untuk mengumpulkan XP dan membuka lencana pencapaian.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroMetricTile(
                icon: Icons.check_circle_outline,
                label: 'Misi Selesai',
                value: '$completedQuestsCount / $totalQuestsCount',
              ),
              _HeroMetricTile(
                icon: Icons.workspace_premium_outlined,
                label: 'Lencana Diraih',
                value: '$earnedBadgesCount / $totalBadgesCount',
              ),
              _HeroMetricTile(
                icon: Icons.local_fire_department_outlined,
                label: 'Streak Aktif',
                value: '${progress.currentStreak} hari',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onStartPractice,
                style: FilledButton.styleFrom(
                  backgroundColor: ext.accentYellow,
                  foregroundColor: ext.onAccentYellowContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.videocam_outlined, size: 18),
                label: const Text(
                  'Mulai Latihan Sekarang',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLeaderboard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.leaderboard_outlined, size: 18),
                label: const Text(
                  'Lihat Papan Peringkat',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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

/// Header + filter chip untuk daftar misi.
class QuestFilterBar extends StatelessWidget {
  const QuestFilterBar({
    super.key,
    required this.selectedFilter,
    required this.totalCount,
    required this.activeCount,
    required this.completedCount,
    required this.onSelectFilter,
    required this.onRefresh,
  });

  final QuestFilter selectedFilter;
  final int totalCount;
  final int activeCount;
  final int completedCount;
  final ValueChanged<QuestFilter> onSelectFilter;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Misi Aktif',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Target latihan bertahap untuk menguasai gestur alfabet A–Z.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text('Semua ($totalCount)'),
              selected: selectedFilter == QuestFilter.all,
              onSelected: (_) => onSelectFilter(QuestFilter.all),
            ),
            ChoiceChip(
              label: Text('Berlangsung ($activeCount)'),
              selected: selectedFilter == QuestFilter.active,
              onSelected: (_) => onSelectFilter(QuestFilter.active),
            ),
            ChoiceChip(
              label: Text('Selesai ($completedCount)'),
              selected: selectedFilter == QuestFilter.completed,
              onSelected: (_) => onSelectFilter(QuestFilter.completed),
            ),
          ],
        ),
      ],
    );
  }
}

/// Kartu detail satu item misi [QuestModel].
class QuestItemCard extends StatelessWidget {
  const QuestItemCard({
    super.key,
    required this.quest,
    required this.onPracticeTap,
  });

  final QuestModel quest;
  final VoidCallback onPracticeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;
    final isDone = quest.isCompleted;
    final progress = quest.progressFraction.clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDone
                      ? ext.successLight
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDone ? Icons.verified_rounded : _iconForQuest(quest),
                  color: isDone ? ext.success : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusPill(
                label: isDone ? 'Selesai' : 'Berlangsung',
                tone: isDone ? StatusPillTone.success : StatusPillTone.info,
                icon: isDone ? Icons.check_circle_outline : Icons.flag_outlined,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: ext.accentYellowLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+${quest.xpReward} XP',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ext.onAccentYellowContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final letter in quest.targetLetters.take(6))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ext.primaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Huruf $letter',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ext.onPrimaryFixed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: ext.borderSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? ext.success : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${quest.currentProgress}/${quest.targetValue}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDone ? ext.success : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (!isDone) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onPracticeTap,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Latih Sekarang'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForQuest(QuestModel quest) {
    final type = quest.questType.name.toLowerCase();
    if (type.contains('streak')) return Icons.local_fire_department_outlined;
    if (type.contains('letter') || quest.targetLetters.isNotEmpty) {
      return Icons.pan_tool_outlined;
    }
    if (type.contains('mastery')) return Icons.auto_awesome_outlined;
    return Icons.flag_outlined;
  }
}

/// Panel lencana pencapaian [BadgeModel] dari ProgressController.
class BadgeShowcasePanel extends StatelessWidget {
  const BadgeShowcasePanel({
    super.key,
    required this.badges,
    required this.earnedCount,
  });

  final List<BadgeModel> badges;
  final int earnedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Koleksi Lencana',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              StatusPill(
                label: '$earnedCount/${badges.length} diraih',
                tone: earnedCount > 0
                    ? StatusPillTone.success
                    : StatusPillTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lencana otomatis terbuka seiring bertambahnya latihan dan penguasaan huruf.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (badges.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Belum ada daftar lencana yang tersedia saat ini.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final badge = badges[index];
                final earned = badge.isEarned;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: earned
                        ? ext.successLight.withValues(alpha: 0.65)
                        : ext.surfaceCanvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: earned
                          ? ext.success.withValues(alpha: 0.35)
                          : ext.borderSubtle,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: earned
                              ? ext.success.withValues(alpha: 0.14)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: earned
                                ? ext.success.withValues(alpha: 0.3)
                                : ext.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          earned
                              ? _badgeIcon(badge.iconKey)
                              : Icons.lock_outline,
                          size: 20,
                          color: earned
                              ? ext.success
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  badge.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                StatusPill(
                                  label: earned ? 'Diraih' : 'Terkunci',
                                  tone: earned
                                      ? StatusPillTone.success
                                      : StatusPillTone.neutral,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _badgeIcon(String iconKey) {
    final key = iconKey.toLowerCase();
    if (key.contains('streak') || key.contains('fire')) {
      return Icons.local_fire_department_rounded;
    }
    if (key.contains('star') || key.contains('xp')) {
      return Icons.auto_awesome_rounded;
    }
    if (key.contains('target') || key.contains('master')) {
      return Icons.track_changes_rounded;
    }
    if (key.contains('trophy') || key.contains('crown')) {
      return Icons.emoji_events_rounded;
    }
    return Icons.workspace_premium_rounded;
  }
}
