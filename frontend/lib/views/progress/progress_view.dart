import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/progress_controller.dart';

/// Halaman Progres Pengguna, Lencana (Badges), Riwayat Latihan, dan Leaderboard.
class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  ProgressController? _fallbackController;

  ProgressController _resolveController(
    BuildContext context, {
    bool listen = false,
  }) {
    final provided = listen
        ? context.watch<ProgressController?>()
        : context.read<ProgressController?>();
    if (provided != null) return provided;
    return _fallbackController ??= ProgressController();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_resolveController(context).refreshAll());
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
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progres & Leaderboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Leaderboard'),
              Tab(text: 'Lencana'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: TabBarView(
              children: [
                // Tab 1: Leaderboard Publik
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = controller.leaderboard[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('#${entry.rank}')),
                        title: Text(
                          entry.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Level ${entry.level} • ${entry.masteredLettersCount}/26 huruf dikuasai',
                        ),
                        trailing: Text(
                          '${entry.xp} XP',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Tab 2: Lencana (Badges)
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.badges.length,
                  itemBuilder: (context, index) {
                    final badge = controller.badges[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          badge.isEarned
                              ? Icons.emoji_events
                              : Icons.lock_outline,
                          color: badge.isEarned
                              ? theme.colorScheme.primary
                              : theme.disabledColor,
                        ),
                        title: Text(badge.title),
                        subtitle: Text(badge.description),
                        trailing: badge.isEarned
                            ? const Chip(label: Text('Diraih'))
                            : const Text('Belum terbuka'),
                      ),
                    );
                  },
                ),

                // Tab 3: Riwayat Latihan (Metadata Tanpa Foto Kamera)
                controller.recentAttempts.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada riwayat latihan. Mulai berlatih di menu Latihan!',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.recentAttempts.length,
                        itemBuilder: (context, index) {
                          final attempt = controller.recentAttempts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                attempt.isCorrect
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: attempt.isCorrect
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary,
                              ),
                              title: Text(
                                attempt.targetLetter != null
                                    ? 'Target ${attempt.targetLetter} → Prediksi ${attempt.predictedLetter}'
                                    : 'Latihan Bebas → Huruf ${attempt.predictedLetter}',
                              ),
                              subtitle: Text(
                                'Keyakinan ${(attempt.confidence * 100).toStringAsFixed(0)}% • '
                                'Platform: ${attempt.platform}',
                              ),
                              trailing: Text(
                                attempt.isCorrect ? 'Benar' : 'Perlu latihan',
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
