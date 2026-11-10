import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../controllers/quest_controller.dart';
import '../../core/routing/app_routes.dart';
import '../../widgets/placeholder_scaffold.dart';

/// Halaman utama (Dashboard): menampilkan ringkasan XP, level, streak,
/// quest aktif, serta pintasan ke Kamus, Latihan, Quest, dan Progres.
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
      final progressCtrl = context.read<ProgressController?>();
      final questCtrl = context.read<QuestController?>();
      if (progressCtrl != null) {
        unawaited(progressCtrl.refreshAll());
      }
      if (questCtrl != null) {
        unawaited(questCtrl.loadQuests());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final progressCtrl = context.watch<ProgressController?>();
    final questCtrl = context.watch<QuestController?>();
    final progress = progressCtrl?.progress;
    final theme = Theme.of(context);

    return PlaceholderScaffold(
      title: 'Dashboard',
      children: [
        Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${auth.displayName}!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level ${progress?.level ?? 1} • ${progress?.xp ?? 0} XP • '
                  'Streak ${progress?.currentStreak ?? 0} hari • '
                  '${progressCtrl?.masteredLettersCount ?? 0}/26 huruf dikuasai',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress?.xpProgressFraction ?? 0.0,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                if (questCtrl != null && questCtrl.quests.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Misi selesai: ${questCtrl.completedCount}/${questCtrl.quests.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.practice),
          icon: const Icon(Icons.videocam),
          label: const Text('Latihan'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.dictionary),
          icon: const Icon(Icons.menu_book),
          label: const Text('Kamus alfabet'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.quest),
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Misi & Quest'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.progress),
          icon: const Icon(Icons.leaderboard_outlined),
          label: const Text('Progres & Leaderboard'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.push(AppRoutes.about),
          icon: const Icon(Icons.info_outline),
          label: const Text('Tentang Kami'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.read<AuthController>().signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('Keluar'),
        ),
      ],
    );
  }
}
