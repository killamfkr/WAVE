import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../nav_destination.dart';

/// Obsidian theme: minimal text-only tabs in small caps with a thin gold
/// underline indicator that animates between tabs.
class ObsidianBottomNav extends StatelessWidget {
  const ObsidianBottomNav({
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
        color: theme.background,
        border: Border(
          top: BorderSide(
            color: theme.accent.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final tabWidth = c.maxWidth / destinations.length;
          return Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: theme.normalDuration,
                curve: theme.defaultCurve,
                left: tabWidth * activeIndex + tabWidth * 0.25,
                top: 0,
                child: Container(
                  height: 1,
                  width: tabWidth * 0.5,
                  color: theme.accent,
                ),
              ),
              Row(
                children: <Widget>[
                  for (int i = 0; i < destinations.length; i++)
                    Expanded(
                      child: _ObsidianTab(
                        theme: theme,
                        label: destinations[i].label,
                        active: i == activeIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ObsidianTab extends StatelessWidget {
  const _ObsidianTab({
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
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: theme.normalDuration,
          curve: theme.defaultCurve,
          style: TextStyle(
            color: active ? theme.accent : theme.onSurfaceMuted,
            fontSize: active ? 12 : 10.5,
            fontWeight: FontWeight.w500,
            letterSpacing: active ? 4 : 2.5,
          ),
          child: Text(label.toUpperCase()),
        ),
      ),
    );
  }
}
