import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/app_logger.dart';
import 'music_player_service.dart';
import 'personal_dj_service.dart';
import 'wave_edge_tts.dart';

/// Plays DJ voice lines using Edge neural TTS, with on-device TTS fallback.
class PersonalDjVoiceService {
  PersonalDjVoiceService() {
    _initFallbackTts();
    _player.stream.completed.listen((completed) {
      if (completed && _playbackDone != null && !_playbackDone!.isCompleted) {
        _playbackDone!.complete();
      }
    });
  }

  final WaveEdgeTts _edge = WaveEdgeTts();
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
      await _fallbackTts.setSpeechRate(0.48);
      await _fallbackTts.setPitch(0.95);
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

      final voices = await _fallbackTts.getVoices;
      if (voices is List) {
        Map<dynamic, dynamic>? best;
        var bestScore = -1;
        for (final voice in voices) {
          if (voice is! Map) continue;
          final locale = (voice['locale'] ?? '').toString().toLowerCase();
          if (!locale.startsWith('en')) continue;
          final name = (voice['name'] ?? '').toString().toLowerCase();
          var score = 0;
          if (name.contains('neural')) score += 50;
          if (name.contains('enhanced')) score += 40;
          if (locale.contains('us')) score += 10;
          if (score > bestScore) {
            bestScore = score;
            best = voice;
          }
        }
        if (best != null) {
          await _fallbackTts.setVoice(<String, String>{
            'name': best['name']?.toString() ?? '',
            'locale': best['locale']?.toString() ?? 'en-US',
          });
        }
      }
      _fallbackReady = true;
    } catch (e) {
      appLogger.w('DJ fallback TTS init failed: $e');
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

    await stop();

    double? savedVolume;
    if (duck && player != null) {
      savedVolume = player.playerState.volume;
      await player.setVolume((savedVolume * 0.1).clamp(0.0, 1.0));
    }

    _speaking = true;
    try {
      await _activateVoiceSession();

      final bytes = await _edge.synthesize(
        line,
        rate: _rateFor(mood),
        pitch: '+0Hz',
      );

      if (bytes.isNotEmpty) {
        await _playMp3(bytes);
      } else {
        appLogger.w('Edge DJ voice empty — using on-device fallback');
        await _speakFallback(line);
      }
    } catch (e) {
      appLogger.w('DJ voice failed, using fallback: $e');
      await _speakFallback(line);
    } finally {
      _speaking = false;
      _playbackDone = null;
      if (duck && player != null && savedVolume != null) {
        await player.setVolume(savedVolume);
      }
    }
  }

  Future<void> _activateVoiceSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.duckOthers |
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.assistanceNavigationGuidance,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ));
      await session.setActive(true);
    } catch (e) {
      appLogger.w('DJ voice session setup failed: $e');
    }
  }

  Future<void> _playMp3(Uint8List bytes) async {
    final path = await _writeTempMp3(bytes);
    _playbackDone = Completer<void>();
    await _player.setVolume(100);
    await _player.open(Media(path), play: true);

    // Wait until playback actually starts, then until it completes.
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

  String _rateFor(PersonalDjMood mood) => switch (mood) {
        PersonalDjMood.chill => '-6%',
        PersonalDjMood.hype => '+14%',
        PersonalDjMood.discover => '+2%',
        PersonalDjMood.mixed => '+6%',
      };

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
