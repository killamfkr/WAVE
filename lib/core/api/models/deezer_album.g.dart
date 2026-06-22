// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deezer_album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeezerAlbum _$DeezerAlbumFromJson(Map<String, dynamic> json) => _DeezerAlbum(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  link: json['link'] as String?,
  cover: json['cover'] as String?,
  coverSmall: json['cover_small'] as String?,
  coverMedium: json['cover_medium'] as String?,
  coverBig: json['cover_big'] as String?,
  coverXl: json['cover_xl'] as String?,
  md5Image: json['md5_image'] as String?,
  releaseDate: json['release_date'] as String?,
  recordType: json['record_type'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
  nbTracks: (json['nb_tracks'] as num?)?.toInt(),
  artist: json['artist'] == null
      ? null
      : DeezerArtist.fromJson(json['artist'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DeezerAlbumToJson(_DeezerAlbum instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'link': instance.link,
      'cover': instance.cover,
      'cover_small': instance.coverSmall,
      'cover_medium': instance.coverMedium,
      'cover_big': instance.coverBig,
      'cover_xl': instance.coverXl,
      'md5_image': instance.md5Image,
      'release_date': instance.releaseDate,
      'record_type': instance.recordType,
      'duration': instance.duration,
      'nb_tracks': instance.nbTracks,
      'artist': instance.artist,
    };
