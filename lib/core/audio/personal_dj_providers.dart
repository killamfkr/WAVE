import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/deezer_track.dart';
import '../storage/library_providers.dart';
import '../storage/recently_played.dart';
import '../storage/settings_providers.dart';
import 'personal_dj_service.dart';
import 'player_providers.dart';

class PersonalDjState {
  const PersonalDjState({
    this.isActive = false,
    this.isLoading = false,
    this.mood = PersonalDjMood.mixed,
    this.liner,
    this.opener,
    this.errorMessage,
  });

  final bool isActive;
  final bool isLoading;
  final PersonalDjMood mood;
  final String? liner;
  final String? opener;
  final String? errorMessage;

  PersonalDjState copyWith({
    bool? isActive,
    bool? isLoading,
    PersonalDjMood? mood,
    String? liner,
    String? opener,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PersonalDjState(
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      mood: mood ?? this.mood,
      liner: liner ?? this.liner,
      opener: opener ?? this.opener,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PersonalDjNotifier extends Notifier<PersonalDjState> {
  Set<int> _likedIds = const <int>{};

  @override
  PersonalDjState build() => const PersonalDjState();

  Future<bool> startSession({PersonalDjMood mood = PersonalDjMood.mixed}) async {
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

      final player = ref.read(playerControlsProvider);
      await player.setShuffle(true);
      await player.setAutoplaySimilar(true);
      if (ref.read(appSettingsProvider).crossfadeSeconds < 4) {
        await player.setCrossfadeSeconds(4);
      }
      await player.playTracks(session.queue);

      state = PersonalDjState(
        isActive: true,
        mood: mood,
        opener: session.opener,
        liner: session.opener,
      );
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
    state = state.copyWith(
      liner: PersonalDjService.linerFor(
        track,
        likedIds: _likedIds,
        mood: state.mood,
      ),
    );
  }

  void endSession() {
    _likedIds = const <int>{};
    state = const PersonalDjState();
  }
}

final personalDjProvider =
    NotifierProvider<PersonalDjNotifier, PersonalDjState>(
  PersonalDjNotifier.new,
);
