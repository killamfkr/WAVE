import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../api/models/player_state.dart';
import '../utils/app_logger.dart';
import 'dj_tts/dj_tts_config.dart';
import 'dj_tts/dj_tts_synthesizer.dart';
import 'music_player_service.dart';
import 'personal_dj_service.dart';

/// Plays DJ voice lines using cloud TTS APIs, Edge neural TTS, or on-device fallback.
class PersonalDjVoiceService {
  PersonalDjVoiceService({DjTtsSynthesizer? synthesizer})
      : _synthesizer = synthesizer ?? DjTtsSynthesizer() {
    _initFallbackTts();
    _player.stream.completed.listen((completed) {
      if (completed && _playbackDone != null && !_playbackDone!.isCompleted) {
        _playbackDone!.complete();
      }
    });
  }

  final DjTtsSynthesizer _synthesizer;
  final FlutterTts _fallbackTts = FlutterTts();
  final Player _player = Player();
  bool _speaking = false;
  bool _fallbackReady = false;
  Completer<void>? _playbackDone;
  int _fileCounter = 0;

  bool get isSpeaking => _speaking;

  Future<void> _initFallbackTts() async {
    try {
      await _fallbackTts.setLanguage('en-US');
      await _fallbackTts.setSpeechRate(0.56);
      await _fallbackTts.setPitch(0.85);
      await _fallbackTts.setVolume(1.0);
      await _fallbackTts.awaitSpeakCompletion(true);

      if (Platform.isIOS) {
        await _fallbackTts.setSharedInstance(true);
        await _fallbackTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          <IosTextToSpeechAudioCategoryOptions>[
            IosTextToSpeechAudioCategoryOptions.duckOthers,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
        );
      }

      final voice = await _pickFallbackMaleVoice();
      if (voice != null) {
        await _fallbackTts.setVoice(voice);
      }
      _fallbackReady = true;
    } catch (e) {
      appLogger.w('DJ fallback TTS init failed: $e');
    }
  }

  Future<Map<String, String>?> _pickFallbackMaleVoice() async {
    final voices = await _fallbackTts.getVoices;
    if (voices is! List) return null;

    Map<dynamic, dynamic>? best;
    var bestScore = -1;
    for (final voice in voices) {
      if (voice is! Map) continue;
      final locale = (voice['locale'] ?? '').toString().toLowerCase();
      if (!locale.startsWith('en')) continue;

      final name = (voice['name'] ?? '').toString();
      final lower = name.toLowerCase();
      final gender = (voice['gender'] ?? '').toString().toLowerCase();

      if (gender == 'female' || _isFemaleVoiceName(lower)) continue;
      if (lower.contains('#female')) continue;

      final isMale = gender == 'male' ||
          lower.contains('#male') ||
          _isPreferredMaleVoiceName(lower);
      if (!isMale) continue;

      var score = 0;
      if (lower.contains('neural')) score += 50;
      if (lower.contains('enhanced')) score += 40;
      if (locale.contains('us')) score += 10;
      if (lower.contains('andrew')) score += 80;
      if (lower.contains('christopher')) score += 70;
      if (lower.contains('guy')) score += 55;
      if (gender == 'male') score += 30;
      if (lower.contains('#male')) score += 25;

      if (score > bestScore) {
        bestScore = score;
        best = voice;
      }
    }

    if (best == null) return null;
    return <String, String>{
      'name': best['name']?.toString() ?? '',
      'locale': best['locale']?.toString() ?? 'en-US',
    };
  }

  Future<void> speak(
    String text, {
    MusicPlayerService? player,
    PersonalDjMood mood = PersonalDjMood.mixed,
    required DjTtsConfig ttsConfig,
  }) async {
    final line = text.trim();
    if (line.isEmpty) return;

    await stop();

    var resumeMusic = false;
    if (player != null) {
      resumeMusic = player.playerState.status == PlaybackStatus.playing;
      if (resumeMusic) {
        await player.pause();
      }
    }

    _speaking = true;
    try {
      final bytes = await _synthesizer.synthesize(
        text: line,
        config: ttsConfig,
        mood: mood,
      );

      if (bytes.isNotEmpty) {
        await _playMp3(bytes);
      } else {
        appLogger.w('Cloud DJ voice empty — using on-device male fallback');
        await _speakFallback(line);
      }
    } catch (e) {
      appLogger.w('DJ voice failed, using fallback: $e');
      await _speakFallback(line);
    } finally {
      _speaking = false;
      _playbackDone = null;
      if (resumeMusic && player != null) {
        await player.play();
      }
    }
  }

  Future<void> _playMp3(Uint8List bytes) async {
    final path = await _writeTempMp3(bytes);
    _playbackDone = Completer<void>();
    await _player.setVolume(100);
    await _player.open(Media(path), play: true);

    await _player.stream.playing.firstWhere((playing) => playing);
    final duration = _player.state.duration;
    if (duration > Duration.zero) {
      await Future<void>.delayed(duration + const Duration(milliseconds: 200));
    } else {
      await _playbackDone!.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          if (!(_playbackDone?.isCompleted ?? true)) {
            _playbackDone?.complete();
          }
        },
      );
    }
  }

  Future<void> _speakFallback(String line) async {
    if (!_fallbackReady) await _initFallbackTts();
    final done = Completer<void>();
    _fallbackTts.setCompletionHandler(() {
      if (!done.isCompleted) done.complete();
    });
    await _fallbackTts.speak(line);
    await done.future.timeout(const Duration(seconds: 45));
  }

  bool _isPreferredMaleVoiceName(String name) => <String>[
        'andrew',
        'christopher',
        'guy',
        'jason',
        'brian',
        'davis',
        'daniel',
        'eric',
        'tony',
        'steffan',
        'brandon',
        'ryan',
        'roger',
      ].any(name.contains);

  bool _isFemaleVoiceName(String name) => <String>[
        'jenny',
        'aria',
        'sara',
        'michelle',
        'emma',
        'ana',
        'natasha',
        'ava',
        'jane',
        'nancy',
        'female',
        'karen',
        'samantha',
        'victoria',
        'zira',
      ].any(name.contains);

  Future<String> _writeTempMp3(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'wave_dj_${_fileCounter++}.mp3');
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<void> stop() async {
    if (_speaking) {
      await _player.stop();
      await _fallbackTts.stop();
    }
    _speaking = false;
    if (!(_playbackDone?.isCompleted ?? true)) {
      _playbackDone?.complete();
    }
    _playbackDone = null;
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
