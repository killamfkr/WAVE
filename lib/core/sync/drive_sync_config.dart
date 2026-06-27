import 'package:flutter/services.dart' show rootBundle;

import '../utils/app_logger.dart';

/// Google OAuth / Drive sync configuration loaded from `.env`.
class DriveSyncConfig {
  DriveSyncConfig._();

  /// Web client ID — required on Android/iOS for Google Sign-In token exchange.
  static String? webClientId;

  static bool get isConfigured =>
      webClientId != null && webClientId!.trim().isNotEmpty;

  static Future<void> loadEnv() async {
    try {
      final content = await rootBundle.loadString('.env');
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          if (key == 'GOOGLE_WEB_CLIENT_ID' && value.isNotEmpty) {
            webClientId = value;
            appLogger.i('Loaded GOOGLE_WEB_CLIENT_ID for Drive sync');
          }
        }
      }
    } catch (e) {
      appLogger.w('Could not load Drive sync config from .env: $e');
    }
  }
}
