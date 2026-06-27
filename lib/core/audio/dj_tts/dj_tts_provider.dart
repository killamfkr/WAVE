/// Cloud TTS backend for the Personal DJ.
enum DjTtsProvider {
  edge,
  openai,
  elevenlabs,
}

extension DjTtsProviderLabel on DjTtsProvider {
  String get label => switch (this) {
        DjTtsProvider.edge => 'Free (Edge)',
        DjTtsProvider.openai => 'OpenAI',
        DjTtsProvider.elevenlabs => 'ElevenLabs',
      };

  String get subtitle => switch (this) {
        DjTtsProvider.edge =>
          'Built-in neural voice. No API key required.',
        DjTtsProvider.openai =>
          'Natural voices with style instructions. Uses your OpenAI API key.',
        DjTtsProvider.elevenlabs =>
          'Ultra-realistic voices. Uses your ElevenLabs API key.',
      };
}
