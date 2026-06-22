import 'package:freezed_annotation/freezed_annotation.dart';

import 'deezer_artist.dart';

part 'deezer_album.freezed.dart';
part 'deezer_album.g.dart';

/// A Deezer album. Tracklist is fetched from the album endpoint and stored
/// inside [tracks] -> data when available.
@freezed
abstract class DeezerAlbum with _$DeezerAlbum {
  const factory DeezerAlbum({
    required int id,
    required String title,
    String? link,
    String? cover,
    @JsonKey(name: 'cover_small') String? coverSmall,
    @JsonKey(name: 'cover_medium') String? coverMedium,
    @JsonKey(name: 'cover_big') String? coverBig,
    @JsonKey(name: 'cover_xl') String? coverXl,
    @JsonKey(name: 'md5_image') String? md5Image,
    @JsonKey(name: 'release_date') String? releaseDate,
    @JsonKey(name: 'record_type') String? recordType,
    int? duration,
    @JsonKey(name: 'nb_tracks') int? nbTracks,
    DeezerArtist? artist,
  }) = _DeezerAlbum;

  factory DeezerAlbum.fromJson(Map<String, dynamic> json) =>
      _$DeezerAlbumFromJson(json);
}
