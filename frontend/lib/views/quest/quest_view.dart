import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controllers/progress_controller.dart';
import '../../controllers/quest_controller.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/quest_model.dart';
import '../../widgets/common/state_views.dart';
import 'quest_widgets.dart';

/// Halaman Quest & Pencapaian Lencana Isyaratify.
class QuestView extends StatefulWidget {
  const QuestView({super.key});

  @override
  State<QuestView> createState() => _QuestViewState();
}

class _QuestViewState extends State<QuestView> {
  QuestFilter _selectedFilter = QuestFilter.all;

  Future<void> _refreshAll(BuildContext context) async {
    final questCtrl = context.read<QuestController>();
    final progressCtrl = context.read<ProgressController>();
    await Future.wait([questCtrl.loadQuests(), progressCtrl.refreshAll()]);
  }

  List<QuestModel> _filterQuests(List<QuestModel> quests) {
    switch (_selectedFilter) {
      case QuestFilter.all:
        return quests;
      case QuestFilter.active:
        return quests.where((q) => !q.isCompleted).toList();
      case QuestFilter.completed:
        return quests.where((q) => q.isCompleted).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<IsyaratifyColors>()!;
    final layoutSize = AppBreakpoints.of(context);
    final isExpanded = layoutSize == AppLayoutSize.expanded;

    final questCtrl = context.watch<QuestController>();
    final progressCtrl = context.watch<ProgressController>();

    final allQuests = questCtrl.quests;
    final completedQuests = allQuests.where((q) => q.isCompleted).toList();
    final activeQuests = allQuests.where((q) => !q.isCompleted).toList();
    final filteredQuests = _filterQuests(allQuests);

    final badges = [...progressCtrl.badges]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final showSkeleton =
        (questCtrl.isLoading || progressCtrl.isLoading) && allQuests.isEmpty;

    final horizontalPad = layoutSize == AppLayoutSize.compact ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: ext.surfaceCanvas,
      body: RefreshIndicator(
        onRefresh: () => _refreshAll(context),
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
                  QuestHeroBanner(
                    progress: progressCtrl.progress,
                    completedQuestsCount: completedQuests.length,
                    totalQuestsCount: allQuests.length,
                    earnedBadgesCount: progressCtrl.earnedBadgesCount,
                    totalBadgesCount: badges.length,
                    onStartPractice: () => context.push(AppRoutes.practice),
                    onOpenLeaderboard: () =>
                        context.push(AppRoutes.leaderboard),
                  ),
                  const SizedBox(height: 24),
                  if (showSkeleton)
                    _QuestLoadingSkeleton()
                  else if (isExpanded)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildQuestColumn(
                            context: context,
                            allQuests: allQuests,
                            activeCount: activeQuests.length,
                            completedCount: completedQuests.length,
                            filteredQuests: filteredQuests,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 5,
                          child: BadgeShowcasePanel(
                            badges: badges,
                            earnedCount: progressCtrl.earnedBadgesCount,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildQuestColumn(
                      context: context,
                      allQuests: allQuests,
                      activeCount: activeQuests.length,
                      completedCount: completedQuests.length,
                      filteredQuests: filteredQuests,
                    ),
                    const SizedBox(height: 24),
                    BadgeShowcasePanel(
                      badges: badges,
                      earnedCount: progressCtrl.earnedBadgesCount,
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

  Widget _buildQuestColumn({
    required BuildContext context,
    required List<QuestModel> allQuests,
    required int activeCount,
    required int completedCount,
    required List<QuestModel> filteredQuests,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestFilterBar(
          selectedFilter: _selectedFilter,
          totalCount: allQuests.length,
          activeCount: activeCount,
          completedCount: completedCount,
          onSelectFilter: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          onRefresh: () => _refreshAll(context),
        ),
        const SizedBox(height: 16),
        if (allQuests.isEmpty)
          AppEmptyState(
            title: 'Belum ada misi aktif',
            description:
                'Misi tantangan alfabet BISINDO akan tampil di sini setelah dimuat. Kamu tetap bisa langsung berlatih kamera kapan saja.',
            icon: Icons.flag_outlined,
            actionLabel: 'Latihan Bebas',
            onAction: () => context.push(AppRoutes.practice),
          )
        else if (filteredQuests.isEmpty)
          AppEmptyState(
            title: _selectedFilter == QuestFilter.completed
                ? 'Belum ada misi selesai'
                : 'Semua misi sudah selesai',
            description: _selectedFilter == QuestFilter.completed
                ? 'Selesaikan misi latihan gestur statis A–Z untuk melihat pencapaianmu di sini.'
                : 'Selamat! Kamu sudah menuntaskan misi aktif yang tersedia.',
            icon: Icons.filter_list_off_outlined,
            actionLabel: 'Tampilkan Semua Misi',
            onAction: () {
              setState(() {
                _selectedFilter = QuestFilter.all;
              });
            },
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredQuests.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quest = filteredQuests[index];
              return QuestItemCard(
                quest: quest,
                onPracticeTap: () => context.push(AppRoutes.practice),
              );
            },
          ),
      ],
    );
  }
}

class _QuestLoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Memuat Misi Alfabet BISINDO'),
                  SizedBox(height: 8),
                  Text(
                    'Menyiapkan daftar misi latihan dan target huruf statis...',
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(value: 0.4),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
