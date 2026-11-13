import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/progress_controller.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/attempt_model.dart';
import '../../models/progress_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/common/status_pill.dart';

enum _ProgressTab { leaderboard, badges, history }

/// Halaman Detail Progres, Penguasaan Huruf A–Z, Lencana & Riwayat Latihan.
class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  _ProgressTab _activeTab = _ProgressTab.history;

  static const List<String> _alphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  static String _safePublicName(LeaderboardEntryModel entry) {
    final display = entry.displayName.trim();
    if (display.isNotEmpty && !display.contains('@')) return display;
    final user = (entry.username ?? '').trim();
    if (user.isNotEmpty && !user.contains('@')) return user;
    return 'Pembelajar BISINDO';
  }

  static String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;
    final layoutSize = AppBreakpoints.of(context);
    final progressCtrl = context.watch<ProgressController>();
    final progress = progressCtrl.progress;
    final horizontalPad = layoutSize == AppLayoutSize.compact ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: ext.surfaceCanvas,
      body: RefreshIndicator(
        onRefresh: progressCtrl.refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  AppCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Progres Belajar Alfabet',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ringkasan penguasaan huruf BISINDO A–Z, lencana, dan metadata riwayat latihan.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: progressCtrl.refreshAll,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Muat Ulang'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            StatusPill(
                              label:
                                  'Level ${progress.level} • ${progress.xp} XP',
                              tone: StatusPillTone.info,
                              icon: Icons.bolt_rounded,
                            ),
                            StatusPill(
                              label: '${progress.currentStreak} hari streak',
                              tone: StatusPillTone.warning,
                              icon: Icons.local_fire_department_outlined,
                            ),
                            StatusPill(
                              label:
                                  '${progressCtrl.masteredLettersCount}/26 huruf dikuasai',
                              tone: StatusPillTone.success,
                              icon: Icons.check_circle_outline,
                            ),
                            StatusPill(
                              label:
                                  '${progressCtrl.earnedBadgesCount}/${progressCtrl.badges.length} lencana',
                              tone: StatusPillTone.neutral,
                              icon: Icons.workspace_premium_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _AlphabetMasteryMatrix(
                    alphabet: _alphabet,
                    mastery: progressCtrl.mastery,
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Riwayat'),
                              selected: _activeTab == _ProgressTab.history,
                              onSelected: (_) => setState(
                                () => _activeTab = _ProgressTab.history,
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('Lencana'),
                              selected: _activeTab == _ProgressTab.badges,
                              onSelected: (_) => setState(
                                () => _activeTab = _ProgressTab.badges,
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('Leaderboard'),
                              selected: _activeTab == _ProgressTab.leaderboard,
                              onSelected: (_) => setState(
                                () => _activeTab = _ProgressTab.leaderboard,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (_activeTab == _ProgressTab.history)
                          _HistoryTabSection(
                            attempts: progressCtrl.recentAttempts,
                            formatTimestamp: _formatTimestamp,
                            onStartPractice: () =>
                                context.push(AppRoutes.practice),
                          )
                        else if (_activeTab == _ProgressTab.badges)
                          _BadgesTabSection(badges: progressCtrl.badges)
                        else
                          _LeaderboardTabSection(
                            entries: progressCtrl.leaderboard,
                            safePublicName: _safePublicName,
                            onOpenLeaderboard: () =>
                                context.push(AppRoutes.leaderboard),
                          ),
                      ],
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

class _AlphabetMasteryMatrix extends StatelessWidget {
  const _AlphabetMasteryMatrix({required this.alphabet, required this.mastery});

  final List<String> alphabet;
  final Map<String, LetterMasteryModel> mastery;

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
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Peta Penguasaan Alfabet A–Z',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: const [
                  StatusPill(label: 'Dikuasai', tone: StatusPillTone.success),
                  StatusPill(label: 'Dilatih', tone: StatusPillTone.info),
                  StatusPill(label: 'Belum', tone: StatusPillTone.neutral),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final letter in alphabet)
                () {
                  final stat = mastery[letter];
                  final mastered = stat?.isMastered ?? false;
                  final practiced = (stat?.totalAttempts ?? 0) > 0;

                  final Color bg;
                  final Color fg;
                  final Color border;
                  if (mastered) {
                    bg = ext.successLight;
                    fg = ext.onSuccessContainer;
                    border = ext.success.withValues(alpha: 0.45);
                  } else if (practiced) {
                    bg = ext.primaryFixed;
                    fg = ext.onPrimaryFixed;
                    border = theme.colorScheme.primary.withValues(alpha: 0.35);
                  } else {
                    bg = ext.surfaceCanvas;
                    fg = theme.colorScheme.onSurfaceVariant;
                    border = ext.borderSubtle;
                  }

                  return Tooltip(
                    message: stat == null
                        ? 'Huruf $letter: belum dilatih'
                        : 'Huruf $letter: ${stat.correctAttempts}/${stat.totalAttempts} cocok (${stat.accuracyPct.round()}%)',
                    child: Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            letter,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: fg,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            stat == null ? '0x' : '${stat.totalAttempts}x',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: fg.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }(),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryTabSection extends StatelessWidget {
  const _HistoryTabSection({
    required this.attempts,
    required this.formatTimestamp,
    required this.onStartPractice,
  });

  final List<PracticeAttemptModel> attempts;
  final String Function(DateTime) formatTimestamp;
  final VoidCallback onStartPractice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    if (attempts.isEmpty) {
      return AppEmptyState(
        title: 'Belum ada riwayat latihan',
        description:
            'Rekam percobaan pengenalan alfabet BISINDO di menu Latihan. Hanya metadata hasil yang disimpan tanpa frame kamera.',
        icon: Icons.history_outlined,
        actionLabel: 'Mulai Latihan Sekarang',
        onAction: onStartPractice,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attempts.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: ext.borderSubtle),
      itemBuilder: (context, index) {
        final item = attempts[index];
        final scorePct = (item.confidence * 100).round();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: item.isCorrect
                    ? ext.successLight
                    : ext.feedbackErrorLight,
                child: Text(
                  (item.targetLetter ?? '').isEmpty
                      ? item.predictedLetter
                      : item.targetLetter!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: item.isCorrect ? ext.success : ext.feedbackError,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target ${(item.targetLetter ?? '').isEmpty ? 'Bebas' : item.targetLetter!} • Prediksi ${item.predictedLetter}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Skor model $scorePct% • Platform ${item.platform} • ${formatTimestamp(item.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: item.isCorrect ? 'Cocok' : 'Ulangi',
                tone: item.isCorrect
                    ? StatusPillTone.success
                    : StatusPillTone.warning,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BadgesTabSection extends StatelessWidget {
  const _BadgesTabSection({required this.badges});

  final List<BadgeModel> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;
    final sorted = [...badges]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (sorted.isEmpty) {
      return const AppEmptyState(
        title: 'Belum ada data lencana',
        description:
            'Daftar lencana pencapaian akan muncul di sini setelah dimuat.',
        icon: Icons.workspace_premium_outlined,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final badge = sorted[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: badge.isEarned
                ? ext.successLight.withValues(alpha: 0.6)
                : ext.surfaceCanvas,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: badge.isEarned
                  ? ext.success.withValues(alpha: 0.35)
                  : ext.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Icon(
                badge.isEarned
                    ? Icons.workspace_premium_rounded
                    : Icons.lock_outline,
                color: badge.isEarned
                    ? ext.success
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badge.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: badge.isEarned ? 'Diraih' : 'Terkunci',
                tone: badge.isEarned
                    ? StatusPillTone.success
                    : StatusPillTone.neutral,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardTabSection extends StatelessWidget {
  const _LeaderboardTabSection({
    required this.entries,
    required this.safePublicName,
    required this.onOpenLeaderboard,
  });

  final List<LeaderboardEntryModel> entries;
  final String Function(LeaderboardEntryModel) safePublicName;
  final VoidCallback onOpenLeaderboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isEmpty)
          AppEmptyState(
            title: 'Belum ada peringkat tersinkron',
            description:
                'Buka halaman Papan Peringkat untuk melihat tolok ukur komunitas.',
            icon: Icons.leaderboard_outlined,
            actionLabel: 'Buka Papan Peringkat',
            onAction: onOpenLeaderboard,
          )
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: ext.borderSubtle),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final name = safePublicName(entry);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: ext.primaryFixed,
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      color: ext.onPrimaryFixed,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Level ${entry.level} • ${entry.masteredLettersCount} huruf',
                ),
                trailing: Text(
                  '${entry.xp} XP',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: onOpenLeaderboard,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Buka Papan Peringkat Penuh'),
            ),
          ),
        ],
      ],
    );
  }
}
