import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/dictionary_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../common/stat_chip.dart';

/// Top bar responsif pada AppShell: pencarian kamus, chip streak/XP/level, dan pintasan cepat.
class TopBar extends StatefulWidget {
  const TopBar({super.key, this.currentLocation = '', this.onMenuPressed});

  /// Rute aktif saat ini untuk menghindari duplikasi BackButton dengan halaman legacy.
  final String currentLocation;

  /// Ditampilkan sebagai tombol menu pada layout compact (`< 700 px`).
  final VoidCallback? onMenuPressed;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    final dict = context.read<DictionaryController?>();
    dict?.setSearchQuery(value);
    context.go(AppRoutes.dictionary);
  }

  bool _hasStackedMatch(List<RouteMatchBase> matches) {
    if (matches.length > 1) return true;
    for (final match in matches) {
      if (match is ShellRouteMatch && _hasStackedMatch(match.matches)) {
        return true;
      }
    }
    return false;
  }

  bool _canNavigateBack(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) return true;
      if (_hasStackedMatch(
        router.routerDelegate.currentConfiguration.matches,
      )) {
        return true;
      }
    }
    return Navigator.of(context).canPop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = IsyaratifyColors.of(context);
    final auth = context.watch<AuthController?>();
    final progress = context.watch<ProgressController?>()?.progress;

    final streak = progress?.currentStreak ?? 0;
    final xp = progress?.xp ?? 0;
    final level = progress?.level ?? 1;
    final displayName = auth?.displayName ?? 'Pelajar';
    final initial = displayName.trim().isEmpty
        ? '?'
        : displayName.trim()[0].toUpperCase();

    final canPop = _canNavigateBack(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ext.surfaceCard.withValues(alpha: 0.96),
        border: Border(bottom: BorderSide(color: ext.borderSubtle)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showFullChips = constraints.maxWidth >= 780;
          final showSearch = constraints.maxWidth >= 480;

          return Row(
            children: [
              if (canPop) ...[
                BackButton(
                  onPressed: () {
                    final router = GoRouter.maybeOf(context);
                    if (router != null) {
                      router.pop();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
                const SizedBox(width: 4),
              ],
              if (widget.onMenuPressed != null) ...[
                IconButton(
                  tooltip: 'Buka Menu',
                  onPressed: widget.onMenuPressed,
                  icon: const Icon(Icons.menu_rounded),
                ),
                const SizedBox(width: 8),
              ],
              if (showSearch)
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: scheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _submitSearch,
                              style: AppTextStyles.bodySm.copyWith(
                                color: scheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Cari huruf, isyarat, materi...',
                                hintStyle: AppTextStyles.bodySm.copyWith(
                                  color: scheme.outline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              if (showFullChips) ...[
                StatChip(
                  icon: Icons.local_fire_department_rounded,
                  label: '$streak Hari',
                  backgroundColor: ext.accentYellowLight,
                  foregroundColor: ext.onAccentYellowContainer,
                  iconColor: scheme.secondary,
                ),
                const SizedBox(width: 8),
                StatChip(
                  icon: Icons.bolt_rounded,
                  label: '$xp XP',
                  backgroundColor: ext.primaryFixed,
                  foregroundColor: ext.onPrimaryFixed,
                  iconColor: scheme.primary,
                ),
                const SizedBox(width: 8),
                StatChip(
                  icon: Icons.explore_outlined,
                  label: 'Lv. $level',
                  backgroundColor: scheme.surfaceContainerHigh,
                  foregroundColor: scheme.onSurface,
                  iconColor: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
              ],
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TopBarIconButton(
                      tooltip: 'Buka Live Practice',
                      icon: Icons.videocam_outlined,
                      onPressed: () => context.go(AppRoutes.practice),
                    ),
                    _TopBarIconButton(
                      tooltip: 'Tentang Isyaratify',
                      icon: Icons.info_outline_rounded,
                      onPressed: () => context.go(AppRoutes.about),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Profil & Pengaturan',
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => context.go(AppRoutes.profile),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: scheme.primary,
                    child: Text(
                      initial,
                      style: AppTextStyles.labelMd.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      iconSize: 18,
      color: scheme.onSurfaceVariant,
      icon: Icon(icon),
    );
  }
}
