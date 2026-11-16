import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../brand/brand_logo.dart';
import 'sidebar_nav.dart';
import 'top_bar.dart';

/// Kerangka navigasi persisten aplikasi untuk halaman terautentikasi:
/// - Desktop (`>= 1100`): Sidebar kiri penuh + TopBar
/// - Tablet (`700 .. < 1100`): NavigationRail ringkas + TopBar
/// - Mobile (`< 700`): TopBar dengan tombol Drawer + Drawer samping
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final layoutSize = AppBreakpoints.of(context);
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final selectedIndex = resolveNavIndex(widget.location);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ext.surfaceCanvas,
      drawer: layoutSize == AppLayoutSize.compact
          ? Drawer(
              child: SidebarNav(
                location: widget.location,
                onNavigate: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (layoutSize == AppLayoutSize.expanded)
            SidebarNav(location: widget.location)
          else if (layoutSize == AppLayoutSize.medium)
            Container(
              decoration: BoxDecoration(
                color: ext.surfaceCard,
                border: Border(right: BorderSide(color: ext.borderSubtle)),
              ),
              child: SafeArea(
                child: NavigationRail(
                  backgroundColor: Colors.transparent,
                  selectedIndex: selectedIndex,
                  labelType: NavigationRailLabelType.none,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go(AppRoutes.home),
                      child: const BrandLogoBadge(size: 40, padding: 5),
                    ),
                  ),
                  onDestinationSelected: (idx) {
                    context.go(kAppNavDestinations[idx].route);
                  },
                  destinations: kAppNavDestinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Semantics(
                            label: item.label,
                            child: Tooltip(
                              message: item.label,
                              child: Icon(item.icon),
                            ),
                          ),
                          selectedIcon: Semantics(
                            label: item.label,
                            child: Tooltip(
                              message: item.label,
                              child: Icon(
                                item.selectedIcon,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          label: const SizedBox.shrink(),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TopBar(
                  currentLocation: widget.location,
                  onMenuPressed: layoutSize == AppLayoutSize.compact
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
