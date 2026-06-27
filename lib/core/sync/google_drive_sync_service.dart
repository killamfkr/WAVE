import 'dart:convert';

import 'package:googleapis/drive/v3.dart' as drive;

import '../api/models/deezer_playlist.dart';
import '../api/models/deezer_track.dart';
import '../storage/user_profile_providers.dart';
import '../utils/app_logger.dart';

class RemoteProfilePayload {
  const RemoteProfilePayload({
    required this.profile,
    required this.updatedAt,
  });

  final LocalUserProfile profile;
  final DateTime updatedAt;
}

class RemotePlaylistPayload {
  const RemotePlaylistPayload({
    required this.playlist,
    required this.tracks,
    required this.updatedAt,
    required this.deleted,
  });

  final DeezerPlaylist playlist;
  final List<DeezerTrack> tracks;
  final DateTime updatedAt;
  final bool deleted;
}

/// Syncs WAVE data to the hidden Google Drive `appDataFolder`.
class GoogleDriveSyncService {
  GoogleDriveSyncService(this._drive);

  final drive.DriveApi _drive;

  static const String profileFileName = 'wave_profile.json';
  static const String playlistPrefix = 'wave_pl_';

  Future<RemoteProfilePayload?> downloadProfile() async {
    final file = await _findFile(profileFileName);
    if (file?.id == null) return null;

    final content = await _downloadText(file!.id!);
    if (content == null) return null;

    try {
      final map = jsonDecode(content) as Map<String, dynamic>;
      final updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final profileMap = map['profile'] as Map<String, dynamic>?;
      if (profileMap == null) return null;
      return RemoteProfilePayload(
        profile: LocalUserProfile.fromJson(profileMap),
        updatedAt: updatedAt,
      );
    } catch (e, st) {
      appLogger.w('Failed to parse remote profile', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> uploadProfile({
    required LocalUserProfile profile,
    required DateTime updatedAt,
  }) async {
    final body = jsonEncode(<String, dynamic>{
      'type': 'wave_profile',
      'version': 1,
      'updatedAt': updatedAt.toIso8601String(),
      'profile': profile.toJson(),
    });
    await _upsertTextFile(profileFileName, body);
  }

  Future<Map<int, RemotePlaylistPayload>> downloadPlaylists() async {
    final files = await _listWaveFiles();
    final result = <int, RemotePlaylistPayload>{};

    for (final file in files) {
      final name = file.name;
      if (name == null || !name.startsWith(playlistPrefix)) continue;
      final id = int.tryParse(name.substring(playlistPrefix.length));
      if (id == null || file.id == null) continue;

      final content = await _downloadText(file.id!);
      if (content == null) continue;

      final payload = _parsePlaylistPayload(content);
      if (payload != null) {
        result[id] = payload;
      }
    }

    return result;
  }

  Future<void> uploadPlaylist({
    required DeezerPlaylist playlist,
    required List<DeezerTrack> tracks,
    required DateTime updatedAt,
    bool deleted = false,
  }) async {
    final body = jsonEncode(<String, dynamic>{
      'type': 'wave_playlist_sync',
      'version': 1,
      'id': playlist.id,
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': deleted,
      'playlist': playlist.toJson(),
      'tracks': tracks.map((t) => t.toJson()).toList(),
    });
    await _upsertTextFile(_playlistFileName(playlist.id), body);
  }

  Future<void> deletePlaylistFile(int id) async {
    final file = await _findFile(_playlistFileName(id));
    if (file?.id != null) {
      await _drive.files.delete(file!.id!);
    }
  }

  RemotePlaylistPayload? _parsePlaylistPayload(String content) {
    try {
      final map = jsonDecode(content) as Map<String, dynamic>;
      final updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final deleted = map['deleted'] as bool? ?? false;
      final playlistMap = map['playlist'] as Map<String, dynamic>?;
      if (playlistMap == null) return null;
      final playlist = DeezerPlaylist.fromJson(playlistMap);
      final rawTracks = map['tracks'] as List? ?? const <dynamic>[];
      final tracks = rawTracks
          .whereType<Map>()
          .map((t) => DeezerTrack.fromJson(Map<String, dynamic>.from(t)))
          .toList(growable: false);
      return RemotePlaylistPayload(
        playlist: playlist,
        tracks: tracks,
        updatedAt: updatedAt,
        deleted: deleted,
      );
    } catch (e, st) {
      appLogger.w('Failed to parse remote playlist', error: e, stackTrace: st);
      return null;
    }
  }

  Future<List<drive.File>> _listWaveFiles() async {
    final response = await _drive.files.list(
      spaces: 'appDataFolder',
      q: "trashed = false and (name = '$profileFileName' or name contains '$playlistPrefix')",
      $fields: 'files(id,name,modifiedTime)',
    );
    return response.files ?? const <drive.File>[];
  }

  Future<drive.File?> _findFile(String name) async {
    final response = await _drive.files.list(
      spaces: 'appDataFolder',
      q: "name = '$name' and trashed = false",
      $fields: 'files(id,name)',
      pageSize: 1,
    );
    final files = response.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  Future<void> _upsertTextFile(String name, String body) async {
    final bytes = utf8.encode(body);
    final media = drive.Media(Stream.value(bytes), bytes.length);
    final existing = await _findFile(name);
    if (existing?.id != null) {
      await _drive.files.update(
        drive.File()..name = name,
        existing!.id!,
        uploadMedia: media,
      );
      return;
    }

    await _drive.files.create(
      drive.File()
        ..name = name
        ..parents = <String>['appDataFolder'],
      uploadMedia: media,
    );
  }

  Future<String?> _downloadText(String fileId) async {
    final media = await _drive.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final data = await media.stream.toList();
    final bytes = data.expand((chunk) => chunk).toList();
    return utf8.decode(bytes);
  }

  String _playlistFileName(int id) => '$playlistPrefix$id.json';
}
