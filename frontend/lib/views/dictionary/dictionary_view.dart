import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/dictionary_controller.dart';
import '../../core/routing/app_routes.dart';
import '../../models/letter_model.dart';

/// Kamus Alfabet BISINDO A–Z beserta modul panduan belajar dan status penguasaan.
class DictionaryView extends StatefulWidget {
  const DictionaryView({super.key});

  @override
  State<DictionaryView> createState() => _DictionaryViewState();
}

class _DictionaryViewState extends State<DictionaryView> {
  DictionaryController? _fallbackController;

  DictionaryController _resolveController(
    BuildContext context, {
    bool listen = false,
  }) {
    final provided = listen
        ? context.watch<DictionaryController?>()
        : context.read<DictionaryController?>();
    if (provided != null) return provided;
    return _fallbackController ??= DictionaryController();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_resolveController(context).loadDictionary());
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
    final letters = controller.filteredLetters;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kamus alfabet')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Daftar huruf A–Z alfabet BISINDO beserta jumlah tangan dan panduan posisi jari.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari huruf atau petunjuk gerakan…',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: controller.setSearchQuery,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Semua (26)'),
                      selected: controller.handsFilter == null,
                      onSelected: (_) => controller.setHandsFilter(null),
                    ),
                    FilterChip(
                      label: const Text('1 Tangan'),
                      selected: controller.handsFilter == 1,
                      onSelected: (_) => controller.setHandsFilter(1),
                    ),
                    FilterChip(
                      label: const Text('2 Tangan'),
                      selected: controller.handsFilter == 2,
                      onSelected: (_) => controller.setHandsFilter(2),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: letters.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada huruf yang cocok dengan filter.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: letters.length,
                          itemBuilder: (context, index) {
                            final item = letters[index];
                            final mastery = controller.masteryFor(item.letter);
                            final isMastered = mastery?.isMastered ?? false;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isMastered
                                      ? theme.colorScheme.primaryContainer
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                  child: Text(
                                    item.letter,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      'Huruf ${item.letter}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text('${item.handCount} tangan'),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    if (isMastered) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.verified,
                                        size: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(item.description),
                                ),
                                trailing: FilledButton.tonal(
                                  onPressed: () => context.push(
                                    AppRoutes.practiceWithTarget(item.letter),
                                  ),
                                  child: const Text('Latih'),
                                ),
                                onTap: () => _showLetterDetailModal(
                                  context,
                                  item,
                                  isMastered: isMastered,
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

  void _showLetterDetailModal(
    BuildContext context,
    LetterModel item, {
    required bool isMastered,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (modalContext) {
        final theme = Theme.of(modalContext);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      item.letter,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Huruf ${item.letter}',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          'Kebutuhan: ${item.handCount} tangan • '
                          'Tingkat kesulitan: ${item.difficulty.labelId}'
                          '${isMastered ? " • Sudah Dikuasai" : ""}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(item.description, style: theme.textTheme.bodyLarge),
              if (item.stepByStepGuides.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...item.stepByStepGuides.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(step)),
                      ],
                    ),
                  ),
                ),
              ],
              if (item.commonMistakes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hindari kesalahan umum: ${item.commonMistakes}',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(modalContext).pop();
                  context.push(AppRoutes.practiceWithTarget(item.letter));
                },
                icon: const Icon(Icons.videocam),
                label: Text('Latih Huruf ${item.letter} Sekarang'),
              ),
            ],
          ),
        );
      },
    );
  }
}
