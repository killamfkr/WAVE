import 'dart:math';

import '../api/deezer_api_client.dart';
import '../api/models/deezer_track.dart';
import '../storage/recently_played.dart';
import '../utils/app_logger.dart';
import 'personal_dj_speech.dart';
import 'similar_tracks_resolver.dart';

enum PersonalDjMood { mixed, chill, hype, discover }

/// Target length for an initial DJ session queue.
const int personalDjQueueTarget = 50;

/// When upcoming drops below this, the DJ refills the queue.
const int personalDjRefillThreshold = 8;

/// How many tracks to append per refill.
const int personalDjRefillBatch = 24;

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
    final seeds = await _pickSeeds(liked: liked, recent: recent, count: 6);
    final seed = seeds.first;
    final exclude = <int>{seed.id};
    final tail = <DeezerTrack>[];

    await _appendFromSeeds(
      seeds: seeds,
      exclude: exclude,
      into: tail,
      target: personalDjQueueTarget - 1,
      similarPerSeed: 12,
    );

    await _appendLikedAndRecent(
      liked: liked,
      recent: recent,
      exclude: exclude,
      into: tail,
      target: personalDjQueueTarget - 1,
    );

    _applyMoodSort(tail, mood);
    if (tail.length > 1) {
      tail.shuffle(_rng);
    }

    final queue = <DeezerTrack>[seed, ...tail];

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

  /// Adds fresh tracks for an active DJ session, skipping anything already heard
  /// or queued in this session.
  Future<List<DeezerTrack>> extendQueue({
    required List<DeezerTrack> liked,
    required List<RecentEntry> recent,
    required Set<int> excludeIds,
    PersonalDjMood mood = PersonalDjMood.mixed,
    int target = personalDjRefillBatch,
  }) async {
    final exclude = <int>{...excludeIds};
    final added = <DeezerTrack>[];

    final seeds = await _pickSeeds(
      liked: liked,
      recent: recent,
      count: 4,
      excludeIds: exclude,
    );

    await _appendFromSeeds(
      seeds: seeds,
      exclude: exclude,
      into: added,
      target: target,
      similarPerSeed: 10,
    );

    await _appendLikedAndRecent(
      liked: liked,
      recent: recent,
      exclude: exclude,
      into: added,
      target: target,
    );

    _applyMoodSort(added, mood);
    if (added.length > 1) {
      added.shuffle(_rng);
    }

    return added.take(target).toList(growable: false);
  }

  Future<void> _appendFromSeeds({
    required List<DeezerTrack> seeds,
    required Set<int> exclude,
    required List<DeezerTrack> into,
    required int target,
    required int similarPerSeed,
  }) async {
    for (final seed in seeds) {
      if (into.length >= target) return;
      exclude.add(seed.id);
      final similar = await _similar.resolve(
        seed,
        excludeIds: exclude,
        limit: similarPerSeed,
      );
      for (final track in similar) {
        if (exclude.add(track.id)) {
          into.add(track);
        }
        if (into.length >= target) return;
      }
    }
  }

  Future<void> _appendLikedAndRecent({
    required List<DeezerTrack> liked,
    required List<RecentEntry> recent,
    required Set<int> exclude,
    required List<DeezerTrack> into,
    required int target,
  }) async {
    final likedPool = List<DeezerTrack>.from(liked)..shuffle(_rng);
    for (final track in likedPool) {
      if (into.length >= target) return;
      if (exclude.add(track.id)) {
        into.add(track);
      }
    }

    for (final entry in recent.where((e) => e.kind == 'track').take(16)) {
      if (into.length >= target) return;
      try {
        final track = await _deezer.getTrack(entry.id);
        if (exclude.add(track.id)) {
          into.add(track);
        }
      } catch (e) {
        appLogger.w('DJ queue: could not load recent track ${entry.id}: $e');
      }
    }
  }

  Future<List<DeezerTrack>> _pickSeeds({
    required List<DeezerTrack> liked,
    required List<RecentEntry> recent,
    required int count,
    Set<int> excludeIds = const <int>{},
  }) async {
    final seeds = <DeezerTrack>[];
    final seen = <int>{...excludeIds};

    void tryAdd(DeezerTrack track) {
      if (seen.add(track.id)) {
        seeds.add(track);
      }
    }

    final likedPool = List<DeezerTrack>.from(liked)..shuffle(_rng);
    for (final track in likedPool) {
      tryAdd(track);
      if (seeds.length >= count) return seeds;
    }

    for (final entry in recent.where((e) => e.kind == 'track')) {
      if (seeds.length >= count) break;
      try {
        tryAdd(await _deezer.getTrack(entry.id));
      } catch (e) {
        appLogger.w('DJ seed: could not load recent track ${entry.id}: $e');
      }
    }

    if (seeds.isEmpty) {
      final chart = await _deezer.getChartTracks(limit: 20);
      final chartPool = List<DeezerTrack>.from(chart)..shuffle(_rng);
      for (final track in chartPool) {
        tryAdd(track);
        if (seeds.length >= count) break;
      }
    }

    if (seeds.isEmpty) {
      throw StateError('Could not build a DJ session — no tracks available.');
    }

    return seeds;
  }

  void _applyMoodSort(
    List<DeezerTrack> tail,
    PersonalDjMood mood,
  ) {
    switch (mood) {
      case PersonalDjMood.chill:
        tail.sort((a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0));
      case PersonalDjMood.hype:
        tail.sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));
      case PersonalDjMood.discover:
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
