import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import '../utils/app_logger.dart';
import 'music_player_service.dart';

/// Speaks Personal DJ liners using system text-to-speech, ducking music while talking.
class PersonalDjVoiceService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _speaking = false;
  Completer<void>? _completion;

  bool get isSpeaking => _speaking;

  Future<void> _ensureReady() async {
    if (_ready) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(0.95);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);

    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        <IosTextToSpeechAudioCategoryOptions>[
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
      );
    }

    _tts.setCompletionHandler(() {
      if (!(_completion?.isCompleted ?? true)) {
        _completion?.complete();
      }
    });
    _tts.setErrorHandler((msg) {
      appLogger.w('DJ TTS error: $msg');
      if (!(_completion?.isCompleted ?? true)) {
        _completion?.complete();
      }
    });

    _ready = true;
  }

  Future<void> speak(
    String text, {
    MusicPlayerService? player,
    bool duck = false,
  }) async {
    final line = text.trim();
    if (line.isEmpty) return;

    await _ensureReady();
    await stop();

    double? savedVolume;
    if (duck && player != null) {
      savedVolume = player.playerState.volume;
      await player.setVolume((savedVolume * 0.14).clamp(0.0, 1.0));
    }

    _speaking = true;
    _completion = Completer<void>();
    try {
      await _tts.speak(line);
      await _completion!.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () => appLogger.w('DJ TTS timed out'),
      );
    } catch (e) {
      appLogger.w('DJ voice failed: $e');
    } finally {
      _speaking = false;
      if (duck && player != null && savedVolume != null) {
        await player.setVolume(savedVolume);
      }
    }
  }

  Future<void> stop() async {
    if (_speaking) {
      await _tts.stop();
    }
    _speaking = false;
    if (!(_completion?.isCompleted ?? true)) {
      _completion?.complete();
    }
    _completion = null;
  }
}
