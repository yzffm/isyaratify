import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/progress_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/common/status_pill.dart';

/// Data contoh lokal untuk melengkapi podium ketika baris komunitas dari
/// Supabase/lokal masih kurang dari 3 pembelajar.
const List<LeaderboardEntryModel> _kSampleLeaderboardEntries = [
  LeaderboardEntryModel(
    rank: 1,
    userId: 'sample-1',
    username: 'raka_bisindo',
    displayName: 'Raka Pratama',
    xp: 480,
    level: 5,
    currentStreak: 7,
    masteredLettersCount: 18,
  ),
  LeaderboardEntryModel(
    rank: 2,
    userId: 'sample-2',
    username: 'nadia_sign',
    displayName: 'Nadia Putri',
    xp: 360,
    level: 4,
    currentStreak: 5,
    masteredLettersCount: 14,
  ),
  LeaderboardEntryModel(
    rank: 3,
    userId: 'sample-3',
    username: 'bima_karya',
    displayName: 'Bima Santoso',
    xp: 250,
    level: 3,
    currentStreak: 4,
    masteredLettersCount: 10,
  ),
  LeaderboardEntryModel(
    rank: 4,
    userId: 'sample-4',
    username: 'citra_isyarat',
    displayName: 'Citra Lestari',
    xp: 160,
    level: 2,
    currentStreak: 2,
    masteredLettersCount: 6,
  ),
  LeaderboardEntryModel(
    rank: 5,
    userId: 'sample-5',
    username: 'dafa_belajar',
    displayName: 'Dafa Wijaya',
    xp: 90,
    level: 1,
    currentStreak: 1,
    masteredLettersCount: 3,
  ),
];

/// Halaman Papan Peringkat Komunitas Isyaratify.
class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Menghindari pemaparan alamat email pada papan peringkat publik.
  static String _sanitizePublicName({
    required String displayName,
    required String? username,
  }) {
    final trimmedDisplay = displayName.trim();
    if (trimmedDisplay.isNotEmpty && !trimmedDisplay.contains('@')) {
      return trimmedDisplay;
    }
    final trimmedUser = (username ?? '').trim();
    if (trimmedUser.isNotEmpty && !trimmedUser.contains('@')) {
      return trimmedUser;
    }
    return 'Pembelajar BISINDO';
  }

  static String _safeInitial(String publicName) {
    final trimmed = publicName.trim();
    if (trimmed.isEmpty) return 'P';
    return trimmed[0].toUpperCase();
  }

  List<_RankedLearner> _buildRankedEntries({
    required List<LeaderboardEntryModel> rawEntries,
    required UserProgressModel currentProgress,
    required int currentMasteredCount,
    required String currentUserName,
    required bool hasSampleFallback,
  }) {
    final combined = <LeaderboardEntryModel>[...rawEntries];
    final existingIds = combined.map((e) => e.userId).toSet();

    final currentSafeName = _sanitizePublicName(
      displayName: currentUserName,
      username: '',
    );

    if (hasSampleFallback) {
      // Pastikan pembelajar saat ini tetap terlihat bila belum ada di rawEntries.
      final alreadyHasCurrentUser = combined.any((e) {
        final name = _sanitizePublicName(
          displayName: e.displayName,
          username: e.username,
        );
        return e.userId == currentProgress.userId || name == currentSafeName;
      });
      if (!alreadyHasCurrentUser) {
        combined.add(
          LeaderboardEntryModel(
            rank: 0,
            userId: currentProgress.userId,
            username: currentSafeName.toLowerCase().replaceAll(' ', '_'),
            displayName: currentSafeName,
            xp: currentProgress.xp,
            level: currentProgress.level,
            currentStreak: currentProgress.currentStreak,
            masteredLettersCount: currentMasteredCount,
          ),
        );
        existingIds.add(currentProgress.userId);
      }

      for (final sample in _kSampleLeaderboardEntries) {
        if (combined.length >= 5) break;
        if (!existingIds.contains(sample.userId)) {
          combined.add(sample);
          existingIds.add(sample.userId);
        }
      }
    }

    combined.sort((a, b) {
      final xpDiff = b.xp.compareTo(a.xp);
      if (xpDiff != 0) return xpDiff;
      return b.masteredLettersCount.compareTo(a.masteredLettersCount);
    });

    return [
      for (var i = 0; i < combined.length; i++)
        () {
          final entry = combined[i];
          final safeName = _sanitizePublicName(
            displayName: entry.displayName,
            username: entry.username,
          );
          final isSample = entry.userId.startsWith('sample-');
          final isCurrentUser =
              !isSample &&
              (entry.userId == currentProgress.userId ||
                  safeName == currentSafeName);
          return _RankedLearner(
            rank: i + 1,
            entry: entry,
            publicName: safeName,
            initial: _safeInitial(safeName),
            isCurrentUser: isCurrentUser,
            isSample: isSample,
          );
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = Theme.of(context).extension<IsyaratifyColors>()!;
    final layoutSize = AppBreakpoints.of(context);

    final progressCtrl = context.watch<ProgressController>();
    final authCtrl = context.watch<AuthController>();

    final rawLeaderboard = progressCtrl.leaderboard;
    final hasSampleFallback = rawLeaderboard.length < 3;
    final rankedList = _buildRankedEntries(
      rawEntries: rawLeaderboard,
      currentProgress: progressCtrl.progress,
      currentMasteredCount: progressCtrl.masteredLettersCount,
      currentUserName: authCtrl.displayName,
      hasSampleFallback: hasSampleFallback,
    );

    final topThree = rankedList.take(3).toList();
    final currentUserEntry = rankedList.cast<_RankedLearner?>().firstWhere(
      (item) => item?.isCurrentUser ?? false,
      orElse: () => null,
    );

    final myRank =
        currentUserEntry?.rank ??
        (rankedList
                .where((item) => item.entry.xp > progressCtrl.progress.xp)
                .length +
            1);
    final myPublicName = _sanitizePublicName(
      displayName: authCtrl.displayName,
      username: '',
    );

    final query = _searchQuery.trim().toLowerCase();
    final filteredList = query.isEmpty
        ? rankedList
        : rankedList
              .where((item) => item.publicName.toLowerCase().contains(query))
              .toList();

    final showSkeleton = progressCtrl.isLoading && rawLeaderboard.isEmpty;
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
                  _LeaderboardHeader(
                    hasSampleFallback: hasSampleFallback,
                    onRefresh: progressCtrl.refreshAll,
                  ),
                  const SizedBox(height: 20),
                  _CurrentUserRankBanner(
                    rank: myRank,
                    publicName: myPublicName,
                    initial: _safeInitial(myPublicName),
                    progress: progressCtrl.progress,
                    masteredLettersCount: progressCtrl.masteredLettersCount,
                    isLocalEstimate: hasSampleFallback,
                    onPracticeTap: () => context.push(AppRoutes.practice),
                  ),
                  const SizedBox(height: 24),
                  if (showSkeleton)
                    _LeaderboardLoadingSkeleton()
                  else ...[
                    if (topThree.length >= 3) ...[
                      Text(
                        'Podium Teratas',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _PodiumSection(
                        topThree: topThree,
                        isCompact: layoutSize == AppLayoutSize.compact,
                      ),
                      const SizedBox(height: 24),
                    ],
                    _LearnerDirectoryCard(
                      entries: filteredList,
                      totalCount: rankedList.length,
                      searchController: _searchController,
                      searchQuery: _searchQuery,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankedLearner {
  const _RankedLearner({
    required this.rank,
    required this.entry,
    required this.publicName,
    required this.initial,
    required this.isCurrentUser,
    required this.isSample,
  });

  final int rank;
  final LeaderboardEntryModel entry;
  final String publicName;
  final String initial;
  final bool isCurrentUser;
  final bool isSample;
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({
    required this.hasSampleFallback,
    required this.onRefresh,
  });

  final bool hasSampleFallback;
  final VoidCallback onRefresh;

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
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Papan Peringkat Komunitas',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const StatusPill(
                    label: 'Peringkat XP',
                    tone: StatusPillTone.info,
                    icon: Icons.leaderboard_outlined,
                  ),
                  if (hasSampleFallback)
                    const StatusPill(
                      label: 'Data contoh lokal',
                      tone: StatusPillTone.warning,
                      icon: Icons.info_outline,
                    ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Muat Ulang'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pantau perolehan XP, streak harian, dan jumlah huruf BISINDO yang dikuasai tanpa menampilkan data email pribadi.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasSampleFallback) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ext.accentYellowLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: ext.onAccentYellowContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sebagian entri peringkat adalah data contoh lokal sebagai tolok ukur latihan karena data komunitas daring masih terbatas.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.onAccentYellowContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrentUserRankBanner extends StatelessWidget {
  const _CurrentUserRankBanner({
    required this.rank,
    required this.publicName,
    required this.initial,
    required this.progress,
    required this.masteredLettersCount,
    required this.isLocalEstimate,
    required this.onPracticeTap,
  });

  final int rank;
  final String publicName;
  final String initial;
  final UserProgressModel progress;
  final int masteredLettersCount;
  final bool isLocalEstimate;
  final VoidCallback onPracticeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.headerIndigo, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: ext.accentYellow,
                child: Text(
                  initial,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: ext.onAccentYellowContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Peringkat Kamu',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: ext.accentYellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isLocalEstimate ? '#$rank (Lokal)' : '#$rank',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      publicName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${progress.xp} XP',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Level ${progress.level}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          '$masteredLettersCount huruf',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          '${progress.currentStreak} hari streak',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: onPracticeTap,
            style: FilledButton.styleFrom(
              backgroundColor: ext.accentYellow,
              foregroundColor: ext.onAccentYellowContainer,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.videocam_outlined, size: 18),
            label: const Text(
              'Tambah XP via Latihan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumSection extends StatelessWidget {
  const _PodiumSection({required this.topThree, required this.isCompact});

  final List<_RankedLearner> topThree;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final first = topThree[0];
    final second = topThree[1];
    final third = topThree[2];

    if (isCompact) {
      return Column(
        children: [
          _PodiumCard(learner: first, medalLabel: '#1 Emas', tier: 1),
          const SizedBox(height: 12),
          _PodiumCard(learner: second, medalLabel: '#2 Perak', tier: 2),
          const SizedBox(height: 12),
          _PodiumCard(learner: third, medalLabel: '#3 Perunggu', tier: 3),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 22),
            child: _PodiumCard(
              learner: second,
              medalLabel: '#2 Perak',
              tier: 2,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _PodiumCard(learner: first, medalLabel: '#1 Emas', tier: 1),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: _PodiumCard(
              learner: third,
              medalLabel: '#3 Perunggu',
              tier: 3,
            ),
          ),
        ),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.learner,
    required this.medalLabel,
    required this.tier,
  });

  final _RankedLearner learner;
  final String medalLabel;
  final int tier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    final Color badgeBg;
    final Color badgeFg;
    final IconData medalIcon;
    switch (tier) {
      case 1:
        badgeBg = ext.accentYellowLight;
        badgeFg = ext.onAccentYellowContainer;
        medalIcon = Icons.emoji_events_rounded;
        break;
      case 2:
        badgeBg = ext.primaryFixed;
        badgeFg = ext.onPrimaryFixed;
        medalIcon = Icons.military_tech_rounded;
        break;
      default:
        badgeBg = const Color(0xFFF3E8DF);
        badgeFg = const Color(0xFF7C4A27);
        medalIcon = Icons.workspace_premium_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.all(tier == 1 ? 22 : 18),
      decoration: BoxDecoration(
        color: ext.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: learner.isCurrentUser
              ? theme.colorScheme.primary
              : (tier == 1
                    ? ext.accentYellow.withValues(alpha: 0.7)
                    : ext.borderSubtle),
          width: tier == 1 || learner.isCurrentUser ? 1.8 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(medalIcon, size: 15, color: badgeFg),
                const SizedBox(width: 5),
                Text(
                  medalLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: badgeFg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CircleAvatar(
            radius: tier == 1 ? 30 : 24,
            backgroundColor: badgeBg,
            child: Text(
              learner.initial,
              style:
                  (tier == 1
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.titleLarge)
                      ?.copyWith(color: badgeFg, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            learner.publicName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${learner.entry.xp} XP',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Lv ${learner.entry.level}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '• ${learner.entry.masteredLettersCount} huruf',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (learner.isCurrentUser)
                const StatusPill(label: 'Kamu', tone: StatusPillTone.info)
              else if (learner.isSample)
                const StatusPill(label: 'Contoh', tone: StatusPillTone.neutral),
            ],
          ),
        ],
      ),
    );
  }
}

class _LearnerDirectoryCard extends StatelessWidget {
  const _LearnerDirectoryCard({
    required this.entries,
    required this.totalCount,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final List<_RankedLearner> entries;
  final int totalCount;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

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
                'Daftar Lengkap Pembelajar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              StatusPill(
                label: '${entries.length} / $totalCount pembelajar',
                tone: StatusPillTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama pembelajar...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: onClearSearch,
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: ext.surfaceCanvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: ext.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: ext.borderSubtle),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'Pembelajar tidak ditemukan',
              description:
                  'Tidak ada nama pembelajar yang cocok dengan kata kunci "$searchQuery".',
              icon: Icons.person_search_outlined,
              actionLabel: 'Reset Pencarian',
              onAction: onClearSearch,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: ext.borderSubtle),
              itemBuilder: (context, index) {
                final item = entries[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: item.isCurrentUser
                        ? ext.primaryFixed.withValues(alpha: 0.45)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 38,
                        child: Text(
                          '#${item.rank}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: item.rank <= 3
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: item.isCurrentUser
                            ? theme.colorScheme.primary
                            : ext.primaryFixed,
                        child: Text(
                          item.initial,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: item.isCurrentUser
                                ? Colors.white
                                : ext.onPrimaryFixed,
                            fontWeight: FontWeight.w800,
                          ),
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
                                  item.publicName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (item.isCurrentUser)
                                  const StatusPill(
                                    label: 'Kamu',
                                    tone: StatusPillTone.info,
                                  )
                                else if (item.isSample)
                                  const StatusPill(
                                    label: 'Contoh',
                                    tone: StatusPillTone.neutral,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              spacing: 10,
                              runSpacing: 2,
                              children: [
                                Text(
                                  'Level ${item.entry.level}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${item.entry.masteredLettersCount} huruf dikuasai',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${item.entry.currentStreak} hari streak',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.entry.xp} XP',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
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
}

class _LeaderboardLoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Memuat Papan Peringkat...'),
                SizedBox(height: 12),
                Text('Mengambil daftar pembelajar dan perolehan XP'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
