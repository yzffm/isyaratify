import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/dictionary_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../controllers/quest_controller.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/letter_model.dart';
import '../../widgets/common/state_views.dart';
import 'dashboard_widgets.dart';

/// Halaman Dashboard utama Isyaratify sesuai layout bento Stitch Web.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dictionary = context.read<DictionaryController>();
      final progress = context.read<ProgressController>();
      final quest = context.read<QuestController>();
      if (!dictionary.isLoading) {
        dictionary.loadDictionary();
      }
      if (!progress.isLoading) {
        progress.refreshAll();
      }
      if (!quest.isLoading) {
        quest.loadQuests();
      }
    });
  }

  LetterModel _pickRecommendedLetter(
    List<LetterModel> letters,
    DictionaryController dictionary,
  ) {
    if (letters.isEmpty) {
      return kDefaultBisindoLetters.first;
    }
    for (final letter in letters) {
      final mastery = dictionary.masteryFor(letter.letter);
      if (mastery == null || !mastery.isMastered) {
        return letter;
      }
    }
    return letters.first;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dictionary = context.watch<DictionaryController>();
    final progressCtrl = context.watch<ProgressController>();
    final questCtrl = context.watch<QuestController>();

    final ext = IsyaratifyColors.of(context);
    final layout = AppBreakpoints.of(context);
    final letters = dictionary.allLetters;
    final recommended = _pickRecommendedLetter(letters, dictionary);
    final isInitialLoading =
        (dictionary.isLoading || progressCtrl.isLoading) &&
        letters.isEmpty &&
        questCtrl.quests.isEmpty;

    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardRecommendedCard(
          letter: recommended,
          mastery: dictionary.masteryFor(recommended.letter),
          onPracticeLetter: () =>
              context.push(AppRoutes.practiceWithTarget(recommended.letter)),
        ),
        const SizedBox(height: 20),
        DashboardQuickAlphabetCard(
          letters: letters,
          masteryFor: dictionary.masteryFor,
          onOpenLetter: (letter) =>
              context.push(AppRoutes.practiceWithTarget(letter)),
          onOpenDictionary: () => context.push(AppRoutes.dictionary),
        ),
        const SizedBox(height: 20),
        DashboardActivityChartCard(
          recentAttempts: progressCtrl.recentAttempts,
          progress: progressCtrl.progress,
        ),
      ],
    );

    final rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardLevelCard(
          displayName: auth.displayName,
          progress: progressCtrl.progress,
          onOpenProgress: () => context.push(AppRoutes.progress),
        ),
        const SizedBox(height: 20),
        DashboardDailyQuestsCard(
          quests: questCtrl.quests,
          onOpenQuests: () => context.push(AppRoutes.quest),
        ),
        const SizedBox(height: 20),
        const DashboardTipsCard(),
      ],
    );

    return ColoredBox(
      color: ext.surfaceCanvas,
      child: RefreshIndicator(
        onRefresh: () => Future.wait([
          dictionary.loadDictionary(),
          progressCtrl.refreshAll(),
          questCtrl.loadQuests(),
        ]),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(layout == AppLayoutSize.compact ? 16 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: AppLoadingSkeleton(
                enabled: isInitialLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardWelcomeBanner(
                      displayName: auth.displayName,
                      progress: progressCtrl.progress,
                      masteredCount: progressCtrl.masteredLettersCount,
                      totalLetters: letters.isEmpty ? 26 : letters.length,
                      onStartPractice: () => context.push(
                        AppRoutes.practiceWithTarget(recommended.letter),
                      ),
                      onOpenDictionary: () =>
                          context.push(AppRoutes.dictionary),
                      onOpenAbout: () => context.push(AppRoutes.about),
                      onSignOut: auth.signOut,
                    ),
                    const SizedBox(height: 20),
                    if (layout == AppLayoutSize.expanded)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 8, child: leftColumn),
                          const SizedBox(width: 20),
                          Expanded(flex: 4, child: rightColumn),
                        ],
                      )
                    else ...[
                      leftColumn,
                      const SizedBox(height: 20),
                      rightColumn,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
