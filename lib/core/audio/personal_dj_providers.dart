import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/deezer_track.dart';
import '../storage/library_providers.dart';
import '../storage/recently_played.dart';
import '../storage/settings_providers.dart';
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
    this.liner,
    this.opener,
    this.errorMessage,
  });

  final bool isActive;
  final bool isLoading;
  final bool isSpeaking;
  final bool voiceEnabled;
  final PersonalDjMood mood;
  final String? liner;
  final String? opener;
  final String? errorMessage;

  PersonalDjState copyWith({
    bool? isActive,
    bool? isLoading,
    bool? isSpeaking,
    bool? voiceEnabled,
    PersonalDjMood? mood,
    String? liner,
    String? opener,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PersonalDjState(
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      mood: mood ?? this.mood,
      liner: liner ?? this.liner,
      opener: opener ?? this.opener,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final personalDjVoiceProvider = Provider<PersonalDjVoiceService>((ref) {
  final voice = PersonalDjVoiceService();
  ref.onDispose(voice.stop);
  return voice;
});

class PersonalDjNotifier extends Notifier<PersonalDjState> {
  Set<int> _likedIds = const <int>{};
  int? _lastSpokenTrackId;

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

      await _player.setShuffle(true);
      await _player.setAutoplaySimilar(true);
      if (ref.read(appSettingsProvider).crossfadeSeconds < 4) {
        await _player.setCrossfadeSeconds(4);
      }

      state = PersonalDjState(
        isActive: true,
        voiceEnabled: voiceEnabled,
        mood: mood,
        opener: session.opener,
        liner: session.opener,
      );

      if (voiceEnabled) {
        await _speak(session.opener, duck: false);
        _lastSpokenTrackId = session.seed.id;
      }

      await _player.playTracks(session.queue);
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

    final liner = PersonalDjService.linerFor(
      track,
      likedIds: _likedIds,
      mood: state.mood,
    );
    state = state.copyWith(liner: liner);
    _speak(liner, duck: true, trackId: track.id);
  }

  Future<void> toggleVoice() async {
    final next = !state.voiceEnabled;
    if (!next) {
      await _voice.stop();
      state = state.copyWith(voiceEnabled: next, isSpeaking: false);
      return;
    }
    state = state.copyWith(voiceEnabled: next);
    final line = state.liner ?? state.opener;
    if (line != null && state.isActive) {
      await _speak(line, duck: _player.playerState.currentTrack != null);
    }
  }

  Future<void> _speak(
    String text, {
    bool duck = false,
    int? trackId,
  }) async {
    if (!state.voiceEnabled) return;

    state = state.copyWith(isSpeaking: true);
    try {
      await _voice.speak(
        text,
        player: duck ? _player : null,
        duck: duck,
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
    state = const PersonalDjState();
  }
}

final personalDjProvider =
    NotifierProvider<PersonalDjNotifier, PersonalDjState>(
  PersonalDjNotifier.new,
);
