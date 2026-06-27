import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../api/models/deezer_album.dart';
import '../api/models/deezer_artist.dart';
import '../api/models/deezer_playlist.dart';
import '../api/models/deezer_track.dart';
import '../api/models/deezer_user.dart';
import 'hive_boxes.dart';
import '../sync/sync_metadata.dart';
import '../sync/sync_trigger_providers.dart';
import 'user_profile_providers.dart';

/// Ensures complex models are recursively converted to Maps before Hive storage.
/// This prevents "unknown type" errors when nested objects (like Artist in Track)
/// aren't manually converted to JSON.
Map<String, dynamic> _deepJson(Map<String, dynamic> json) {
  return jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
}

/// Sort options for the liked tracks list.
enum LikedSort { recent, alphabetical, artist, duration }

// ---------------------------------------------------------------------------
// Liked tracks ------------------------------------------------------------

class LikedTracksNotifier extends Notifier<List<DeezerTrack>> {
  @override
  List<DeezerTrack> build() {
    final box = Hive.box<dynamic>(HiveBoxes.likedTracks);
    return box.values
        .whereType<Map>()
        .map((m) => DeezerTrack.fromJson(_deepJson(Map<String, dynamic>.from(m))))
        .toList(growable: false);
  }

  bool isLiked(int id) => state.any((t) => t.id == id);

  Future<void> toggle(DeezerTrack track) async {
    final box = Hive.box<dynamic>(HiveBoxes.likedTracks);
    if (isLiked(track.id)) {
      await box.delete(track.id);
      state = state.where((t) => t.id != track.id).toList(growable: false);
    } else {
      await box.put(track.id, _deepJson(track.toJson()));
      state = <DeezerTrack>[track, ...state];
    }
    await SyncMetadata.touchLiked();
    ref.read(syncTriggerProvider.notifier).bump();
  }

  Future<void> remove(int id) async {
    await Hive.box<dynamic>(HiveBoxes.likedTracks).delete(id);
    state = state.where((t) => t.id != id).toList(growable: false);
    await SyncMetadata.touchLiked();
    ref.read(syncTriggerProvider.notifier).bump();
  }

  Future<void> applyFromSync(List<DeezerTrack> tracks) async {
    final box = Hive.box<dynamic>(HiveBoxes.likedTracks);
    await box.clear();
    for (final track in tracks) {
      await box.put(track.id, _deepJson(track.toJson()));
    }
    state = List<DeezerTrack>.from(tracks);
  }
}

final likedTracksProvider =
    NotifierProvider<LikedTracksNotifier, List<DeezerTrack>>(
  LikedTracksNotifier.new,
);

final likedSortProvider =
    NotifierProvider<LikedSortNotifier, LikedSort>(LikedSortNotifier.new);

class LikedSortNotifier extends Notifier<LikedSort> {
  @override
  LikedSort build() => LikedSort.recent;
  void set(LikedSort s) => state = s;
}

/// Read-only sorted view derived from `likedTracksProvider` + sort choice.
final likedTracksSortedProvider = Provider<List<DeezerTrack>>((ref) {
  final list = <DeezerTrack>[...ref.watch(likedTracksProvider)];
  switch (ref.watch(likedSortProvider)) {
    case LikedSort.recent:
      // Already in insertion order (newest first).
      break;
    case LikedSort.alphabetical:
      list.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      break;
    case LikedSort.artist:
      list.sort(
        (a, b) => (a.artist?.name ?? '')
            .toLowerCase()
            .compareTo((b.artist?.name ?? '').toLowerCase()),
      );
      break;
    case LikedSort.duration:
      list.sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
      break;
  }
  return list;
});

// ---------------------------------------------------------------------------
// Liked albums ------------------------------------------------------------

class LikedAlbumsNotifier extends Notifier<List<DeezerAlbum>> {
  @override
  List<DeezerAlbum> build() {
    final box = Hive.box<dynamic>(HiveBoxes.likedAlbums);
    return box.values
        .whereType<Map>()
        .map((m) => DeezerAlbum.fromJson(_deepJson(Map<String, dynamic>.from(m))))
        .toList(growable: false);
  }

  bool isLiked(int id) => state.any((a) => a.id == id);

  Future<void> toggle(DeezerAlbum album) async {
    final box = Hive.box<dynamic>(HiveBoxes.likedAlbums);
    if (isLiked(album.id)) {
      await box.delete(album.id);
      state = state.where((a) => a.id != album.id).toList(growable: false);
    } else {
      await box.put(album.id, _deepJson(album.toJson()));
      state = <DeezerAlbum>[album, ...state];
    }
  }
}

final likedAlbumsProvider =
    NotifierProvider<LikedAlbumsNotifier, List<DeezerAlbum>>(
  LikedAlbumsNotifier.new,
);

// ---------------------------------------------------------------------------
// Liked playlists ---------------------------------------------------------

class LikedPlaylistsNotifier extends Notifier<List<DeezerPlaylist>> {
  @override
  List<DeezerPlaylist> build() {
    final box = Hive.box<dynamic>(HiveBoxes.likedPlaylists);
    return box.values
        .whereType<Map>()
        .map((m) => DeezerPlaylist.fromJson(_deepJson(Map<String, dynamic>.from(m))))
        .toList(growable: false);
  }

  bool isLiked(int id) => state.any((p) => p.id == id);

  Future<void> toggle(DeezerPlaylist playlist) async {
    final box = Hive.box<dynamic>(HiveBoxes.likedPlaylists);
    final key = playlist.id.toString();
    if (isLiked(playlist.id)) {
      await box.delete(key);
      await box.delete(playlist.id);
      state = state.where((p) => p.id != playlist.id).toList(growable: false);
    } else {
      await box.put(key, _deepJson(playlist.toJson()));
      state = <DeezerPlaylist>[playlist, ...state];
    }
  }
}

final likedPlaylistsProvider =
    NotifierProvider<LikedPlaylistsNotifier, List<DeezerPlaylist>>(
  LikedPlaylistsNotifier.new,
);

// ---------------------------------------------------------------------------
// Followed artists --------------------------------------------------------

class FollowedArtistsNotifier extends Notifier<List<DeezerArtist>> {
  @override
  List<DeezerArtist> build() {
    final box = Hive.box<dynamic>(HiveBoxes.followedArtists);
    return box.values
        .whereType<Map>()
        .map((m) => DeezerArtist.fromJson(_deepJson(Map<String, dynamic>.from(m))))
        .toList(growable: false);
  }

  bool isFollowing(int id) => state.any((a) => a.id == id);

  Future<void> toggle(DeezerArtist artist) async {
    final box = Hive.box<dynamic>(HiveBoxes.followedArtists);
    if (isFollowing(artist.id)) {
      await box.delete(artist.id);
      state = state.where((a) => a.id != artist.id).toList(growable: false);
    } else {
      await box.put(artist.id, _deepJson(artist.toJson()));
      state = <DeezerArtist>[artist, ...state];
    }
  }
}

final followedArtistsProvider =
    NotifierProvider<FollowedArtistsNotifier, List<DeezerArtist>>(
  FollowedArtistsNotifier.new,
);

// ---------------------------------------------------------------------------
// User playlists ----------------------------------------------------------

class UserPlaylistsNotifier extends Notifier<List<DeezerPlaylist>> {
  DeezerUser _creatorFromProfile() =>
      ref.read(userProfileProvider).toDeezerUser();

  @override
  List<DeezerPlaylist> build() {
    final box = Hive.box<dynamic>(HiveBoxes.playlists);
    return box.values
        .whereType<Map>()
        .map((m) => DeezerPlaylist.fromJson(_deepJson(Map<String, dynamic>.from(m))))
        .toList(growable: false);
  }

  Future<DeezerPlaylist> create({
    required String title,
    String? description,
    bool public = true,
    String? coverUrl,
  }) async {
    // Local id space — negative to avoid collisions with real Deezer ids.
    // Use a string key for Hive to avoid the 32-bit integer range limit.
    final id = -DateTime.now().millisecondsSinceEpoch;
    final pl = DeezerPlaylist(
      id: id,
      title: title,
      description: description,
      public: public,
      nbTracks: 0,
      picture: coverUrl,
      pictureMedium: coverUrl,
      pictureBig: coverUrl,
      creator: _creatorFromProfile(),
    );
    await Hive.box<dynamic>(HiveBoxes.playlists).put(id.toString(), _deepJson(pl.toJson()));
    state = <DeezerPlaylist>[pl, ...state];
    await SyncMetadata.touchPlaylist(id);
    ref.read(syncTriggerProvider.notifier).bump();
    return pl;
  }

  Future<void> syncCreatorFromProfile() async {
    if (state.isEmpty) return;
    final creator = _creatorFromProfile();
    final box = Hive.box<dynamic>(HiveBoxes.playlists);
    final updated = state
        .map((p) => p.copyWith(creator: creator))
        .toList(growable: false);
    for (final p in updated) {
      await box.put(p.id.toString(), _deepJson(p.toJson()));
    }
    state = updated;
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = <DeezerPlaylist>[...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    final box = Hive.box<dynamic>(HiveBoxes.playlists);
    await box.clear();
    for (final p in list) {
      await box.put(p.id.toString(), _deepJson(p.toJson()));
      await SyncMetadata.touchPlaylist(p.id);
    }
    ref.read(syncTriggerProvider.notifier).bump();
  }

  Future<void> delete(int id) async {
    await SyncMetadata.markPlaylistDeleted(id);
    await Hive.box<dynamic>(HiveBoxes.playlists).delete(id.toString());
    await Hive.box<dynamic>(HiveBoxes.playlistTracks).delete(id.toString());
    state = state.where((p) => p.id != id).toList(growable: false);
    ref.read(syncTriggerProvider.notifier).bump();
  }

  Future<void> removeFromSync(int id) async {
    await Hive.box<dynamic>(HiveBoxes.playlists).delete(id.toString());
    await Hive.box<dynamic>(HiveBoxes.playlistTracks).delete(id.toString());
    state = state.where((p) => p.id != id).toList(growable: false);
    await SyncMetadata.clearPlaylistDeleted(id);
  }

  Future<void> upsertFromSync({
    required DeezerPlaylist playlist,
    required List<DeezerTrack> tracks,
  }) async {
    await Hive.box<dynamic>(HiveBoxes.playlists).put(
      playlist.id.toString(),
      _deepJson(playlist.toJson()),
    );
    await Hive.box<dynamic>(HiveBoxes.playlistTracks).put(
      playlist.id.toString(),
      tracks.map((t) => _deepJson(t.toJson())).toList(),
    );

    final without = state.where((p) => p.id != playlist.id).toList();
    state = <DeezerPlaylist>[playlist, ...without];
    ref.invalidate(localPlaylistTracksProvider);
  }

  Future<void> updatePlaylist(int id, {required String title, String? description}) async {
    final list = state.map((p) {
      if (p.id == id) {
        return p.copyWith(
          title: title,
          description: description,
        );
      }
      return p;
    }).toList(growable: false);
    
    state = list;
    
    final box = Hive.box<dynamic>(HiveBoxes.playlists);
    final target = list.firstWhere((p) => p.id == id);
    await box.put(id.toString(), _deepJson(target.toJson()));
    await SyncMetadata.touchPlaylist(id);
    ref.read(syncTriggerProvider.notifier).bump();
  }
}

final userPlaylistsProvider =
    NotifierProvider<UserPlaylistsNotifier, List<DeezerPlaylist>>(
  UserPlaylistsNotifier.new,
);

// ---------------------------------------------------------------------------
// Local playlist tracks ---------------------------------------------------

class LocalPlaylistTracksNotifier extends Notifier<Map<int, List<DeezerTrack>>> {
  @override
  Map<int, List<DeezerTrack>> build() {
    final box = Hive.box<dynamic>(HiveBoxes.playlistTracks);
    final map = <int, List<DeezerTrack>>{};
    for (final key in box.keys) {
      if (key is String) {
        final id = int.tryParse(key);
        if (id != null) {
          final rawList = box.get(key);
          if (rawList is List) {
            map[id] = rawList
                .whereType<Map>()
                .map((m) => DeezerTrack.fromJson(_deepJson(Map<String, dynamic>.from(m))))
                .toList(growable: false);
          }
        }
      }
    }
    return map;
  }

  Future<void> addTrack(int playlistId, DeezerTrack track) async {
    final currentList = state[playlistId] ?? <DeezerTrack>[];
    final newList = <DeezerTrack>[...currentList, track];
    
    state = {
      ...state,
      playlistId: newList,
    };
    
    // Update the tracks box
    final box = Hive.box<dynamic>(HiveBoxes.playlistTracks);
    await box.put(playlistId.toString(), newList.map((t) => _deepJson(t.toJson())).toList());
    
    // Update the playlist metadata (nbTracks and occasionally picture)
    final currentPlaylists = ref.read(userPlaylistsProvider);
    final idx = currentPlaylists.indexWhere((p) => p.id == playlistId);
    if (idx != -1) {
      final pl = currentPlaylists[idx];
      var newPicture = pl.pictureBig;
      if (newList.length == 1) {
        newPicture = track.album?.coverBig ?? track.album?.cover;
      }
      final updatedPl = pl.copyWith(
        nbTracks: newList.length,
        picture: newPicture,
        pictureMedium: newPicture,
        pictureBig: newPicture,
      );
      final plBox = Hive.box<dynamic>(HiveBoxes.playlists);
      await plBox.put(playlistId.toString(), _deepJson(updatedPl.toJson()));
      
      // We manually invalidate UserPlaylistsNotifier since we bypassed its methods
      ref.invalidate(userPlaylistsProvider); 
    }
    await SyncMetadata.touchPlaylist(playlistId);
    ref.read(syncTriggerProvider.notifier).bump();
  }

  Future<void> removeTrack(int playlistId, int trackId) async {
    final currentList = state[playlistId] ?? <DeezerTrack>[];
    final newList = currentList.where((t) => t.id != trackId).toList(growable: false);
    
    state = {
      ...state,
      playlistId: newList,
    };
    
    final box = Hive.box<dynamic>(HiveBoxes.playlistTracks);
    await box.put(playlistId.toString(), newList.map((t) => _deepJson(t.toJson())).toList());
    
    ref.invalidate(userPlaylistsProvider);
    await SyncMetadata.touchPlaylist(playlistId);
    ref.read(syncTriggerProvider.notifier).bump();
  }

  Future<void> reorderTrack(int playlistId, int oldIndex, int newIndex) async {
    final currentList = state[playlistId] ?? <DeezerTrack>[];
    final newList = <DeezerTrack>[...currentList];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    
    state = {
      ...state,
      playlistId: newList,
    };
    
    final box = Hive.box<dynamic>(HiveBoxes.playlistTracks);
    await box.put(playlistId.toString(), newList.map((t) => _deepJson(t.toJson())).toList());
    await SyncMetadata.touchPlaylist(playlistId);
    ref.read(syncTriggerProvider.notifier).bump();
  }
}

final localPlaylistTracksProvider =
    NotifierProvider<LocalPlaylistTracksNotifier, Map<int, List<DeezerTrack>>>(
  LocalPlaylistTracksNotifier.new,
);
