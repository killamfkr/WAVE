import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Registry of all six built-in themes.
class AppThemes {
  AppThemes._();

  static const AppTheme obsidian = AppTheme(
    id: AppThemeId.obsidian,
    name: 'Obsidian',
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF0D0D0D),
    onSurface: Color(0xFFF5F0E8),
    onSurfaceMuted: Color(0xFF8A857D),
    accent: Color(0xFFC9A84C),
    error: Color(0xFFE05A47),
    displayFont: 'Cormorant Garamond',
    bodyFont: 'DM Sans',
    cardStyle: CardStyle.sharp,
    cardRadius: 0,
    animation: AnimationPersonality.smooth,
    fastDuration: Duration(milliseconds: 200),
    normalDuration: Duration(milliseconds: 400),
    slowDuration: Duration(milliseconds: 600),
    defaultCurve: Curves.easeOutCubic,
  );

  static const AppTheme vapor = AppTheme(
    id: AppThemeId.vapor,
    name: 'Vapor',
    brightness: Brightness.dark,
    background: Color(0xFF0B0B1A),
    surface: Color(0x14FFFFFF),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceMuted: Color(0xB3FFFFFF),
    accent: Color(0xFFFF6EFF),
    error: Color(0xFFFF5577),
    displayFont: 'Space Grotesk',
    bodyFont: 'Inter',
    cardStyle: CardStyle.glass,
    cardRadius: 20,
    animation: AnimationPersonality.floaty,
    fastDuration: Duration(milliseconds: 250),
    normalDuration: Duration(milliseconds: 450),
    slowDuration: Duration(milliseconds: 700),
    defaultCurve: Curves.easeOutBack,
  );

  static const AppTheme brutalist = AppTheme(
    id: AppThemeId.brutalist,
    name: 'Brutalist',
    brightness: Brightness.light,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    onSurfaceMuted: Color(0xFF555555),
    accent: Color(0xFFFFE500),
    error: Color(0xFFFF0000),
    displayFont: 'Anton',
    bodyFont: 'Courier Prime',
    cardStyle: CardStyle.brutal,
    cardRadius: 0,
    animation: AnimationPersonality.instant,
    fastDuration: Duration(milliseconds: 80),
    normalDuration: Duration(milliseconds: 150),
    slowDuration: Duration(milliseconds: 200),
    defaultCurve: Curves.linear,
  );

  static const AppTheme aurora = AppTheme(
    id: AppThemeId.aurora,
    name: 'Aurora',
    brightness: Brightness.dark,
    background: Color(0xFF0A1628),
    surface: Color(0xFF12233B),
    onSurface: Color(0xFFF5ECD7),
    onSurfaceMuted: Color(0xFF8FAF8F),
    accent: Color(0xFFE8A445),
    error: Color(0xFFE57373),
    displayFont: 'Lora',
    bodyFont: 'Nunito',
    cardStyle: CardStyle.organic,
    cardRadius: 16,
    animation: AnimationPersonality.smooth,
    fastDuration: Duration(milliseconds: 220),
    normalDuration: Duration(milliseconds: 400),
    slowDuration: Duration(milliseconds: 700),
    defaultCurve: Curves.elasticOut,
  );

  static const AppTheme neonGrid = AppTheme(
    id: AppThemeId.neonGrid,
    name: 'Neon Grid',
    brightness: Brightness.dark,
    background: Color(0xFF080808),
    surface: Color(0xFF101018),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceMuted: Color(0xFF808095),
    accent: Color(0xFFFF0080),
    error: Color(0xFFFF3344),
    displayFont: 'Orbitron',
    bodyFont: 'Roboto Mono',
    cardStyle: CardStyle.neonOutline,
    cardRadius: 4,
    animation: AnimationPersonality.punchy,
    fastDuration: Duration(milliseconds: 100),
    normalDuration: Duration(milliseconds: 200),
    slowDuration: Duration(milliseconds: 300),
    defaultCurve: Curves.easeOutQuart,
  );

  static const AppTheme minimalMono = AppTheme(
    id: AppThemeId.minimalMono,
    name: 'Minimal Mono',
    brightness: Brightness.light,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    onSurfaceMuted: Color(0x991A1A1A),
    accent: Color(0xFF1A1A1A),
    error: Color(0xFFB00020),
    displayFont: 'DM Sans',
    bodyFont: 'DM Sans',
    cardStyle: CardStyle.hairline,
    cardRadius: 0,
    animation: AnimationPersonality.crossfade,
    fastDuration: Duration(milliseconds: 200),
    normalDuration: Duration(milliseconds: 300),
    slowDuration: Duration(milliseconds: 1000),
    defaultCurve: Curves.easeInOut,
  );

  static const List<AppTheme> all = <AppTheme>[
    obsidian,
    vapor,
    brutalist,
    aurora,
    neonGrid,
    minimalMono,
  ];

  static AppTheme byId(AppThemeId id) =>
      all.firstWhere((t) => t.id == id, orElse: () => obsidian);
}
