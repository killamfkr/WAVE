import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../nav_destination.dart';

/// Neon Grid theme: dark strip, glowing icon for active tab, an animated
/// horizontal glow that slides between tabs.
class NeonBottomNav extends StatelessWidget {
  const NeonBottomNav({
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
      height: 60,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          top: BorderSide(color: theme.accent.withValues(alpha: 0.3), width: 1),
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
                left: tabWidth * activeIndex,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: <Color>[
                          theme.accent.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  for (int i = 0; i < destinations.length; i++)
                    Expanded(
                      child: _NeonTab(
                        theme: theme,
                        destination: destinations[i],
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

class _NeonTab extends StatelessWidget {
  const _NeonTab({
    required this.theme,
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final AppTheme theme;
  final NavDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? theme.accent : theme.onSurfaceMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: theme.fastDuration,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: active
                ? <BoxShadow>[
                    BoxShadow(
                      color: theme.accent.withValues(alpha: 0.7),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            active ? destination.iconFilled : destination.icon,
            size: 22,
            color: color,
          ),
        ),
      ),
    );
  }
}
