import 'dart:convert';

import '../api/models/deezer_playlist.dart';
import '../api/models/deezer_track.dart';
import '../storage/user_profile_providers.dart';
import 'sync_metadata.dart';

/// JSON blob stored under `user_settings.prefs.wave_library`.
class WaveLibraryBundle {
  const WaveLibraryBundle({
    required this.updatedAt,
    required this.profile,
    required this.playlists,
    required this.tracksByPlaylistId,
    this.deletedPlaylistIds = const <String>[],
  });

  static const String prefsKey = 'wave_library';
  static const int profileId = 1;

  final DateTime updatedAt;
  final LocalUserProfile profile;
  final List<DeezerPlaylist> playlists;
  final Map<int, List<DeezerTrack>> tracksByPlaylistId;
  final List<String> deletedPlaylistIds;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': 1,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'profile': profile.toJson(),
      'playlists': playlists.map((p) => p.toJson()).toList(),
      'tracks': tracksByPlaylistId.map(
        (id, tracks) => MapEntry(
          id.toString(),
          tracks.map((t) => t.toJson()).toList(),
        ),
      ),
      'deletedPlaylistIds': deletedPlaylistIds,
    };
  }

  factory WaveLibraryBundle.fromLocal({
    required LocalUserProfile profile,
    required List<DeezerPlaylist> playlists,
    required Map<int, List<DeezerTrack>> tracksByPlaylistId,
  }) {
    final deleted = SyncMetadata.deletedPlaylistIds().toList(growable: false);
    return WaveLibraryBundle(
      updatedAt: _latestLocalUpdatedAt(),
      profile: profile,
      playlists: playlists,
      tracksByPlaylistId: tracksByPlaylistId,
      deletedPlaylistIds: deleted,
    );
  }

  static DateTime _latestLocalUpdatedAt() {
    var latest = SyncMetadata.profileUpdatedAt();
    for (final entry in SyncMetadata.playlistTimes().entries) {
      final parsed = DateTime.tryParse(entry.value)?.toUtc();
      if (parsed != null && parsed.isAfter(latest)) {
        latest = parsed;
      }
    }
    return latest;
  }

  static WaveLibraryBundle? parse(Object? raw) {
    Map<String, dynamic>? map;
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) map = decoded;
      } catch (_) {
        return null;
      }
    } else if (raw is Map) {
      map = raw.cast<String, dynamic>();
    }
    if (map == null) return null;

    final updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '')
            ?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final profileMap = map['profile'];
    if (profileMap is! Map) return null;

    final playlistsRaw = map['playlists'];
    final playlists = <DeezerPlaylist>[];
    if (playlistsRaw is List) {
      for (final item in playlistsRaw) {
        if (item is Map) {
          playlists.add(
            DeezerPlaylist.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final tracksRaw = map['tracks'];
    final tracksById = <int, List<DeezerTrack>>{};
    if (tracksRaw is Map) {
      for (final entry in tracksRaw.entries) {
        final id = int.tryParse(entry.key.toString());
        final list = entry.value;
        if (id == null || list is! List) continue;
        tracksById[id] = list
            .whereType<Map>()
            .map((t) => DeezerTrack.fromJson(Map<String, dynamic>.from(t)))
            .toList(growable: false);
      }
    }

    final deletedRaw = map['deletedPlaylistIds'];
    final deleted = deletedRaw is List
        ? deletedRaw.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    return WaveLibraryBundle(
      updatedAt: updatedAt,
      profile: LocalUserProfile.fromJson(
        Map<String, dynamic>.from(profileMap),
      ),
      playlists: playlists,
      tracksByPlaylistId: tracksById,
      deletedPlaylistIds: deleted,
    );
  }
}
