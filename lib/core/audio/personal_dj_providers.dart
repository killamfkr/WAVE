import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/deezer_track.dart';
import '../api/models/player_state.dart';
import '../storage/library_providers.dart';
import '../storage/recently_played.dart';
import '../storage/settings_providers.dart';
import 'dj_tts/dj_tts_config.dart';
import 'dj_tts/dj_tts_key_store.dart';
import 'music_player_service.dart';
import 'personal_dj_service.dart';
import 'personal_dj_voice_service.dart';
import 'player_providers.dart';

class PersonalDjState {
  const PersonalDjState({
    this.isActive = false,
    this.isLoading = false,
    this.isSpeaking = false,
    this.voiceEnabled = true,
    this.mood = PersonalDjMood.mixed,
    this.errorMessage,
  });

  final bool isActive;
  final bool isLoading;
  final bool isSpeaking;
  final bool voiceEnabled;
  final PersonalDjMood mood;
  final String? errorMessage;

  PersonalDjState copyWith({
    bool? isActive,
    bool? isLoading,
    bool? isSpeaking,
    bool? voiceEnabled,
    PersonalDjMood? mood,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PersonalDjState(
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      mood: mood ?? this.mood,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final personalDjVoiceProvider = Provider<PersonalDjVoiceService>((ref) {
  final voice = PersonalDjVoiceService();
  ref.onDispose(voice.dispose);
  return voice;
});

class PersonalDjNotifier extends Notifier<PersonalDjState> {
  Set<int> _likedIds = const <int>{};
  int? _lastSpokenTrackId;
  String? _lastSpokenScript;

  PersonalDjVoiceService get _voice => ref.read(personalDjVoiceProvider);
  MusicPlayerService get _player => ref.read(playerControlsProvider);

  @override
  PersonalDjState build() => const PersonalDjState();

  Future<bool> startSession({PersonalDjMood mood = PersonalDjMood.mixed}) async {
    final voiceEnabled = state.voiceEnabled;
    state = state.copyWith(
      isLoading: true,
      mood: mood,
      clearError: true,
    );

    try {
      final session = await PersonalDjService().buildSession(
        liked: ref.read(likedTracksProvider),
        recent: ref.read(recentlyPlayedProvider),
        mood: mood,
      );
      _likedIds = session.likedTrackIds;
      _lastSpokenTrackId = null;
      _lastSpokenScript = null;

      await _player.setShuffle(true);
      await _player.setAutoplaySimilar(true);
      if (ref.read(appSettingsProvider).crossfadeSeconds < 4) {
        await _player.setCrossfadeSeconds(4);
      }

      state = PersonalDjState(
        isActive: true,
        voiceEnabled: voiceEnabled,
        mood: mood,
      );

      await _player.playTracks(session.queue);

      if (voiceEnabled) {
        await _speak(session.openerSpoken, mood: mood);
        _lastSpokenTrackId = session.seed.id;
      } else if (_player.playerState.status != PlaybackStatus.playing) {
        await _player.play();
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not start your DJ session. Try again.',
      );
      return false;
    }
  }

  Future<void> setMood(PersonalDjMood mood) async {
    if (!state.isActive) {
      await startSession(mood: mood);
      return;
    }
    await startSession(mood: mood);
  }

  void onTrackChanged(DeezerTrack? track) {
    if (!state.isActive || track == null) return;
    if (track.id == _lastSpokenTrackId) return;

    final spoken = PersonalDjService.linerFor(
      track,
      likedIds: _likedIds,
      mood: state.mood,
    );
    _speak(spoken, trackId: track.id, mood: state.mood);
  }

  Future<void> toggleVoice() async {
    final next = !state.voiceEnabled;
    if (!next) {
      await _voice.stop();
      state = state.copyWith(voiceEnabled: next, isSpeaking: false);
      return;
    }
    state = state.copyWith(voiceEnabled: next);
    if (_lastSpokenScript != null && state.isActive) {
      await _speak(_lastSpokenScript!, mood: state.mood);
    }
  }

  Future<DjTtsConfig> _ttsConfig() => DjTtsConfig.resolve(
        settings: ref.read(appSettingsProvider),
        keyStore: ref.read(djTtsKeyStoreProvider),
      );

  Future<void> _speak(
    String text, {
    int? trackId,
    PersonalDjMood mood = PersonalDjMood.mixed,
  }) async {
    if (!state.voiceEnabled) return;

    _lastSpokenScript = text;
    state = state.copyWith(isSpeaking: true);
    try {
      await _voice.speak(
        text,
        player: _player,
        mood: mood,
        ttsConfig: await _ttsConfig(),
      );
      if (trackId != null) {
        _lastSpokenTrackId = trackId;
      }
    } finally {
      if (state.isActive) {
        state = state.copyWith(isSpeaking: false);
      }
    }
  }

  Future<void> endSession() async {
    await _voice.stop();
    _likedIds = const <int>{};
    _lastSpokenTrackId = null;
    _lastSpokenScript = null;
    state = const PersonalDjState();
  }
}

final personalDjProvider =
    NotifierProvider<PersonalDjNotifier, PersonalDjState>(
  PersonalDjNotifier.new,
);
