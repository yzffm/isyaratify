import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/letter_model.dart';
import '../../models/progress_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/progress_bar.dart';
import '../../widgets/common/status_pill.dart';

/// Filter status kamus di atas filter bawaan `DictionaryController`.
enum DictionaryStatusFilter { all, oneHand, twoHands, mastered }

/// Header kamus alfabet berisi progres penguasaan, search bar, dan chip filter.
class DictionaryHeaderCard extends StatelessWidget {
  const DictionaryHeaderCard({
    super.key,
    required this.totalLetters,
    required this.masteredCount,
    required this.searchController,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectFilter,
  });

  final int totalLetters;
  final int masteredCount;
  final TextEditingController searchController;
  final DictionaryStatusFilter statusFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<DictionaryStatusFilter> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ratio = totalLetters <= 0
        ? 0.0
        : (masteredCount / totalLetters).clamp(0.0, 1.0);
    final pct = (ratio * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final titleSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'KOLEKSI HURUF BISINDO',
                        style: AppTextStyles.labelSm.copyWith(
                          color: ext.headerIndigo,
                        ),
                      ),
                      Text(
                        '• Sistem Isyarat Bahasa Indonesia',
                        style: AppTextStyles.bodySm.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kamus Alfabet BISINDO',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              );

              final masteryCard = Container(
                width: isWide ? 300 : double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ext.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ext.primaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.verified_outlined,
                        color: ext.headerIndigo,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Penguasaan',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: ext.headerIndigo,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AppProgressBar(value: ratio, height: 6),
                          const SizedBox(height: 4),
                          Text(
                            '$masteredCount dari $totalLetters huruf dikuasai',
                            style: AppTextStyles.bodySm.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 14),
                    masteryCard,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: titleSection),
                  const SizedBox(width: 16),
                  masteryCard,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari huruf A - Z atau panduan...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: onClearSearch,
                            icon: const Icon(Icons.close_rounded, size: 18),
                          )
                        : null,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text('Semua ($totalLetters)'),
                    selected: statusFilter == DictionaryStatusFilter.all,
                    onSelected: (_) =>
                        onSelectFilter(DictionaryStatusFilter.all),
                  ),
                  ChoiceChip(
                    label: const Text('1 Tangan'),
                    selected: statusFilter == DictionaryStatusFilter.oneHand,
                    onSelected: (_) =>
                        onSelectFilter(DictionaryStatusFilter.oneHand),
                  ),
                  ChoiceChip(
                    label: const Text('2 Tangan'),
                    selected: statusFilter == DictionaryStatusFilter.twoHands,
                    onSelected: (_) =>
                        onSelectFilter(DictionaryStatusFilter.twoHands),
                  ),
                  ChoiceChip(
                    label: Text('Dikuasai ($masteredCount)'),
                    selected: statusFilter == DictionaryStatusFilter.mastered,
                    onSelected: (_) =>
                        onSelectFilter(DictionaryStatusFilter.mastered),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu satuan huruf alfabet pada grid Kamus.
class DictionaryLetterTile extends StatelessWidget {
  const DictionaryLetterTile({
    super.key,
    required this.letter,
    required this.mastery,
    required this.isSelected,
    required this.onTap,
  });

  final LetterModel letter;
  final LetterMasteryModel? mastery;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isMastered = mastery?.isMastered ?? false;
    final attempts = mastery?.totalAttempts ?? 0;
    final progress = mastery == null
        ? 0.0
        : isMastered
        ? 1.0
        : (mastery!.accuracyPct / 100.0).clamp(0.0, 1.0);

    final statusText = isMastered
        ? 'Dikuasai'
        : attempts > 0
        ? 'Belajar ${mastery!.accuracyPct.round()}%'
        : 'Siap dilatih';
    final statusColor = isMastered
        ? ext.success
        : attempts > 0
        ? ext.accentYellow
        : ext.headerIndigo;

    return Material(
      color: ext.surfaceCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? ext.headerIndigo : ext.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? ext.headerIndigo.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 14 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ext.headerIndigo
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter.letter,
                      style: AppTextStyles.headlineSm.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : scheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${letter.handCount}T',
                      style: AppTextStyles.labelSm.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    letter.requiresTwoHands
                        ? Icons.sign_language_rounded
                        : Icons.front_hand_outlined,
                    size: 28,
                    color: isMastered ? ext.success : ext.headerIndigo,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppProgressBar(
                    value: progress,
                    height: 5,
                    fillColor: statusColor,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSm.copyWith(
                            color: isMastered
                                ? ext.onSuccessContainer
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        isMastered
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                        size: 16,
                        color: isMastered ? ext.success : scheme.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel inspektor detail huruf BISINDO (dipakai di panel kanan desktop & modal mobile).
class DictionaryInspectorPanel extends StatelessWidget {
  const DictionaryInspectorPanel({
    super.key,
    required this.letter,
    required this.mastery,
    required this.onStartPractice,
    this.isInSheet = false,
  });

  final LetterModel letter;
  final LetterMasteryModel? mastery;
  final VoidCallback onStartPractice;
  final bool isInSheet;

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
    final accuracyText = mastery == null || attempts == 0
        ? 'Belum ada'
        : '${mastery!.accuracyPct.round()}%';
    final bestText = mastery == null || mastery!.bestConfidence <= 0
        ? '-'
        : '${(mastery!.bestConfidence * 100).round()}%';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ext.headerIndigo,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                letter.letter,
                style: AppTextStyles.headlineLg.copyWith(
                  color: Colors.white,
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
                    "Huruf Alfabet '${letter.letter}'",
                    style: AppTextStyles.headlineSm.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      StatusPill(
                        label: '${letter.handCount} Tangan',
                        tone: letter.requiresTwoHands
                            ? StatusPillTone.info
                            : StatusPillTone.neutral,
                        icon: Icons.front_hand_outlined,
                      ),
                      StatusPill(
                        label: _difficultyLabel(letter.difficulty),
                        tone: StatusPillTone.warning,
                        icon: Icons.school_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 152,
          decoration: BoxDecoration(
            color: ext.cameraBackdrop,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (letter.imageUrl != null && letter.imageUrl!.isNotEmpty)
                Image.network(
                  letter.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _LetterIllustrationPlaceholder(letter: letter),
                )
              else
                _LetterIllustrationPlaceholder(letter: letter),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Referensi Visual 2D',
                    style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          letter.description,
          style: AppTextStyles.bodyMd.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _MetricColumn(
                  label: 'Akurasi',
                  value: accuracyText,
                  valueColor: ext.headerIndigo,
                ),
              ),
              Expanded(
                child: _MetricColumn(label: 'Percobaan', value: '${attempts}x'),
              ),
              Expanded(
                child: _MetricColumn(
                  label: 'Skor Terbaik',
                  value: bestText,
                  valueColor: ext.onAccentYellowContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cara Melakukan Gestur:',
          style: AppTextStyles.labelLg.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < letter.stepByStepGuides.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ext.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: ext.headerIndigo,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    letter.stepByStepGuides[i],
                    style: AppTextStyles.bodyMd.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (letter.commonMistakes.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ext.accentYellowLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 20,
                  color: ext.onAccentYellowContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perhatikan Kesalahan Umum',
                        style: AppTextStyles.labelMd.copyWith(
                          color: ext.onAccentYellowContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        letter.commonMistakes,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        IsyaratifyPrimaryButton(
          label: 'Latih Huruf ${letter.letter} di Kamera',
          icon: Icons.videocam_rounded,
          expand: true,
          onPressed: onStartPractice,
        ),
      ],
    );

    if (isInSheet) return content;
    return AppCard(padding: const EdgeInsets.all(20), child: content);
  }
}

class _LetterIllustrationPlaceholder extends StatelessWidget {
  const _LetterIllustrationPlaceholder({required this.letter});

  final LetterModel letter;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          letter.requiresTwoHands
              ? Icons.sign_language_rounded
              : Icons.front_hand_rounded,
          size: 48,
          color: ext.accentYellow,
        ),
        const SizedBox(height: 8),
        Text(
          'Ilustrasi Gestur Huruf ${letter.letter} (${letter.handCount} Tangan)',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelLg.copyWith(
            color: valueColor ?? scheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
