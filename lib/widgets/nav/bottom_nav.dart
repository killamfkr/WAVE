import 'package:flutter/widgets.dart';

import '../../core/theme/app_theme.dart';
import 'nav_destination.dart';
import 'variants/aurora_bottom_nav.dart';
import 'variants/brutalist_bottom_nav.dart';
import 'variants/minimal_bottom_nav.dart';
import 'variants/neon_bottom_nav.dart';
import 'variants/obsidian_bottom_nav.dart';
import 'variants/vapor_bottom_nav.dart';

/// Renders the bottom-nav variant for the active theme. Every variant has
/// the same signature: `(theme, destinations, activeIndex, onSelected)`.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.theme,
    required this.activeIndex,
    required this.onSelected,
  });

  final AppTheme theme;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = kNavDestinations;
    switch (theme.id) {
      case AppThemeId.obsidian:
        return ObsidianBottomNav(
          theme: theme,
          destinations: destinations,
          activeIndex: activeIndex,
          onSelected: onSelected,
        );
      case AppThemeId.vapor:
        return VaporBottomNav(
          theme: theme,
          destinations: destinations,
          activeIndex: activeIndex,
          onSelected: onSelected,
        );
      case AppThemeId.brutalist:
        return BrutalistBottomNav(
          theme: theme,
          destinations: destinations,
          activeIndex: activeIndex,
          onSelected: onSelected,
        );
      case AppThemeId.aurora:
        return AuroraBottomNav(
          theme: theme,
          destinations: destinations,
          activeIndex: activeIndex,
          onSelected: onSelected,
        );
      case AppThemeId.neonGrid:
        return NeonBottomNav(
          theme: theme,
          destinations: destinations,
          activeIndex: activeIndex,
          onSelected: onSelected,
        );
      case AppThemeId.minimalMono:
        return MinimalBottomNav(
          theme: theme,
          destinations: destinations,
          activeIndex: activeIndex,
          onSelected: onSelected,
        );
    }
  }
}
