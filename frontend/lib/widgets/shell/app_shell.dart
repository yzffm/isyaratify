import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
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
        bottomNavigationBar: layoutSize == AppLayoutSize.compact
          ? Container(
              color: const Color(0xFF1E1E2C), 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: GNav(
                  backgroundColor: const Color(0xFF1E1E2C),
                  color: Colors.white54,
                  activeColor: Colors.white,
                  tabBackgroundColor: const Color(0xFF434371),
                  gap: 8,
                  padding: const EdgeInsets.all(12),
                  selectedIndex: selectedIndex, 
                  tabs: const [
                    GButton(icon: Icons.grid_view_rounded, text: 'Dashboard'),
                    GButton(icon: Icons.menu_book_rounded, text: 'Kamus'),
                    GButton(icon: Icons.videocam_rounded, text: 'Latihan'),
                    GButton(icon: Icons.person_rounded, text: 'Profil'),
                  ],
                  onTabChange: (index) {
                    switch (index) {
                      case 0: context.go('/home'); break;
                      case 1: context.go('/dictionary'); break;
                      case 2: context.go('/practice'); break;
                      case 3: context.go('/profile'); break;
                    }
                  },
                ),
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
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ext.headerIndigo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sign_language_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
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
