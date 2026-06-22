// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deezer_playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeezerPlaylist _$DeezerPlaylistFromJson(Map<String, dynamic> json) =>
    _DeezerPlaylist(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      public: boolFromJson(json['public']),
      isLovedTrack: boolFromJson(json['is_loved_track']),
      collaborative: boolFromJson(json['collaborative']),
      nbTracks: (json['nb_tracks'] as num?)?.toInt(),
      fans: (json['fans'] as num?)?.toInt(),
      link: json['link'] as String?,
      picture: json['picture'] as String?,
      pictureSmall: json['picture_small'] as String?,
      pictureMedium: json['picture_medium'] as String?,
      pictureBig: json['picture_big'] as String?,
      pictureXl: json['picture_xl'] as String?,
      creator: json['creator'] == null
          ? null
          : DeezerUser.fromJson(json['creator'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeezerPlaylistToJson(_DeezerPlaylist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'duration': instance.duration,
      'public': boolToJson(instance.public),
      'is_loved_track': boolToJson(instance.isLovedTrack),
      'collaborative': boolToJson(instance.collaborative),
      'nb_tracks': instance.nbTracks,
      'fans': instance.fans,
      'link': instance.link,
      'picture': instance.picture,
      'picture_small': instance.pictureSmall,
      'picture_medium': instance.pictureMedium,
      'picture_big': instance.pictureBig,
      'picture_xl': instance.pictureXl,
      'creator': instance.creator,
    };
