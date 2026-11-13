import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/dictionary_controller.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/letter_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/state_views.dart';
import 'dictionary_widgets.dart';

/// Halaman Kamus Alfabet Visual BISINDO A–Z dengan panel inspektor interaktif.
class DictionaryView extends StatefulWidget {
  const DictionaryView({super.key});

  @override
  State<DictionaryView> createState() => _DictionaryViewState();
}

class _DictionaryViewState extends State<DictionaryView> {
  final TextEditingController _searchController = TextEditingController();
  DictionaryStatusFilter _statusFilter = DictionaryStatusFilter.all;
  String? _selectedLetterCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DictionaryController>().loadDictionary();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter(
    DictionaryController dictionary,
    DictionaryStatusFilter filter,
  ) {
    setState(() => _statusFilter = filter);
    switch (filter) {
      case DictionaryStatusFilter.all:
      case DictionaryStatusFilter.mastered:
        dictionary.setHandsFilter(null);
      case DictionaryStatusFilter.oneHand:
        dictionary.setHandsFilter(1);
      case DictionaryStatusFilter.twoHands:
        dictionary.setHandsFilter(2);
    }
  }

  void _resetAll(DictionaryController dictionary) {
    _searchController.clear();
    dictionary.setSearchQuery('');
    _applyFilter(dictionary, DictionaryStatusFilter.all);
  }

  List<LetterModel> _visibleLetters(DictionaryController dictionary) {
    final base = dictionary.filteredLetters;
    if (_statusFilter != DictionaryStatusFilter.mastered) {
      return base;
    }
    return base
        .where((item) => dictionary.masteryFor(item.letter)?.isMastered == true)
        .toList(growable: false);
  }

  void _openInspectorSheet(
    BuildContext context,
    LetterModel letter,
    DictionaryController dictionary,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: DictionaryInspectorPanel(
              letter: letter,
              mastery: dictionary.masteryFor(letter.letter),
              isInSheet: true,
              onStartPractice: () {
                Navigator.of(sheetContext).pop();
                context.push(AppRoutes.practiceWithTarget(letter.letter));
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dictionary = context.watch<DictionaryController>();
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final layout = AppBreakpoints.of(context);

    final allLetters = dictionary.allLetters;
    final visibleLetters = _visibleLetters(dictionary);
    final masteredCount = allLetters
        .where((item) => dictionary.masteryFor(item.letter)?.isMastered == true)
        .length;

    LetterModel? selectedLetter;
    if (visibleLetters.isNotEmpty) {
      selectedLetter = visibleLetters.firstWhere(
        (item) => item.letter == _selectedLetterCode,
        orElse: () => visibleLetters.first,
      );
    }

    final isWide = layout == AppLayoutSize.expanded;

    final gridSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Daftar Alfabet',
          subtitle: 'Klik kartu huruf untuk melihat langkah gestur detail',
        ),
        const SizedBox(height: 14),
        if (visibleLetters.isEmpty)
          AppEmptyState(
            title: 'Huruf Tidak Ditemukan',
            description:
                'Tidak ada huruf yang cocok dengan kata kunci atau filter saat ini.',
            icon: Icons.search_off_rounded,
            actionLabel: 'Reset Filter',
            onAction: () => _resetAll(dictionary),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 780
                  ? 6
                  : constraints.maxWidth >= 560
                  ? 4
                  : constraints.maxWidth >= 340
                  ? 3
                  : 2;
              const spacing = 12.0;
              final tileWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: visibleLetters.map((item) {
                  final isSelected = selectedLetter?.letter == item.letter;
                  return SizedBox(
                    width: tileWidth,
                    height: 164,
                    child: DictionaryLetterTile(
                      letter: item,
                      mastery: dictionary.masteryFor(item.letter),
                      isSelected: isSelected && isWide,
                      onTap: () {
                        setState(() => _selectedLetterCode = item.letter);
                        if (!isWide) {
                          _openInspectorSheet(context, item, dictionary);
                        }
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        if (dictionary.guides.isNotEmpty) ...[
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Umum Pengambilan Gestur',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                for (final guide in dictionary.guides)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: ext.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${guide.title}: ${guide.summary}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );

    return ColoredBox(
      color: ext.surfaceCanvas,
      child: RefreshIndicator(
        onRefresh: dictionary.loadDictionary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(layout == AppLayoutSize.compact ? 16 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: AppLoadingSkeleton(
                enabled: dictionary.isLoading && allLetters.isEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DictionaryHeaderCard(
                      totalLetters: allLetters.length,
                      masteredCount: masteredCount,
                      searchController: _searchController,
                      statusFilter: _statusFilter,
                      onSearchChanged: dictionary.setSearchQuery,
                      onClearSearch: () => _resetAll(dictionary),
                      onSelectFilter: (f) => _applyFilter(dictionary, f),
                    ),
                    const SizedBox(height: 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 8, child: gridSection),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: selectedLetter != null
                                ? DictionaryInspectorPanel(
                                    letter: selectedLetter,
                                    mastery: dictionary.masteryFor(
                                      selectedLetter.letter,
                                    ),
                                    onStartPractice: () => context.push(
                                      AppRoutes.practiceWithTarget(
                                        selectedLetter!.letter,
                                      ),
                                    ),
                                  )
                                : const AppEmptyState(
                                    title: 'Pilih Huruf',
                                    description:
                                        'Klik salah satu huruf untuk melihat instruksi detail.',
                                  ),
                          ),
                        ],
                      )
                    else
                      gridSection,
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
