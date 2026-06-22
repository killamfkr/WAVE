import 'package:freezed_annotation/freezed_annotation.dart';

import 'deezer_album.dart';
import 'deezer_artist.dart';
import 'deezer_playlist.dart';
import 'deezer_track.dart';

part 'library_state.freezed.dart';

/// Aggregated user library state held in memory and mirrored to Hive.
@freezed
abstract class LibraryState with _$LibraryState {
  const factory LibraryState({
    @Default(<DeezerTrack>[]) List<DeezerTrack> likedTracks,
    @Default(<DeezerAlbum>[]) List<DeezerAlbum> likedAlbums,
    @Default(<DeezerArtist>[]) List<DeezerArtist> followedArtists,
    @Default(<DeezerPlaylist>[]) List<DeezerPlaylist> playlists,
    @Default(<int>[]) List<int> downloadedTrackIds,
  }) = _LibraryState;
}
