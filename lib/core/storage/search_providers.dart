import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../api/deezer_api_client.dart';
import '../api/models/deezer_album.dart';
import '../api/models/deezer_artist.dart';
import '../api/models/deezer_playlist.dart';
import '../api/models/deezer_track.dart';
import '../storage/hive_boxes.dart';

/// Aggregated search payload returned by [searchResultsProvider].
class SearchResults {
  const SearchResults({
    required this.tracks,
    required this.artists,
    required this.albums,
    required this.playlists,
  });

  const SearchResults.empty()
      : tracks = const <DeezerTrack>[],
        artists = const <DeezerArtist>[],
        albums = const <DeezerAlbum>[],
        playlists = const <DeezerPlaylist>[];

  final List<DeezerTrack> tracks;
  final List<DeezerArtist> artists;
  final List<DeezerAlbum> albums;
  final List<DeezerPlaylist> playlists;

  bool get isEmpty =>
      tracks.isEmpty &&
      artists.isEmpty &&
      albums.isEmpty &&
      playlists.isEmpty;
}

/// Current debounced search query (raw, trimmed). Empty = idle.
class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  /// Sets the live text immediately but only commits after a 300ms pause.
  void setText(String value) {
    final trimmed = value.trim();
    _debounce?.cancel();
    if (trimmed.isEmpty) {
      state = '';
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = trimmed;
    });
  }

  void clear() {
    _debounce?.cancel();
    state = '';
  }
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Issues 4 parallel calls (tracks/artists/albums/playlists) for the active
/// query. Cancels in-flight requests when the query changes.
final searchResultsProvider = FutureProvider<SearchResults>((ref) async {
  final q = ref.watch(searchQueryProvider);
  if (q.isEmpty) return const SearchResults.empty();

  final api = ref.watch(deezerApiClientProvider);
  final cancel = CancelToken();
  ref.onDispose(() {
    if (!cancel.isCancelled) cancel.cancel();
  });

  final results = await Future.wait<dynamic>(<Future<dynamic>>[
    api.searchTracks(q, limit: 20, cancelToken: cancel),
    api.searchArtists(q, limit: 12, cancelToken: cancel),
    api.searchAlbums(q, limit: 12, cancelToken: cancel),
    api.searchPlaylists(q, limit: 12, cancelToken: cancel),
  ]);

  return SearchResults(
    tracks: results[0] as List<DeezerTrack>,
    artists: results[1] as List<DeezerArtist>,
    albums: results[2] as List<DeezerAlbum>,
    playlists: results[3] as List<DeezerPlaylist>,
  );
});

// ---------------------------------------------------------------------------
// Recent searches (Hive-backed) -------------------------------------------

class RecentSearchesNotifier extends Notifier<List<String>> {
  static const String _key = 'queries';
  static const int _maxEntries = 10;

  @override
  List<String> build() {
    final box = Hive.box<dynamic>(HiveBoxes.recentSearches);
    final raw = box.get(_key);
    if (raw is! List) return const <String>[];
    return raw.whereType<String>().toList(growable: false);
  }

  Future<void> push(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    final next = <String>[
      trimmed,
      ...state.where((e) => e.toLowerCase() != trimmed.toLowerCase()),
    ];
    if (next.length > _maxEntries) next.removeRange(_maxEntries, next.length);
    state = next;
    await Hive.box<dynamic>(HiveBoxes.recentSearches).put(_key, next);
  }

  Future<void> remove(String q) async {
    state = state.where((e) => e != q).toList(growable: false);
    await Hive.box<dynamic>(HiveBoxes.recentSearches).put(_key, state);
  }

  Future<void> clear() async {
    state = const <String>[];
    await Hive.box<dynamic>(HiveBoxes.recentSearches).delete(_key);
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
  RecentSearchesNotifier.new,
);
