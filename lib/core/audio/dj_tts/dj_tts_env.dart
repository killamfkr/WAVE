import 'package:flutter/services.dart' show rootBundle;

import '../../utils/app_logger.dart';

/// Optional build-time TTS keys from `.env` (overridden by user keys in secure storage).
class DjTtsEnv {
  DjTtsEnv._();

  static String? openAiApiKey;
  static String? elevenLabsApiKey;

  static Future<void> loadEnv() async {
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
        switch (key) {
          case 'OPENAI_API_KEY':
            openAiApiKey = value;
          case 'ELEVENLABS_API_KEY':
            elevenLabsApiKey = value;
        }
      }
    } catch (e) {
      appLogger.w('Could not load .env for DJ TTS keys: $e');
    }
  }
}
