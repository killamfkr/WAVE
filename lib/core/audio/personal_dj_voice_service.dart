import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:edge_tts/edge_tts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/app_logger.dart';
import 'music_player_service.dart';
import 'personal_dj_service.dart';

/// Plays DJ voice lines using Microsoft Edge neural TTS (natural speech).
class PersonalDjVoiceService {
  PersonalDjVoiceService() {
    _player.stream.completed.listen((completed) {
      if (completed && _playbackDone != null && !_playbackDone!.isCompleted) {
        _playbackDone!.complete();
      }
    });
  }

  static const _voice = 'en-US-DavisNeural';

  final Player _player = Player();
  bool _speaking = false;
  Completer<void>? _playbackDone;
  int _fileCounter = 0;

  bool get isSpeaking => _speaking;

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
      final bytes = await Communicate(
        text: line,
        voice: _voice,
        rate: _rateFor(mood),
        pitch: '-1Hz',
        volume: '+0%',
      ).toBytes();

      if (bytes.isEmpty) {
        appLogger.w('DJ voice: empty audio for line');
        return;
      }

      final path = await _writeTempMp3(bytes);
      _playbackDone = Completer<void>();
      await _player.open(Media(path));
      await _player.play();
      await _playbackDone!.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          appLogger.w('DJ voice playback timed out');
          if (!(_playbackDone?.isCompleted ?? true)) {
            _playbackDone?.complete();
          }
        },
      );
    } catch (e) {
      appLogger.w('DJ voice failed: $e');
    } finally {
      _speaking = false;
      _playbackDone = null;
      if (duck && player != null && savedVolume != null) {
        await player.setVolume(savedVolume);
      }
    }
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
