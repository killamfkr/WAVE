import 'dart:typed_data';

import '../../utils/app_logger.dart';
import '../personal_dj_service.dart';
import '../wave_edge_tts.dart';
import 'dj_tts_config.dart';
import 'dj_tts_provider.dart';
import 'elevenlabs_tts_client.dart';
import 'openai_tts_client.dart';

/// Routes DJ lines to the selected cloud TTS provider with free fallbacks.
class DjTtsSynthesizer {
  DjTtsSynthesizer({
    OpenAiTtsClient? openAi,
    ElevenLabsTtsClient? elevenLabs,
  })  : _openAi = openAi ?? OpenAiTtsClient(),
        _elevenLabs = elevenLabs ?? ElevenLabsTtsClient();

  final OpenAiTtsClient _openAi;
  final ElevenLabsTtsClient _elevenLabs;

  Future<Uint8List> synthesize({
    required String text,
    required DjTtsConfig config,
    required PersonalDjMood mood,
  }) async {
    final line = text.trim();
    if (line.isEmpty) return Uint8List(0);

    if (config.provider == DjTtsProvider.openai && config.hasOpenAiKey) {
      try {
        final bytes = await _openAi.synthesize(
          apiKey: config.openAiKey!,
          text: line,
          voice: config.openAiVoice,
          instructions: config.openAiInstructions,
          mood: mood,
        );
        if (bytes.isNotEmpty) return bytes;
      } catch (e) {
        appLogger.w('OpenAI DJ TTS failed, falling back: $e');
      }
    }

    if (config.provider == DjTtsProvider.elevenlabs &&
        config.hasElevenLabsKey) {
      try {
        final bytes = await _elevenLabs.synthesize(
          apiKey: config.elevenLabsKey!,
          voiceId: config.elevenLabsVoiceId,
          text: line,
          mood: mood,
        );
        if (bytes.isNotEmpty) return bytes;
      } catch (e) {
        appLogger.w('ElevenLabs DJ TTS failed, falling back: $e');
      }
    }

    return _synthesizeEdge(line, mood);
  }

  Future<Uint8List> _synthesizeEdge(String line, PersonalDjMood mood) async {
    for (final voice in WaveEdgeTts.preferredMaleVoices) {
      try {
        final bytes = await WaveEdgeTts(voice: voice).synthesize(
          line,
          rate: _edgeRateFor(mood),
          pitch: '-4Hz',
        );
        if (bytes.isNotEmpty) {
          if (voice != WaveEdgeTts.defaultVoice) {
            appLogger.w('DJ Edge voice fell back to $voice');
          }
          return bytes;
        }
      } catch (e) {
        appLogger.w('Edge voice $voice failed: $e');
      }
    }
    return Uint8List(0);
  }

  String _edgeRateFor(PersonalDjMood mood) => switch (mood) {
        PersonalDjMood.chill => '+12%',
        PersonalDjMood.hype => '+26%',
        PersonalDjMood.discover => '+16%',
        PersonalDjMood.mixed => '+20%',
      };
}
