import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/quest_controller.dart';
import '../../core/routing/app_routes.dart';

/// Halaman Misi (Quest) harian dan pencapaian.
class QuestView extends StatefulWidget {
  const QuestView({super.key});

  @override
  State<QuestView> createState() => _QuestViewState();
}

class _QuestViewState extends State<QuestView> {
  QuestController? _fallbackController;

  QuestController _resolveController(
    BuildContext context, {
    bool listen = false,
  }) {
    final provided = listen
        ? context.watch<QuestController?>()
        : context.read<QuestController?>();
    if (provided != null) return provided;
    return _fallbackController ??= QuestController();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_resolveController(context).loadQuests());
    });
  }

  @override
  void dispose() {
    _fallbackController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _resolveController(context, listen: true);
    final quests = controller.quests;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Misi & Quest')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Selesaikan misi latihan gestur BISINDO untuk memperoleh '
                      'bonus XP dan membuka lencana. (${controller.completedCount}/${quests.length} selesai)',
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: quests.length,
                    itemBuilder: (context, index) {
                      final quest = quests[index];
                      final firstTarget = quest.targetLetters.isNotEmpty
                          ? quest.targetLetters.first
                          : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    quest.isCompleted
                                        ? Icons.check_circle
                                        : Icons.flag_outlined,
                                    color: quest.isCompleted
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      quest.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text('+${quest.xpReward} XP'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(quest.description),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: quest.progressFraction,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progres: ${quest.currentProgress}/${quest.targetValue}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  if (!quest.isCompleted)
                                    TextButton.icon(
                                      onPressed: () => context.push(
                                        AppRoutes.practiceWithTarget(
                                          firstTarget,
                                        ),
                                      ),
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Kerjakan'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
