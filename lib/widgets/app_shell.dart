import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_breakpoints.dart';
import 'mini_player.dart';
import 'nav/bottom_nav.dart';
import 'nav/desktop_sidebar.dart';
import 'nav/nav_destination.dart';

/// Persistent app shell that wires the active tab content with the
/// theme-aware bottom navigation (mobile/tablet) or the left sidebar
/// (desktop), plus the persistent mini-player.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final activeIndex = _activeTabIndex(context);

    void onSelected(int i) {
      final route = kNavDestinations[i].route;
      GoRouter.of(context).go(route);
    }

    if (isDesktop) {
      return Material(
        type: MaterialType.canvas,
        color: theme.background,
        child: Row(
          children: <Widget>[
            DesktopSidebar(
              theme: theme,
              activeIndex: activeIndex,
              onSelected: onSelected,
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: child),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MiniPlayer(theme: theme),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      type: MaterialType.canvas,
      color: theme.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Expanded(child: child),
            MiniPlayer(theme: theme),
            AppBottomNav(
              theme: theme,
              activeIndex: activeIndex,
              onSelected: onSelected,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

int _activeTabIndex(BuildContext context) {
  final location = GoRouterState.of(context).matchedLocation;
  if (location.startsWith(AppRoutes.discover)) return 1;
  if (location.startsWith(AppRoutes.search)) return 2;
  if (location.startsWith(AppRoutes.library)) return 3;
  return 0;
}
