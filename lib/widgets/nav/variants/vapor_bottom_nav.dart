import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../nav_destination.dart';

/// Glassmorphic floating pill nav for the Vapor theme.
class VaporBottomNav extends StatelessWidget {
  const VaporBottomNav({
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _VaporTab(
                      theme: theme,
                      destination: destinations[i],
                      active: i == activeIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VaporTab extends StatelessWidget {
  const _VaporTab({
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: theme.fastDuration,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: active
              ? LinearGradient(
                  colors: <Color>[
                    theme.accent.withValues(alpha: 0.4),
                    const Color(0xFF00FFFF).withValues(alpha: 0.3),
                  ],
                )
              : null,
          boxShadow: active
              ? <BoxShadow>[
                  BoxShadow(
                    color: theme.accent.withValues(alpha: 0.4),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              active ? destination.iconFilled : destination.icon,
              size: 22,
              color: active ? Colors.white : theme.onSurfaceMuted,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? Colors.white : theme.onSurfaceMuted,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
