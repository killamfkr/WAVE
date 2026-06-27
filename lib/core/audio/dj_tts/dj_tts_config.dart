import '../../storage/settings_providers.dart';
import '../personal_dj_service.dart';
import 'dj_tts_key_store.dart';
import 'dj_tts_provider.dart';

class DjTtsConfig {
  const DjTtsConfig({
    required this.provider,
    this.openAiKey,
    this.elevenLabsKey,
    this.openAiVoice = 'onyx',
    this.elevenLabsVoiceId = DjTtsPresets.elevenLabsJosh,
    this.openAiInstructions = DjTtsPresets.defaultDjInstructions,
  });

  final DjTtsProvider provider;
  final String? openAiKey;
  final String? elevenLabsKey;
  final String openAiVoice;
  final String elevenLabsVoiceId;
  final String openAiInstructions;

  bool get hasOpenAiKey => openAiKey != null && openAiKey!.isNotEmpty;
  bool get hasElevenLabsKey =>
      elevenLabsKey != null && elevenLabsKey!.isNotEmpty;

  static Future<DjTtsConfig> resolve({
    required AppSettings settings,
    required DjTtsKeyStore keyStore,
  }) async {
    return DjTtsConfig(
      provider: settings.djTtsProvider,
      openAiKey: await keyStore.openAiKey(),
      elevenLabsKey: await keyStore.elevenLabsKey(),
      openAiVoice: settings.djOpenAiVoice,
      elevenLabsVoiceId: settings.djElevenLabsVoiceId,
      openAiInstructions: settings.djOpenAiInstructions,
    );
  }
}

class DjTtsPresets {
  DjTtsPresets._();

  static const defaultDjInstructions =
      'Speak like a confident Black male radio DJ with a deep baritone voice. '
      'Natural, warm, and upbeat — never robotic.';

  /// ElevenLabs "Josh" — deep male voice.
  static const elevenLabsJosh = 'TxGEqnHWrfWFTfGW9XjX';

  /// ElevenLabs "Adam" — clear male voice.
  static const elevenLabsAdam = 'pNInz6obpgDQGcFmaJgB';

  static const openAiVoices = <String>[
    'onyx',
    'echo',
    'ash',
    'cedar',
    'fable',
    'alloy',
  ];

  static const elevenLabsVoices = <Map<String, String>>[
    <String, String>{'name': 'Josh (deep male)', 'id': elevenLabsJosh},
    <String, String>{'name': 'Adam (male)', 'id': elevenLabsAdam},
  ];
}

double openAiSpeedFor(PersonalDjMood mood) => switch (mood) {
      PersonalDjMood.chill => 1.0,
      PersonalDjMood.hype => 1.18,
      PersonalDjMood.discover => 1.06,
      PersonalDjMood.mixed => 1.1,
    };
