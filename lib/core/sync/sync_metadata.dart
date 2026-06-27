import 'dart:convert';

import 'package:hive/hive.dart';

import '../storage/hive_boxes.dart';

/// Local timestamps and tombstones used for last-write-wins Drive sync.
class SyncMetadata {
  SyncMetadata._();

  static const String _profileUpdatedKey = 'sync_profile_updated_at';
  static const String _playlistTimesKey = 'sync_playlist_times';
  static const String _deletedPlaylistsKey = 'sync_deleted_playlists';

  static Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.settings);

  static DateTime profileUpdatedAt() {
    final raw = _box.get(_profileUpdatedKey);
    return _parseDate(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static Future<void> touchProfile() async {
    await setProfileUpdatedAt(DateTime.now().toUtc());
  }

  static Future<void> setProfileUpdatedAt(DateTime updatedAt) async {
    await _box.put(
      _profileUpdatedKey,
      updatedAt.toUtc().toIso8601String(),
    );
  }

  static DateTime? playlistUpdatedAt(int id) {
    final map = _playlistTimes();
    return _parseDate(map[id.toString()]);
  }

  static Future<void> touchPlaylist(int id) async {
    await setPlaylistUpdatedAt(id, DateTime.now().toUtc());
    await clearPlaylistDeleted(id);
  }

  static Future<void> setPlaylistUpdatedAt(int id, DateTime updatedAt) async {
    final map = _playlistTimes();
    map[id.toString()] = updatedAt.toUtc().toIso8601String();
    await _box.put(_playlistTimesKey, jsonEncode(map));
  }

  static Future<void> markPlaylistDeleted(int id) async {
    final deleted = _deletedPlaylists();
    deleted.add(id.toString());
    await _box.put(_deletedPlaylistsKey, jsonEncode(deleted.toList()));
    final map = _playlistTimes();
    map[id.toString()] = DateTime.now().toUtc().toIso8601String();
    await _box.put(_playlistTimesKey, jsonEncode(map));
  }

  static Future<void> clearPlaylistDeleted(int id) async {
    final deleted = _deletedPlaylists();
    if (deleted.remove(id.toString())) {
      await _box.put(_deletedPlaylistsKey, jsonEncode(deleted.toList()));
    }
  }

  static Set<String> deletedPlaylistIds() => _deletedPlaylists();

  static Map<String, String> playlistTimes() => _playlistTimes();

  static Map<String, String> _playlistTimes() {
    final raw = _box.get(_playlistTimesKey);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          );
        }
      } catch (_) {}
    }
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return <String, String>{};
  }

  static Set<String> _deletedPlaylists() {
    final raw = _box.get(_deletedPlaylistsKey);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toSet();
        }
      } catch (_) {}
    }
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw)?.toUtc();
    }
    return null;
  }
}
