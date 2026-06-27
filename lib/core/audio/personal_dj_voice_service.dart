import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import '../utils/app_logger.dart';
import 'music_player_service.dart';
import 'personal_dj_service.dart';
import 'personal_dj_speech.dart';

/// Speaks Personal DJ liners with paced delivery and music ducking.
class PersonalDjVoiceService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _speaking = false;
  PersonalDjMood _mood = PersonalDjMood.mixed;
  Completer<void>? _completion;

  bool get isSpeaking => _speaking;

  Future<void> _ensureReady({PersonalDjMood mood = PersonalDjMood.mixed}) async {
    if (_ready && _mood == mood) return;
    _mood = mood;

    await _tts.setLanguage('en-US');
    await _applyMoodVoice(mood);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _pickBestVoice();

    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        <IosTextToSpeechAudioCategoryOptions>[
          IosTextToSpeechAudioCategoryOptions.duckOthers,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );
    }

    if (Platform.isAndroid) {
      await _tts.setQueueMode(1);
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

  Future<void> _applyMoodVoice(PersonalDjMood mood) async {
    switch (mood) {
      case PersonalDjMood.chill:
        await _tts.setSpeechRate(0.44);
        await _tts.setPitch(0.92);
      case PersonalDjMood.hype:
        await _tts.setSpeechRate(0.51);
        await _tts.setPitch(1.02);
      case PersonalDjMood.discover:
        await _tts.setSpeechRate(0.47);
        await _tts.setPitch(1.0);
      case PersonalDjMood.mixed:
        await _tts.setSpeechRate(0.48);
        await _tts.setPitch(0.97);
    }
  }

  Future<void> _pickBestVoice() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return;

      Map<dynamic, dynamic>? best;
      var bestScore = -1;

      for (final voice in raw) {
        if (voice is! Map) continue;
        final locale = (voice['locale'] ?? '').toString().toLowerCase();
        if (!locale.startsWith('en')) continue;

        final name = (voice['name'] ?? '').toString().toLowerCase();
        var score = 0;
        if (name.contains('neural')) score += 60;
        if (name.contains('enhanced')) score += 50;
        if (name.contains('premium')) score += 45;
        if (name.contains('wavenet')) score += 40;
        if (name.contains('network')) score += 25;
        if (locale.contains('us')) score += 12;
        if (name.contains('sfg') || name.contains('iom')) score += 8;
        if (name.contains('male')) score += 4;
        if (name.contains('female')) score += 2;
        if (name.contains('local') && !name.contains('network')) score -= 8;

        if (score > bestScore) {
          bestScore = score;
          best = voice;
        }
      }

      if (best != null) {
        await _tts.setVoice(<String, String>{
          'name': best['name']?.toString() ?? '',
          'locale': best['locale']?.toString() ?? 'en-US',
        });
        appLogger.i('DJ voice: ${best['name']}');
      }
    } catch (e) {
      appLogger.w('Could not pick DJ voice: $e');
    }
  }

  Future<void> speak(
    String text, {
    MusicPlayerService? player,
    bool duck = false,
    PersonalDjMood mood = PersonalDjMood.mixed,
  }) async {
    final line = text.trim();
    if (line.isEmpty) return;

    await _ensureReady(mood: mood);
    await stop();

    double? savedVolume;
    if (duck && player != null) {
      savedVolume = player.playerState.volume;
      await player.setVolume((savedVolume * 0.12).clamp(0.0, 1.0));
    }

    _speaking = true;
    try {
      final phrases = PersonalDjSpeech.phrasesForDelivery(line);
      for (var i = 0; i < phrases.length; i++) {
        if (i > 0) {
          await Future<void>.delayed(const Duration(milliseconds: 320));
        }
        await _speakPhrase(phrases[i]);
      }
    } catch (e) {
      appLogger.w('DJ voice failed: $e');
    } finally {
      _speaking = false;
      if (duck && player != null && savedVolume != null) {
        await player.setVolume(savedVolume);
      }
    }
  }

  Future<void> _speakPhrase(String phrase) async {
    _completion = Completer<void>();
    await _tts.speak(phrase);
    await _completion!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => appLogger.w('DJ TTS phrase timed out'),
    );
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
