import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/progress_controller.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../brand/brand_logo.dart';
import '../common/progress_bar.dart';

/// Item navigasi utama pada shell aplikasi web/tablet.
@immutable
class AppNavDestination {
  const AppNavDestination({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<AppNavDestination> kAppNavDestinations = [
  AppNavDestination(
    route: AppRoutes.home,
    label: 'Dashboard',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
  ),
  AppNavDestination(
    route: AppRoutes.dictionary,
    label: 'Kamus Alfabet',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
  ),
  AppNavDestination(
    route: AppRoutes.practice,
    label: 'Live Practice',
    icon: Icons.videocam_outlined,
    selectedIcon: Icons.videocam_rounded,
  ),
  AppNavDestination(
    route: AppRoutes.quest,
    label: 'Quest & Tantangan',
    icon: Icons.military_tech_outlined,
    selectedIcon: Icons.military_tech_rounded,
  ),
  AppNavDestination(
    route: AppRoutes.leaderboard,
    label: 'Leaderboard',
    icon: Icons.leaderboard_outlined,
    selectedIcon: Icons.leaderboard_rounded,
  ),
  AppNavDestination(
    route: AppRoutes.profile,
    label: 'Pengaturan / Profil',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  ),
];

/// Menentukan index item navigasi aktif berdasarkan path URI saat ini.
int resolveNavIndex(String location) {
  for (var i = 0; i < kAppNavDestinations.length; i++) {
    if (location == kAppNavDestinations[i].route) return i;
  }
  if (location == AppRoutes.progress || location == AppRoutes.about) {
    return 5;
  }
  return 0;
}

/// Sidebar navigasi penuh untuk layout desktop (serta isi Drawer pada mobile).
class SidebarNav extends StatelessWidget {
  const SidebarNav({super.key, required this.location, this.onNavigate});

  final String location;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = IsyaratifyColors.of(context);
    final progressCtrl = context.watch<ProgressController?>();
    final masteredCount = progressCtrl?.masteredLettersCount ?? 0;
    final dailyTarget = 5;
    final dailyDone = masteredCount.clamp(0, dailyTarget);
    final dailyFraction = dailyDone / dailyTarget;
    final dailyPct = (dailyFraction * 100).round();

    void navigateTo(String route) {
      onNavigate?.call();
      context.go(route);
    }

    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: ext.surfaceCard,
        border: Border(right: BorderSide(color: ext.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => navigateTo(AppRoutes.home),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: BrandLogo(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: kAppNavDestinations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = kAppNavDestinations[index];
                    final isSelected =
                        location == item.route ||
                        (item.route == AppRoutes.profile &&
                            location == AppRoutes.progress);

                    return _SidebarItem(
                      destination: item,
                      selected: isSelected,
                      onTap: () => navigateTo(item.route),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _AboutQuickLink(
                selected: location == AppRoutes.about,
                onTap: () => navigateTo(AppRoutes.about),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TARGET HARIAN',
                          style: AppTextStyles.labelSm.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '$dailyPct%',
                          style: AppTextStyles.labelSm.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppProgressBar(
                      value: dailyFraction,
                      height: 8,
                      fillColor: ext.headerIndigo,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$dailyDone dari $dailyTarget huruf BISINDO dikuasai',
                      style: AppTextStyles.bodySm.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = selected ? scheme.primaryContainer : Colors.transparent;
    final fgColor = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 20,
                color: fgColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(
                    color: fgColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutQuickLink extends StatelessWidget {
  const _AboutQuickLink({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryFixed.withValues(alpha: 0.45)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(
                Icons.groups_outlined,
                size: 18,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tentang Tim Pengembang',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd.copyWith(
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
