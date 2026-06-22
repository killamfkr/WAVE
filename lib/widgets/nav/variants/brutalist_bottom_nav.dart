import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../nav_destination.dart';

/// Brutalist theme: thick black bar, uppercase text, no animation on switch.
class BrutalistBottomNav extends StatelessWidget {
  const BrutalistBottomNav({
    super.key,
    required this.theme,
    required this.destinations,
    required this.activeIndex,
    required this.onSelected,
  });

  final AppTheme theme;
  final List<NavDestination> destinations;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.onSurface,
        border: Border(top: BorderSide(color: theme.onSurface, width: 4)),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < destinations.length; i++) ...<Widget>[
            Expanded(
              child: _BrutalistTab(
                theme: theme,
                label: destinations[i].label,
                active: i == activeIndex,
                onTap: () => onSelected(i),
              ),
            ),
            if (i < destinations.length - 1)
              Container(width: 2, height: 32, color: theme.background),
          ],
        ],
      ),
    );
  }
}

class _BrutalistTab extends StatelessWidget {
  const _BrutalistTab({
    required this.theme,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final AppTheme theme;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: active ? theme.accent : theme.onSurface,
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: active ? theme.onSurface : theme.background,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
