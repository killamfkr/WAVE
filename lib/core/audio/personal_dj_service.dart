import 'dart:math';

import '../api/deezer_api_client.dart';
import '../api/models/deezer_track.dart';
import '../storage/recently_played.dart';
import '../utils/app_logger.dart';
import 'personal_dj_speech.dart';
import 'similar_tracks_resolver.dart';

enum PersonalDjMood { mixed, chill, hype, discover }

class PersonalDjSession {
  const PersonalDjSession({
    required this.queue,
    required this.seed,
    required this.openerSpoken,
    required this.likedTrackIds,
  });

  final List<DeezerTrack> queue;
  final DeezerTrack seed;
  final String openerSpoken;
  final Set<int> likedTrackIds;
}

/// Builds personalized DJ queues from likes, history, and similar-track resolution.
class PersonalDjService {
  PersonalDjService({
    SimilarTracksResolver? similar,
    DeezerApiClient? deezer,
  })  : _similar = similar ?? SimilarTracksResolver(),
        _deezer = deezer ?? DeezerApiClient();

  final SimilarTracksResolver _similar;
  final DeezerApiClient _deezer;
  final _rng = Random();

  Future<PersonalDjSession> buildSession({
    required List<DeezerTrack> liked,
    required List<RecentEntry> recent,
    PersonalDjMood mood = PersonalDjMood.mixed,
  }) async {
    final likedIds = liked.map((t) => t.id).toSet();
    final seed = await _pickSeed(liked: liked, recent: recent);
    final similar = await _similar.resolve(seed, excludeIds: {seed.id});

    final queue = <DeezerTrack>[seed, ...similar];

    for (final track in liked) {
      if (queue.length >= 20) break;
      if (!queue.any((t) => t.id == track.id)) {
        queue.add(track);
      }
    }

    _applyMoodSort(queue, mood, seed);
    if (queue.length > 1) {
      queue.shuffle(_rng);
      // Keep a strong opener — move seed near front.
      queue.remove(seed);
      queue.insert(_rng.nextInt(min(3, queue.length + 1)), seed);
    }

    final openerSpoken = PersonalDjSpeech.opener(
      seed: seed,
      fromLiked: likedIds.contains(seed.id),
      fromRecent: recent.any((e) => e.kind == 'track' && e.id == seed.id),
      mood: mood,
    );

    return PersonalDjSession(
      queue: queue,
      seed: seed,
      openerSpoken: openerSpoken,
      likedTrackIds: likedIds,
    );
  }

  Future<DeezerTrack> _pickSeed({
    required List<DeezerTrack> liked,
    required List<RecentEntry> recent,
  }) async {
    final candidates = <DeezerTrack>[];

    if (liked.isNotEmpty) {
      candidates.add(liked[_rng.nextInt(liked.length)]);
      if (liked.length > 1) {
        candidates.add(liked[_rng.nextInt(liked.length)]);
      }
    }

    for (final entry in recent.where((e) => e.kind == 'track').take(6)) {
      try {
        candidates.add(await _deezer.getTrack(entry.id));
      } catch (e) {
        appLogger.w('DJ seed: could not load recent track ${entry.id}: $e');
      }
    }

    if (candidates.isEmpty) {
      final chart = await _deezer.getChartTracks(limit: 15);
      if (chart.isEmpty) {
        throw StateError('Could not build a DJ session — no tracks available.');
      }
      return chart[_rng.nextInt(chart.length)];
    }

    return candidates[_rng.nextInt(candidates.length)];
  }

  void _applyMoodSort(
    List<DeezerTrack> queue,
    PersonalDjMood mood,
    DeezerTrack seed,
  ) {
    switch (mood) {
      case PersonalDjMood.chill:
        queue.sort((a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0));
        break;
      case PersonalDjMood.hype:
        queue.sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));
        break;
      case PersonalDjMood.discover:
        queue.removeWhere((t) => t.id == seed.id);
        queue.shuffle(_rng);
        queue.insert(0, seed);
        break;
      case PersonalDjMood.mixed:
        break;
    }
  }

  static String linerFor(
    DeezerTrack track, {
    required Set<int> likedIds,
    PersonalDjMood mood = PersonalDjMood.mixed,
  }) {
    return PersonalDjSpeech.liner(
      track: track,
      likedIds: likedIds,
      mood: mood,
    );
  }

  static String moodLabel(PersonalDjMood mood) => switch (mood) {
        PersonalDjMood.mixed => 'Mixed',
        PersonalDjMood.chill => 'Chill',
        PersonalDjMood.hype => 'Hype',
        PersonalDjMood.discover => 'Discover',
      };
}
