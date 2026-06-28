import 'dart:math';

import '../api/deezer_api_client.dart';
import '../api/models/deezer_track.dart';
import '../storage/recently_played.dart';
import '../utils/app_logger.dart';
import 'personal_dj_speech.dart';
import 'similar_tracks_resolver.dart';

enum PersonalDjMood { mixed, chill, hype, discover }

/// Minimum duration (seconds) for chill picks — skips short singles.
const int personalDjChillMinDuration = 210;

/// Chart rank above this is treated as too high-energy for chill.
const int personalDjChillMaxRank = 480000;

/// Minimum [PersonalDjService.chillScore] for a track to enter a chill queue.
const double personalDjChillMinScore = 0.42;

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
    final recentIds = _recentTrackIds(recent);
    final seeds = await _pickSeeds(
      liked: liked,
      recent: recent,
      count: 6,
      mood: mood,
      likedIds: likedIds,
      recentIds: recentIds,
    );
    final seed = _pickOpenerSeed(seeds, mood, likedIds, recentIds);
    final orderedSeeds = <DeezerTrack>[seed, ...seeds.where((t) => t.id != seed.id)];
    final exclude = <int>{seed.id};
    final tail = <DeezerTrack>[];

    await _appendFromSeeds(
      seeds: orderedSeeds,
      exclude: exclude,
      into: tail,
      target: personalDjQueueTarget - 1,
      similarPerSeed: 12,
      mood: mood,
      likedIds: likedIds,
      recentIds: recentIds,
    );

    await _appendLikedAndRecent(
      liked: liked,
      recent: recent,
      exclude: exclude,
      into: tail,
      target: personalDjQueueTarget - 1,
      mood: mood,
      likedIds: likedIds,
      recentIds: recentIds,
    );

    _finalizeTailOrder(tail, mood);

    final queue = <DeezerTrack>[seed, ...tail];

    final openerSpoken = PersonalDjSpeech.opener(
      seed: seed,
      fromLiked: likedIds.contains(seed.id),
      fromRecent: recentIds.contains(seed.id),
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
    final likedIds = liked.map((t) => t.id).toSet();
    final recentIds = _recentTrackIds(recent);
    final exclude = <int>{...excludeIds};
    final added = <DeezerTrack>[];

    final seeds = await _pickSeeds(
      liked: liked,
      recent: recent,
      count: 4,
      excludeIds: exclude,
      mood: mood,
      likedIds: likedIds,
      recentIds: recentIds,
    );

    await _appendFromSeeds(
      seeds: seeds,
      exclude: exclude,
      into: added,
      target: target,
      similarPerSeed: 10,
      mood: mood,
      likedIds: likedIds,
      recentIds: recentIds,
    );

    await _appendLikedAndRecent(
      liked: liked,
      recent: recent,
      exclude: exclude,
      into: added,
      target: target,
      mood: mood,
      likedIds: likedIds,
      recentIds: recentIds,
    );

    _finalizeTailOrder(added, mood);

    return added.take(target).toList(growable: false);
  }

  Future<void> _appendFromSeeds({
    required List<DeezerTrack> seeds,
    required Set<int> exclude,
    required List<DeezerTrack> into,
    required int target,
    required int similarPerSeed,
    required PersonalDjMood mood,
    required Set<int> likedIds,
    required Set<int> recentIds,
  }) async {
    for (final seed in seeds) {
      if (into.length >= target) return;
      exclude.add(seed.id);
      final similar = await _similar.resolve(
        seed,
        excludeIds: exclude,
        limit: similarPerSeed + 6,
      );
      final filtered = _filterForMood(
        similar,
        mood,
        likedIds: likedIds,
        recentIds: recentIds,
        strict: mood != PersonalDjMood.chill,
      );
      var candidates = filtered.isEmpty
          ? similar
          : filtered.length >= 4
              ? filtered
              : <DeezerTrack>[...filtered, ...similar.where((t) => !filtered.contains(t))];

      if (mood == PersonalDjMood.chill) {
        candidates = _chillCandidates(candidates);
      }

      for (final track in candidates) {
        if (into.length >= target) return;
        if (exclude.add(track.id)) {
          into.add(track);
        }
      }
    }
  }

  Future<void> _appendLikedAndRecent({
    required List<DeezerTrack> liked,
    required List<RecentEntry> recent,
    required Set<int> exclude,
    required List<DeezerTrack> into,
    required int target,
    required PersonalDjMood mood,
    required Set<int> likedIds,
    required Set<int> recentIds,
  }) async {
    switch (mood) {
      case PersonalDjMood.discover:
        return;
      case PersonalDjMood.mixed:
      case PersonalDjMood.chill:
      case PersonalDjMood.hype:
        break;
    }

    final likedCap = switch (mood) {
      PersonalDjMood.chill => 14,
      PersonalDjMood.hype => 22,
      PersonalDjMood.mixed => 20,
      PersonalDjMood.discover => 0,
    };

    final likedPool = _rankLikedForMood(liked, mood);
    for (final track in likedPool.take(likedCap)) {
      if (into.length >= target) return;
      if (!_trackFitsMood(track, mood, likedIds: likedIds, recentIds: recentIds)) {
        continue;
      }
      if (exclude.add(track.id)) {
        into.add(track);
      }
    }

    final recentCap = switch (mood) {
      PersonalDjMood.chill => 3,
      PersonalDjMood.hype => 10,
      PersonalDjMood.mixed => 12,
      PersonalDjMood.discover => 0,
    };

    for (final entry in recent.where((e) => e.kind == 'track').take(recentCap)) {
      if (into.length >= target) return;
      try {
        final track = await _deezer.getTrack(entry.id);
        if (!_trackFitsMood(track, mood, likedIds: likedIds, recentIds: recentIds)) {
          continue;
        }
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
    PersonalDjMood mood = PersonalDjMood.mixed,
    Set<int> excludeIds = const <int>{},
    Set<int> likedIds = const <int>{},
    Set<int> recentIds = const <int>{},
  }) async {
    final seeds = <DeezerTrack>[];
    final seen = <int>{...excludeIds};

    void tryAdd(DeezerTrack track) {
      if (seen.add(track.id)) {
        seeds.add(track);
      }
    }

    switch (mood) {
      case PersonalDjMood.discover:
        for (final entry in recent.where((e) => e.kind == 'track')) {
          if (seeds.length >= count) break;
          if (likedIds.contains(entry.id)) continue;
          try {
            tryAdd(await _deezer.getTrack(entry.id));
          } catch (e) {
            appLogger.w('DJ seed: could not load recent track ${entry.id}: $e');
          }
        }
        final deepLiked = List<DeezerTrack>.from(liked)
          ..sort((a, b) => (a.rank ?? 999999).compareTo(b.rank ?? 999999));
        for (final track in deepLiked) {
          tryAdd(track);
          if (seeds.length >= count) return seeds;
        }
      case PersonalDjMood.hype:
        final hypePool = List<DeezerTrack>.from(liked)
          ..sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));
        for (final track in hypePool) {
          tryAdd(track);
          if (seeds.length >= count) return seeds;
        }
      case PersonalDjMood.chill:
        final chillPool = List<DeezerTrack>.from(liked)
          ..removeWhere(
            (track) => !_trackFitsMood(
              track,
              mood,
              likedIds: likedIds,
              recentIds: recentIds,
            ),
          )
          ..sort((a, b) => chillScore(b).compareTo(chillScore(a)));
        for (final track in chillPool) {
          tryAdd(track);
          if (seeds.length >= count) return seeds;
        }
      case PersonalDjMood.mixed:
        final mixedPool = List<DeezerTrack>.from(liked)..shuffle(_rng);
        for (final track in mixedPool) {
          tryAdd(track);
          if (seeds.length >= count) return seeds;
        }
    }

    for (final entry in recent.where((e) => e.kind == 'track')) {
      if (seeds.length >= count) break;
      if (mood == PersonalDjMood.discover && likedIds.contains(entry.id)) {
        continue;
      }
      try {
        final track = await _deezer.getTrack(entry.id);
        if (mood == PersonalDjMood.chill &&
            !_trackFitsMood(
              track,
              mood,
              likedIds: likedIds,
              recentIds: recentIds,
            )) {
          continue;
        }
        tryAdd(track);
      } catch (e) {
        appLogger.w('DJ seed: could not load recent track ${entry.id}: $e');
      }
    }

    if (seeds.length < count) {
      try {
        final chart = await _deezer.getChartTracks(limit: 30);
        final chartPool = _rankChartForMood(chart, mood);
        if (mood != PersonalDjMood.chill) {
          chartPool.shuffle(_rng);
        }
        for (final track in chartPool) {
          tryAdd(track);
          if (seeds.length >= count) break;
        }
      } catch (e) {
        appLogger.w('DJ seed: chart fallback failed: $e');
      }
    }

    if (seeds.isEmpty) {
      throw StateError('Could not build a DJ session — no tracks available.');
    }

    return seeds;
  }

  DeezerTrack _pickOpenerSeed(
    List<DeezerTrack> seeds,
    PersonalDjMood mood,
    Set<int> likedIds,
    Set<int> recentIds,
  ) {
    if (seeds.isEmpty) {
      throw StateError('No seeds available for DJ opener.');
    }
    final ranked = List<DeezerTrack>.from(seeds)
      ..sort((a, b) => _moodScore(b, mood, likedIds, recentIds)
          .compareTo(_moodScore(a, mood, likedIds, recentIds)));
    return ranked.first;
  }

  List<DeezerTrack> _rankLikedForMood(List<DeezerTrack> liked, PersonalDjMood mood) {
    final pool = List<DeezerTrack>.from(liked);
    switch (mood) {
      case PersonalDjMood.chill:
        pool.sort((a, b) => chillScore(b).compareTo(chillScore(a)));
      case PersonalDjMood.hype:
        pool.sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));
      case PersonalDjMood.discover:
        pool.sort((a, b) => (a.rank ?? 999999).compareTo(b.rank ?? 999999));
      case PersonalDjMood.mixed:
        pool.shuffle(_rng);
    }
    return pool;
  }

  List<DeezerTrack> _rankChartForMood(List<DeezerTrack> chart, PersonalDjMood mood) {
    final pool = List<DeezerTrack>.from(chart);
    switch (mood) {
      case PersonalDjMood.hype:
        pool.sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));
      case PersonalDjMood.chill:
        pool
          ..removeWhere((track) => chillScore(track) < personalDjChillMinScore)
          ..sort((a, b) => chillScore(b).compareTo(chillScore(a)));
      case PersonalDjMood.discover:
        pool.sort((a, b) => (a.rank ?? 999999).compareTo(b.rank ?? 999999));
      case PersonalDjMood.mixed:
        break;
    }
    return pool;
  }

  List<DeezerTrack> _filterForMood(
    List<DeezerTrack> tracks,
    PersonalDjMood mood, {
    required Set<int> likedIds,
    required Set<int> recentIds,
    required bool strict,
  }) {
    if (mood == PersonalDjMood.chill) {
      return _chillCandidates(tracks, minScore: personalDjChillMinScore);
    }

    final passing = tracks
        .where((t) => _trackFitsMood(t, mood, likedIds: likedIds, recentIds: recentIds))
        .toList();
    if (!strict || passing.length >= 4) return passing;
    return tracks;
  }

  List<DeezerTrack> _chillCandidates(
    List<DeezerTrack> tracks, {
    double minScore = personalDjChillMinScore,
  }) {
    final passing = tracks.where((t) => chillScore(t) >= minScore).toList()
      ..sort((a, b) => chillScore(b).compareTo(chillScore(a)));
    if (passing.isNotEmpty) return passing;

    final relaxed = tracks.where((t) => chillScore(t) >= minScore - 0.12).toList()
      ..sort((a, b) => chillScore(b).compareTo(chillScore(a)));
    return relaxed;
  }

  /// Heuristic chill fit from duration and chart rank (higher = mellower).
  static double chillScore(DeezerTrack track) {
    final duration = track.duration ?? 0;
    if (duration < personalDjChillMinDuration) return -1;

    final rank = track.rank ?? 220000;
    if (rank >= personalDjChillMaxRank) return -1;

    final durationScore =
        1.0 - ((duration - 285) / 210).abs().clamp(0.0, 1.0);
    final rankScore =
        ((personalDjChillMaxRank - rank) / personalDjChillMaxRank).clamp(0.0, 1.0);

    return durationScore * 0.3 + rankScore * 0.7;
  }

  bool _trackFitsMood(
    DeezerTrack track,
    PersonalDjMood mood, {
    required Set<int> likedIds,
    required Set<int> recentIds,
  }) {
    final duration = track.duration ?? 0;
    final rank = track.rank ?? 0;

    return switch (mood) {
      PersonalDjMood.chill => chillScore(track) >= personalDjChillMinScore,
      PersonalDjMood.hype => rank >= 250000 || duration <= 240,
      PersonalDjMood.discover =>
        !likedIds.contains(track.id) && !recentIds.contains(track.id),
      PersonalDjMood.mixed => true,
    };
  }

  double _moodScore(
    DeezerTrack track,
    PersonalDjMood mood,
    Set<int> likedIds,
    Set<int> recentIds,
  ) {
    final duration = (track.duration ?? 180).toDouble();
    final rank = (track.rank ?? 400000).toDouble();

    return switch (mood) {
      PersonalDjMood.chill => chillScore(track),
      PersonalDjMood.hype => rank / 100000 + duration.clamp(120, 300) / 300,
      PersonalDjMood.discover =>
        (likedIds.contains(track.id) ? -5.0 : 2.0) +
            (recentIds.contains(track.id) ? -3.0 : 1.0) +
            (700000 - rank).clamp(0, 700000) / 200000,
      PersonalDjMood.mixed => _rng.nextDouble(),
    };
  }

  void _finalizeTailOrder(List<DeezerTrack> tail, PersonalDjMood mood) {
    if (tail.length <= 1) return;

    switch (mood) {
      case PersonalDjMood.mixed:
        tail.shuffle(_rng);
      case PersonalDjMood.chill:
        tail.sort((a, b) => chillScore(b).compareTo(chillScore(a)));
        _shuffleWithinChunks(tail, chunkSize: 3);
      case PersonalDjMood.hype:
        tail.sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));
        _shuffleWithinChunks(tail, chunkSize: 4);
      case PersonalDjMood.discover:
        tail.sort(
          (a, b) => (a.rank ?? 999999).compareTo(b.rank ?? 999999),
        );
        _shuffleWithinChunks(tail, chunkSize: 3);
    }
  }

  void _shuffleWithinChunks(List<DeezerTrack> tracks, {required int chunkSize}) {
    if (chunkSize < 2) return;
    for (var i = 0; i < tracks.length; i += chunkSize) {
      final end = min(i + chunkSize, tracks.length);
      final chunk = tracks.sublist(i, end)..shuffle(_rng);
      for (var j = 0; j < chunk.length; j++) {
        tracks[i + j] = chunk[j];
      }
    }
  }

  Set<int> _recentTrackIds(List<RecentEntry> recent) => recent
      .where((e) => e.kind == 'track')
      .map((e) => e.id)
      .toSet();

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

  static String moodDescription(PersonalDjMood mood) => switch (mood) {
        PersonalDjMood.mixed =>
          'Balanced mix of favorites, recent plays, and similar tracks.',
        PersonalDjMood.chill =>
          'Deeper cuts and longer tracks — skips chart bangers and short singles.',
        PersonalDjMood.hype =>
          'High-energy favorites and chart-rising picks.',
        PersonalDjMood.discover =>
          'New-to-you tracks — skips your likes and recent plays.',
      };
}
