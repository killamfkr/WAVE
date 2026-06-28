// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deezer_track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeezerTrack _$DeezerTrackFromJson(Map<String, dynamic> json) => _DeezerTrack(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  titleShort: json['title_short'] as String?,
  titleVersion: json['title_version'] as String?,
  link: json['link'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
  rank: (json['rank'] as num?)?.toInt(),
  bpm: (json['bpm'] as num?)?.toDouble(),
  explicitLyrics: boolFromJson(json['explicit_lyrics']),
  preview: json['preview'] as String?,
  artist: json['artist'] == null
      ? null
      : DeezerArtist.fromJson(json['artist'] as Map<String, dynamic>),
  album: json['album'] == null
      ? null
      : DeezerAlbum.fromJson(json['album'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DeezerTrackToJson(_DeezerTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'title_short': instance.titleShort,
      'title_version': instance.titleVersion,
      'link': instance.link,
      'duration': instance.duration,
      'rank': instance.rank,
      'bpm': instance.bpm,
      'explicit_lyrics': boolToJson(instance.explicitLyrics),
      'preview': instance.preview,
      'artist': instance.artist,
      'album': instance.album,
    };
