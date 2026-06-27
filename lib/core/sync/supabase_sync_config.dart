import 'package:flutter/services.dart' show rootBundle;

import '../utils/app_logger.dart';

/// Shared PlayTorrio Supabase project — same as PlayTorrioV2 and Stories.
class SupabaseSyncConfig {
  SupabaseSyncConfig._();

  static const String _envUrlKey = 'PLAYTORRIO_SUPABASE_URL';
  static const String _envAnonKey = 'PLAYTORRIO_SUPABASE_ANON_KEY';

  static String? url;
  static String? anonKey;

  static bool get isConfigured =>
      (url ?? '').trim().isNotEmpty && (anonKey ?? '').trim().isNotEmpty;

  static bool get isAnonKeyJwtFormat {
    final k = anonKey;
    if (k == null || k.isEmpty) return false;
    return k.split('.').length == 3 && k.startsWith('eyJ');
  }

  static Future<void> loadEnv() async {
    url = const String.fromEnvironment(_envUrlKey);
    anonKey = const String.fromEnvironment(_envAnonKey);

    if (url != null && url!.isNotEmpty && anonKey != null && anonKey!.isNotEmpty) {
      appLogger.i('Loaded Supabase config from dart-define');
      return;
    }

    try {
      final content = await rootBundle.loadString('.env');
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length < 2) continue;
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        if (value.isEmpty) continue;
        if (key == _envUrlKey) url = value;
        if (key == _envAnonKey) anonKey = value;
      }
      if (isConfigured) {
        appLogger.i('Loaded Supabase config from .env');
      }
    } catch (e) {
      appLogger.w('Could not load Supabase config from .env: $e');
    }
  }
}
