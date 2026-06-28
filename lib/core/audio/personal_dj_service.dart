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

/// Tracks above this BPM are excluded from chill (when BPM is known).
const double personalDjChillMaxBpm = 118;

/// Minimum [PersonalDjService.hypeScore] for a track to enter a hype queue.
const double personalDjHypeMinScore = 0.4;

/// Tracks below this BPM are excluded from hype (when BPM is known).
const double personalDjHypeSlowBpm = 98;

/// Faster tracks above this BPM score highest for hype.
const double personalDjHypeMinBpm = 108;

/// Tempo around this BPM scores highest for hype.
const double personalDjHypeIdealBpm = 128;

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
  final _bpmCache = <int, double>{};

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
    var seed = _pickOpenerSeed(seeds, mood, likedIds, recentIds);
    if (mood == PersonalDjMood.chill || mood == PersonalDjMood.hype) {
      final enrichedSeed = await _withKnownBpm(seed);
      if (_trackFitsMood(enrichedSeed, mood, likedIds: likedIds, recentIds: recentIds)) {
        seed = enrichedSeed;
      }
    }
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

    await _refineMoodTail(tail, mood);

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

    await _refineMoodTail(added, mood);

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
      List<DeezerTrack> candidates;
      if (mood == PersonalDjMood.chill) {
        candidates = await _filterChillTracks(similar);
      } else if (mood == PersonalDjMood.hype) {
        candidates = await _filterHypeTracks(similar);
      } else {
        final filtered = _filterForMood(
          similar,
          mood,
          likedIds: likedIds,
          recentIds: recentIds,
          strict: true,
        );
        candidates = filtered.isEmpty
            ? similar
            : filtered.length >= 4
                ? filtered
                : <DeezerTrack>[
                    ...filtered,
                    ...similar.where((t) => !filtered.contains(t)),
                  ];
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

    var likedPool = _rankLikedForMood(liked, mood);
    if (mood == PersonalDjMood.chill) {
      likedPool = await _filterChillTracks(likedPool.take(20).toList());
    } else if (mood == PersonalDjMood.hype) {
      likedPool = await _filterHypeTracks(likedPool.take(24).toList());
    }
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
        final hypePool = await _filterHypeTracks(liked);
        for (final track in hypePool) {
          tryAdd(track);
          if (seeds.length >= count) return _enrichBpm(seeds);
        }
      case PersonalDjMood.chill:
        final chillPool = await _filterChillTracks(liked);
        for (final track in chillPool) {
          tryAdd(track);
          if (seeds.length >= count) return _enrichBpm(seeds);
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
        if ((mood == PersonalDjMood.chill || mood == PersonalDjMood.hype) &&
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
        var chartPool = _rankChartForMood(chart, mood);
        if (mood == PersonalDjMood.chill) {
          chartPool = await _filterChillTracks(chartPool);
        } else if (mood == PersonalDjMood.hype) {
          chartPool = await _filterHypeTracks(chartPool);
        } else {
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

    if (mood == PersonalDjMood.chill || mood == PersonalDjMood.hype) {
      return _enrichBpm(seeds);
    }

    return seeds;
  }

  Future<void> _refineMoodTail(List<DeezerTrack> tail, PersonalDjMood mood) async {
    if (tail.isEmpty) return;

    switch (mood) {
      case PersonalDjMood.chill:
        final enriched = await _enrichBpm(tail);
        tail
          ..clear()
          ..addAll(
            enriched.where(
              (t) => chillScore(t) >= personalDjChillMinScore - 0.08,
            ),
          );
      case PersonalDjMood.hype:
        final enriched = await _enrichBpm(tail);
        tail
          ..clear()
          ..addAll(
            enriched.where(
              (t) => hypeScore(t) >= personalDjHypeMinScore - 0.08,
            ),
          );
      case PersonalDjMood.mixed:
      case PersonalDjMood.discover:
        break;
    }
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
        pool.sort((a, b) => hypeScore(b).compareTo(hypeScore(a)));
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
        pool
          ..removeWhere((track) => hypeScore(track) < personalDjHypeMinScore)
          ..sort((a, b) => hypeScore(b).compareTo(hypeScore(a)));
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
    if (mood == PersonalDjMood.hype) {
      return _hypeCandidates(tracks, minScore: personalDjHypeMinScore);
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

  Future<List<DeezerTrack>> _filterChillTracks(
    List<DeezerTrack> tracks, {
    double minScore = personalDjChillMinScore,
  }) async {
    final enriched = await _enrichBpm(tracks);
    return _chillCandidates(enriched, minScore: minScore);
  }

  List<DeezerTrack> _hypeCandidates(
    List<DeezerTrack> tracks, {
    double minScore = personalDjHypeMinScore,
  }) {
    final passing = tracks.where((t) => hypeScore(t) >= minScore).toList()
      ..sort((a, b) => hypeScore(b).compareTo(hypeScore(a)));
    if (passing.isNotEmpty) return passing;

    final relaxed = tracks.where((t) => hypeScore(t) >= minScore - 0.12).toList()
      ..sort((a, b) => hypeScore(b).compareTo(hypeScore(a)));
    return relaxed;
  }

  Future<List<DeezerTrack>> _filterHypeTracks(
    List<DeezerTrack> tracks, {
    double minScore = personalDjHypeMinScore,
  }) async {
    final enriched = await _enrichBpm(tracks);
    return _hypeCandidates(enriched, minScore: minScore);
  }

  Future<DeezerTrack> _withKnownBpm(DeezerTrack track) async {
    final cached = track.bpm ?? _bpmCache[track.id];
    if (cached != null && cached > 0) {
      return track.bpm == cached ? track : track.copyWith(bpm: cached);
    }

    try {
      final full = await _deezer.getTrack(track.id);
      final bpm = full.bpm ?? 0;
      if (bpm > 0) _bpmCache[track.id] = bpm;
      return bpm > 0 ? track.copyWith(bpm: bpm) : track;
    } catch (e) {
      appLogger.w('DJ BPM: could not load tempo for ${track.id}: $e');
      return track;
    }
  }

  Future<List<DeezerTrack>> _enrichBpm(
    List<DeezerTrack> tracks, {
    int maxFetches = 28,
  }) async {
    final updated = List<DeezerTrack>.from(tracks);
    final pending = <int>[];

    for (var i = 0; i < updated.length; i++) {
      final track = updated[i];
      final known = track.bpm ?? _bpmCache[track.id];
      if (known != null && known > 0) {
        if (track.bpm != known) {
          updated[i] = track.copyWith(bpm: known);
        }
        continue;
      }
      if (pending.length < maxFetches) {
        pending.add(i);
      }
    }

    for (var start = 0; start < pending.length; start += 6) {
      final batch = pending.skip(start).take(6).toList();
      final results = await Future.wait(
        batch.map((index) async => MapEntry(index, await _withKnownBpm(updated[index]))),
      );
      for (final entry in results) {
        updated[entry.key] = entry.value;
      }
    }

    return updated;
  }

  /// Heuristic chill fit from tempo, duration, and chart rank (higher = mellower).
  static double chillScore(DeezerTrack track) {
    final duration = track.duration ?? 0;
    if (duration < personalDjChillMinDuration) return -1;

    final rank = track.rank ?? 220000;
    if (rank >= personalDjChillMaxRank) return -1;

    final bpm = track.bpm ?? 0;
    if (bpm > personalDjChillMaxBpm) return -1;

    final durationScore =
        1.0 - ((duration - 285) / 210).abs().clamp(0.0, 1.0);
    final rankScore =
        ((personalDjChillMaxRank - rank) / personalDjChillMaxRank).clamp(0.0, 1.0);
    final baseScore = durationScore * 0.2 + rankScore * 0.35;

    if (bpm <= 0) return baseScore;

    final bpmScore = _bpmChillScore(bpm);
    if (bpmScore < 0) return -1;
    return baseScore * 0.25 + bpmScore * 0.75;
  }

  static double _bpmChillScore(double bpm) {
    if (bpm > personalDjChillMaxBpm) return -1;
    if (bpm <= 92) return 1.0;
    if (bpm <= 105) return 1.0 - (bpm - 92) / 26;
    return 1.0 - (bpm - 92) / 18;
  }

  /// Heuristic hype fit from tempo, chart rank, and duration (higher = more energy).
  static double hypeScore(DeezerTrack track) {
    final rank = track.rank ?? 0;
    final duration = track.duration ?? 180;
    final bpm = track.bpm ?? 0;

    if (bpm > 0 && bpm < personalDjHypeSlowBpm) return -1;

    final rankScore = (rank / 900000).clamp(0.0, 1.0);
    final durationScore = duration <= 240
        ? 1.0
        : (1.0 - (duration - 240) / 360).clamp(0.0, 1.0);
    final baseScore = rankScore * 0.45 + durationScore * 0.2;

    if (bpm <= 0) {
      if (rank < 250000 && duration > 240) return -1;
      return baseScore;
    }

    final bpmScore = _bpmHypeScore(bpm);
    if (bpmScore < 0) return -1;
    return baseScore * 0.3 + bpmScore * 0.7;
  }

  static double _bpmHypeScore(double bpm) {
    if (bpm < personalDjHypeSlowBpm) return -1;
    if (bpm >= personalDjHypeIdealBpm) return 1.0;
    if (bpm >= personalDjHypeMinBpm) {
      return 0.72 + (bpm - personalDjHypeMinBpm) / 71;
    }
    return (bpm - personalDjHypeSlowBpm) /
        (personalDjHypeMinBpm - personalDjHypeSlowBpm) *
        0.72;
  }

  bool _trackFitsMood(
    DeezerTrack track,
    PersonalDjMood mood, {
    required Set<int> likedIds,
    required Set<int> recentIds,
  }) {
    return switch (mood) {
      PersonalDjMood.chill => chillScore(track) >= personalDjChillMinScore,
      PersonalDjMood.hype => hypeScore(track) >= personalDjHypeMinScore,
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
    return switch (mood) {
      PersonalDjMood.chill => chillScore(track),
      PersonalDjMood.hype => hypeScore(track),
      PersonalDjMood.discover =>
        (likedIds.contains(track.id) ? -5.0 : 2.0) +
            (recentIds.contains(track.id) ? -3.0 : 1.0) +
            (700000 - (track.rank ?? 400000)).clamp(0, 700000) / 200000,
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
        tail.sort((a, b) => hypeScore(b).compareTo(hypeScore(a)));
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
          'Slower tempos and deeper cuts — skips fast tracks and chart bangers.',
        PersonalDjMood.hype =>
          'Faster tempos and chart favorites — skips slow, long album cuts.',
        PersonalDjMood.discover =>
          'New-to-you tracks — skips your likes and recent plays.',
      };
}
