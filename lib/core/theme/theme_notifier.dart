import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../storage/hive_boxes.dart';
import 'app_theme.dart';
import 'themes.dart';

/// Persists and exposes the currently selected [AppTheme].
///
/// The active theme id is stored in the [HiveBoxes.settings] box under
/// the [_themeKey] key.
class ThemeNotifier extends Notifier<AppTheme> {
  static const String _themeKey = 'active_theme_id';

  @override
  AppTheme build() {
    final box = Hive.box<dynamic>(HiveBoxes.settings);
    final stored = box.get(_themeKey) as String?;
    if (stored == null) return AppThemes.obsidian;
    final id = AppThemeId.values.firstWhere(
      (e) => e.name == stored,
      orElse: () => AppThemeId.obsidian,
    );
    return AppThemes.byId(id);
  }

  Future<void> setTheme(AppThemeId id) async {
    final next = AppThemes.byId(id);
    state = next;
    final box = Hive.box<dynamic>(HiveBoxes.settings);
    await box.put(_themeKey, id.name);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppTheme>(
  ThemeNotifier.new,
);
