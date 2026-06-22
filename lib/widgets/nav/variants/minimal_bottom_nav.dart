import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../nav_destination.dart';

/// Minimal Mono theme: text-only labels, the only visual change between
/// active/inactive is the font weight.
class MinimalBottomNav extends StatelessWidget {
  const MinimalBottomNav({
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
      height: 52,
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(
          top: BorderSide(color: const Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < destinations.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(i),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: theme.normalDuration,
                    style: TextStyle(
                      color: theme.onSurface,
                      fontSize: 13,
                      fontWeight: i == activeIndex
                          ? FontWeight.w700
                          : FontWeight.w300,
                      letterSpacing: 0.2,
                    ),
                    child: Text(destinations[i].label),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
