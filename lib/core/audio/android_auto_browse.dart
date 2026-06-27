import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

import '../api/models/deezer_playlist.dart';
import '../api/models/deezer_track.dart';
import '../storage/hive_boxes.dart';

/// Media id namespace for Android Auto / MediaBrowser browse + play.
abstract final class AndroidAutoIds {
  static const String liked = 'wave/liked';
  static const String playlists = 'wave/playlists';
  static String playlist(int id) => 'wave/playlist/$id';
  static String track(int id) => 'wave/track/$id';
}

Map<String, dynamic> _deepJson(Map<String, dynamic> json) {
  return jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
}

DeezerTrack? _trackFromHiveValue(Object? raw) {
  if (raw is! Map) return null;
  try {
    return DeezerTrack.fromJson(_deepJson(Map<String, dynamic>.from(raw)));
  } catch (_) {
    return null;
  }
}

List<DeezerTrack> _likedTracks() {
  final box = Hive.box<dynamic>(HiveBoxes.likedTracks);
  return box.values
      .map(_trackFromHiveValue)
      .whereType<DeezerTrack>()
      .toList(growable: false);
}

List<DeezerPlaylist> _userPlaylists() {
  final box = Hive.box<dynamic>(HiveBoxes.playlists);
  return box.values
      .map((raw) {
        if (raw is! Map) return null;
        try {
          return DeezerPlaylist.fromJson(
            _deepJson(Map<String, dynamic>.from(raw)),
          );
        } catch (_) {
          return null;
        }
      })
      .whereType<DeezerPlaylist>()
      .toList(growable: false);
}

List<DeezerTrack> _playlistTracks(int playlistId) {
  final box = Hive.box<dynamic>(HiveBoxes.playlistTracks);
  final raw = box.get(playlistId.toString());
  if (raw is! List) return const <DeezerTrack>[];
  return raw
      .map(_trackFromHiveValue)
      .whereType<DeezerTrack>()
      .toList(growable: false);
}

DeezerTrack? findTrackById(int id) {
  for (final track in _likedTracks()) {
    if (track.id == id) return track;
  }
  for (final playlist in _userPlaylists()) {
    for (final track in _playlistTracks(playlist.id)) {
      if (track.id == id) return track;
    }
  }
  return null;
}

MediaItem trackToMediaItem(DeezerTrack track) {
  final art = track.album?.coverMedium ??
      track.album?.coverBig ??
      track.album?.cover;
  return MediaItem(
    id: AndroidAutoIds.track(track.id),
    title: track.title,
    artist: track.artist?.name,
    album: track.album?.title,
    duration:
        track.duration != null ? Duration(seconds: track.duration!) : null,
    artUri: art != null ? Uri.tryParse(art) : null,
    playable: true,
  );
}

MediaItem _folderItem({
  required String id,
  required String title,
  String? subtitle,
}) {
  return MediaItem(
    id: id,
    title: title,
    album: subtitle,
    playable: false,
  );
}

/// Children for [AudioHandler.getChildren] (Android Auto browse tree).
List<MediaItem> androidAutoChildrenFor(String parentMediaId) {
  if (parentMediaId == AudioService.browsableRootId) {
    final likedCount = _likedTracks().length;
    final playlistCount = _userPlaylists().length;
    return <MediaItem>[
      _folderItem(
        id: AndroidAutoIds.liked,
        title: 'Liked Songs',
        subtitle: likedCount == 1 ? '1 song' : '$likedCount songs',
      ),
      _folderItem(
        id: AndroidAutoIds.playlists,
        title: 'My Playlists',
        subtitle:
            playlistCount == 1 ? '1 playlist' : '$playlistCount playlists',
      ),
    ];
  }

  if (parentMediaId == AndroidAutoIds.liked) {
    return _likedTracks().map(trackToMediaItem).toList(growable: false);
  }

  if (parentMediaId == AndroidAutoIds.playlists) {
    return _userPlaylists()
        .map(
          (p) => _folderItem(
            id: AndroidAutoIds.playlist(p.id),
            title: p.title,
            subtitle: '${p.nbTracks ?? 0} tracks',
          ),
        )
        .toList(growable: false);
  }

  const playlistPrefix = 'wave/playlist/';
  if (parentMediaId.startsWith(playlistPrefix)) {
    final id = int.tryParse(parentMediaId.substring(playlistPrefix.length));
    if (id == null) return const <MediaItem>[];
    return _playlistTracks(id).map(trackToMediaItem).toList(growable: false);
  }

  return const <MediaItem>[];
}

/// Resolve a browsable/playable media id to tracks for playback.
List<DeezerTrack> tracksForMediaId(String mediaId) {
  if (mediaId.startsWith('wave/track/')) {
    final id = int.tryParse(mediaId.substring('wave/track/'.length));
    if (id == null) return const <DeezerTrack>[];
    final track = findTrackById(id);
    return track == null ? const <DeezerTrack>[] : <DeezerTrack>[track];
  }

  const playlistPrefix = 'wave/playlist/';
  if (mediaId.startsWith(playlistPrefix)) {
    final id = int.tryParse(mediaId.substring(playlistPrefix.length));
    if (id == null) return const <DeezerTrack>[];
    return _playlistTracks(id);
  }

  if (mediaId == AndroidAutoIds.liked) {
    return _likedTracks();
  }

  return const <DeezerTrack>[];
}
