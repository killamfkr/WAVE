import 'dart:math';

import '../api/deezer_api_client.dart';
import '../api/lastfm_api_client.dart';
import '../api/models/deezer_track.dart';
import '../utils/app_logger.dart';

/// Finds playable tracks similar to a seed track (Last.fm + Deezer fallbacks).
class SimilarTracksResolver {
  SimilarTracksResolver({
    DeezerApiClient? deezer,
    LastfmApiClient? lastfm,
  })  : _deezer = deezer ?? DeezerApiClient(),
        _lastfm = lastfm ?? LastfmApiClient();

  final DeezerApiClient _deezer;
  final LastfmApiClient _lastfm;

  Future<List<DeezerTrack>> resolve(
    DeezerTrack seed, {
    Set<int> excludeIds = const <int>{},
    int limit = 15,
  }) async {
    final results = <DeezerTrack>[];
    final seen = <int>{...excludeIds};
    final cap = limit.clamp(1, 40);

    void addTracks(Iterable<DeezerTrack> tracks) {
      for (final track in tracks) {
        if (seen.add(track.id)) {
          results.add(track);
        }
        if (results.length >= cap) return;
      }
    }

    final artistName = seed.artist?.name ?? '';
    if (artistName.isNotEmpty) {
      try {
        final similar = await _lastfm.getSimilarTracks(
          seed.title,
          artistName,
          limit: 20,
        );
        for (final entry in similar) {
          final trackName = entry['name'] ?? '';
          final similarArtist = entry['artist'] ?? '';
          if (trackName.isEmpty || similarArtist.isEmpty) continue;
          try {
            final found = await _deezer.searchTracks(
              'artist:"$similarArtist" track:"$trackName"',
              limit: 3,
            );
            addTracks(found);
          } catch (_) {}
          if (results.length >= cap) break;
        }
      } catch (e) {
        appLogger.w('Last.fm similar resolution failed: $e');
      }
    }

    final artistId = seed.artist?.id;
    if (results.length < 8 && artistId != null) {
      try {
        final related = await _deezer.getRelatedArtists(artistId);
        for (final artist in related.take(5)) {
          final tops = await _deezer.getArtistTopTracks(artist.id, limit: 5);
          addTracks(tops.where((t) => t.id != seed.id));
          if (results.length >= cap) break;
        }
      } catch (e) {
        appLogger.w('Related-artist similar resolution failed: $e');
      }
    }

    if (results.length < 8 && artistId != null) {
      try {
        final tops = await _deezer.getArtistTopTracks(artistId, limit: 20);
        addTracks(tops.where((t) => t.id != seed.id));
      } catch (e) {
        appLogger.w('Artist top-tracks similar resolution failed: $e');
      }
    }

    if (results.isEmpty) {
      try {
        final chart = await _deezer.getChartTracks(limit: 20);
        addTracks(chart);
      } catch (e) {
        appLogger.w('Chart fallback for similar tracks failed: $e');
      }
    }

    if (results.length > 1) {
      results.shuffle(Random());
    }
    return results.take(cap).toList(growable: false);
  }
}
