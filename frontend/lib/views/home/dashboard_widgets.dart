import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/attempt_model.dart';
import '../../models/letter_model.dart';
import '../../models/progress_model.dart';
import '../../models/quest_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/progress_bar.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/stat_chip.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/common/status_pill.dart';

/// Banner sambutan utama di bagian atas Dashboard dengan tombol aksi cepat.
class DashboardWelcomeBanner extends StatelessWidget {
  const DashboardWelcomeBanner({
    super.key,
    required this.displayName,
    required this.progress,
    required this.masteredCount,
    required this.totalLetters,
    required this.onStartPractice,
    required this.onOpenDictionary,
    required this.onOpenAbout,
    required this.onSignOut,
  });

  final String displayName;
  final UserProgressModel progress;
  final int masteredCount;
  final int totalLetters;
  final VoidCallback onStartPractice;
  final VoidCallback onOpenDictionary;
  final VoidCallback onOpenAbout;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerIndigo,
            AppColors.primary,
            AppColors.primaryContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerIndigo.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Dashboard',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Halo, $displayName!',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lanjutkan latihan alfabet BISINDO A–Z secara bertahap dengan deteksi lokal.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatChip(
                    icon: Icons.local_fire_department_rounded,
                    label: '${progress.currentStreak} Hari Streak',
                    backgroundColor: ext.accentYellowLight,
                    foregroundColor: ext.onAccentYellowContainer,
                    iconColor: AppColors.secondary,
                  ),
                  StatChip(
                    icon: Icons.verified_outlined,
                    label: '$masteredCount/$totalLetters Huruf Dikuasai',
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onStartPractice,
                style: FilledButton.styleFrom(
                  backgroundColor: ext.accentYellow,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.videocam_rounded, size: 18),
                label: const Text('Latihan'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenDictionary,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: const Text('Kamus alfabet'),
              ),
              TextButton.icon(
                onPressed: onOpenAbout,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                label: const Text('Tentang Kami'),
              ),
              TextButton.icon(
                onPressed: onSignOut,
                style: TextButton.styleFrom(
                  foregroundColor: ext.primaryFixed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Keluar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu rekomendasi huruf berikutnya untuk langsung dilatih di Practice studio.
class DashboardRecommendedCard extends StatelessWidget {
  const DashboardRecommendedCard({
    super.key,
    required this.letter,
    required this.mastery,
    required this.onPracticeLetter,
  });

  final LetterModel letter;
  final LetterMasteryModel? mastery;
  final VoidCallback onPracticeLetter;

  String _difficultyLabel(LetterDifficulty difficulty) {
    return switch (difficulty) {
      LetterDifficulty.easy => 'Dasar',
      LetterDifficulty.medium => 'Menengah',
      LetterDifficulty.hard => 'Lanjutan',
    };
  }

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final attempts = mastery?.totalAttempts ?? 0;
    final masteryPct = mastery == null
        ? 0
        : mastery!.isMastered
        ? 100
        : mastery!.accuracyPct.round().clamp(0, 100);

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 540;
          final badgeBox = Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ext.primaryFixed, scheme.surfaceContainerLow],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ext.borderSubtle),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  letter.letter,
                  style: AppTextStyles.displayLetter.copyWith(
                    color: ext.headerIndigo,
                  ),
                ),
                Text(
                  '${letter.handCount} Tangan',
                  style: AppTextStyles.labelSm.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );

          final infoCol = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  const StatusPill(
                    label: 'Rekomendasi Latihan',
                    tone: StatusPillTone.info,
                    icon: Icons.auto_awesome_rounded,
                  ),
                  StatusPill(
                    label: 'Tingkat ${_difficultyLabel(letter.difficulty)}',
                    tone: StatusPillTone.warning,
                    icon: Icons.school_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Target Berikutnya: Huruf "${letter.letter}"',
                style: AppTextStyles.headlineMd.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                letter.description,
                style: AppTextStyles.bodyMd.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (letter.stepByStepGuides.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Panduan awal: ${letter.stepByStepGuides.first}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: onPracticeLetter,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text('Mulai Huruf ${letter.letter}'),
                  ),
                  Text(
                    attempts > 0
                        ? 'Penguasaan saat ini: $masteryPct% ($attempts percobaan)'
                        : 'Belum ada percobaan pada huruf ini',
                    style: AppTextStyles.bodySm.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [badgeBox, const SizedBox(height: 16), infoCol],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              badgeBox,
              const SizedBox(width: 22),
              Expanded(child: infoCol),
            ],
          );
        },
      ),
    );
  }
}

/// Grid ringkas 6 huruf pertama (`A–F`) untuk akses cepat ke Live Practice.
class DashboardQuickAlphabetCard extends StatelessWidget {
  const DashboardQuickAlphabetCard({
    super.key,
    required this.letters,
    required this.masteryFor,
    required this.onOpenLetter,
    required this.onOpenDictionary,
  });

  final List<LetterModel> letters;
  final LetterMasteryModel? Function(String letter) masteryFor;
  final ValueChanged<String> onOpenLetter;
  final VoidCallback onOpenDictionary;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final preview = letters.take(6).toList(growable: false);

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Ringkasan Alfabet BISINDO',
            subtitle: 'Klik huruf untuk langsung berlatih di kamera',
            actionLabel: 'Semua (${letters.length})',
            onActionTap: onOpenDictionary,
          ),
          const SizedBox(height: 16),
          if (preview.isEmpty)
            AppEmptyState(
              title: 'Daftar Huruf Belum Tersedia',
              description:
                  'Buka kamus untuk memuat ulang daftar alfabet BISINDO A–Z.',
              icon: Icons.menu_book_outlined,
              actionLabel: 'Buka Kamus',
              onAction: onOpenDictionary,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620
                    ? 6
                    : constraints.maxWidth >= 380
                    ? 3
                    : 2;
                const spacing = 12.0;
                final itemWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                    columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: preview.map((item) {
                    final mastery = masteryFor(item.letter);
                    final isMastered = mastery?.isMastered ?? false;
                    final fraction = mastery == null
                        ? 0.0
                        : isMastered
                        ? 1.0
                        : (mastery.accuracyPct / 100.0).clamp(0.0, 1.0);
                    final statusLabel = isMastered
                        ? 'Dikuasai'
                        : (mastery?.totalAttempts ?? 0) > 0
                        ? '${(fraction * 100).round()}%'
                        : 'Baru';

                    return SizedBox(
                      width: itemWidth,
                      child: InkWell(
                        onTap: () => onOpenLetter(item.letter),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isMastered
                                ? ext.successLight.withValues(alpha: 0.55)
                                : scheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isMastered
                                  ? ext.success.withValues(alpha: 0.35)
                                  : ext.borderSubtle,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item.handCount}T',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Icon(
                                    isMastered
                                        ? Icons.check_circle_rounded
                                        : Icons.play_circle_outline_rounded,
                                    size: 16,
                                    color: isMastered
                                        ? ext.success
                                        : ext.headerIndigo,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.letter,
                                style: AppTextStyles.headlineLg.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppProgressBar(
                                value: fraction,
                                height: 5,
                                fillColor: isMastered
                                    ? ext.success
                                    : ext.headerIndigo,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                statusLabel,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: isMastered
                                      ? ext.onSuccessContainer
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Grafik aktivitas percobaan latihan mingguan berbasis data nyata [recentAttempts].
class DashboardActivityChartCard extends StatelessWidget {
  const DashboardActivityChartCard({
    super.key,
    required this.recentAttempts,
    required this.progress,
  });

  final List<PracticeAttemptModel> recentAttempts;
  final UserProgressModel progress;

  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final countsByWeekday = List<int>.filled(7, 0);
    for (final attempt in recentAttempts) {
      final index = (attempt.createdAt.weekday - 1).clamp(0, 6);
      countsByWeekday[index]++;
    }

    final maxCount = countsByWeekday.fold<int>(
      1,
      (best, value) => value > best ? value : best,
    );
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
    final subtitle = progress.totalAttempts > 0
        ? 'Akurasi tercatat: ${progress.accuracyPct.toStringAsFixed(0)}% (${progress.correctAttempts}/${progress.totalAttempts} percobaan)'
        : 'Belum ada riwayat sesi — grafik akan terisi setelah latihan lokal.';

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Aktivitas Latihan Mingguan',
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 172,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 1).toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: ext.borderSubtle, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value != value.roundToDouble()) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '${value.toInt()}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: scheme.outline,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _dayLabels.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = idx == todayIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _dayLabels[idx],
                            style: AppTextStyles.labelMd.copyWith(
                              color: isToday
                                  ? ext.headerIndigo
                                  : scheme.onSurfaceVariant,
                              fontWeight: isToday
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (index) {
                  final count = countsByWeekday[index];
                  final isToday = index == todayIndex;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        color: count == 0
                            ? scheme.surfaceContainerHigh
                            : isToday
                            ? ext.accentYellow
                            : ext.headerIndigo,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (maxCount + 1).toDouble(),
                          color: scheme.surfaceContainerLow,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu progres level dan XP pengguna pada kolom kanan Dashboard.
class DashboardLevelCard extends StatelessWidget {
  const DashboardLevelCard({
    super.key,
    required this.displayName,
    required this.progress,
    required this.onOpenProgress,
  });

  final String displayName;
  final UserProgressModel progress;
  final VoidCallback onOpenProgress;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final pct = (progress.xpProgressFraction * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'LEVEL PEMELAJAR',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: 'Tingkat ${progress.level}',
                tone: StatusPillTone.info,
                icon: Icons.explore_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.military_tech_rounded,
                  size: 32,
                  color: ext.headerIndigo,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSm.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${progress.xpInCurrentLevel} / 100 XP menuju Lv. ${progress.level + 1}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(value: progress.xpProgressFraction, height: 10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kurang ${progress.xpToNextLevel} XP lagi',
                style: AppTextStyles.labelSm.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                '$pct%',
                style: AppTextStyles.labelMd.copyWith(
                  color: ext.headerIndigo,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onOpenProgress,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
            ),
            icon: const Icon(Icons.insights_outlined, size: 18),
            label: const Text('Progres & Leaderboard'),
          ),
        ],
      ),
    );
  }
}

/// Kartu daftar misi harian aktif dari [QuestController].
class DashboardDailyQuestsCard extends StatelessWidget {
  const DashboardDailyQuestsCard({
    super.key,
    required this.quests,
    required this.onOpenQuests,
  });

  final List<QuestModel> quests;
  final VoidCallback onOpenQuests;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final topQuests = quests.take(3).toList(growable: false);

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Misi Harian',
            subtitle: 'Selesaikan target latihan bertahap',
            actionLabel: 'Semua',
            onActionTap: onOpenQuests,
          ),
          const SizedBox(height: 14),
          if (topQuests.isEmpty)
            const AppEmptyState(
              title: 'Belum Ada Misi Aktif',
              description:
                  'Misi latihan harian akan tampil di sini saat tersedia.',
              icon: Icons.flag_outlined,
            )
          else
            Column(
              children: topQuests.map((quest) {
                final done = quest.isCompleted;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: done
                        ? ext.successLight.withValues(alpha: 0.65)
                        : scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: done
                          ? ext.success.withValues(alpha: 0.35)
                          : ext.borderSubtle,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              quest.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelLg.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusPill(
                            label: done ? 'Selesai' : '+${quest.xpReward} XP',
                            tone: done
                                ? StatusPillTone.success
                                : StatusPillTone.warning,
                            icon: done
                                ? Icons.check_circle_outline_rounded
                                : Icons.bolt_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AppProgressBar(
                        value: quest.progressFraction,
                        height: 6,
                        fillColor: done ? ext.success : ext.headerIndigo,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progres: ${quest.currentProgress}/${quest.targetValue}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${(quest.progressFraction * 100).round()}%',
                            style: AppTextStyles.labelSm.copyWith(
                              color: done
                                  ? ext.onSuccessContainer
                                  : ext.headerIndigo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/// Kartu tips belajar dan jaminan privasi on-device pada Dashboard.
class DashboardTipsCard extends StatelessWidget {
  const DashboardTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: ext.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: ext.headerIndigo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tips Belajar Hari Ini',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TipRow(
            icon: Icons.wb_sunny_outlined,
            iconColor: ext.success,
            title: 'Pencahayaan Merata',
            description:
                'Pastikan tangan terlihat jelas menghadap kamera agar landmark sendi dapat terdeteksi stabil.',
          ),
          const SizedBox(height: 12),
          _TipRow(
            icon: Icons.shield_outlined,
            iconColor: ext.headerIndigo,
            title: 'Privasi Kamera On-Device',
            description:
                'Pelacakan tangan berjalan lokal di perangkat tanpa mengirim rekaman video ke server.',
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySm.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
