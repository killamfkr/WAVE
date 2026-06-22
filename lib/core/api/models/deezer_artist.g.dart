// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deezer_artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeezerArtist _$DeezerArtistFromJson(Map<String, dynamic> json) =>
    _DeezerArtist(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      link: json['link'] as String?,
      picture: json['picture'] as String?,
      pictureSmall: json['picture_small'] as String?,
      pictureMedium: json['picture_medium'] as String?,
      pictureBig: json['picture_big'] as String?,
      pictureXl: json['picture_xl'] as String?,
      nbAlbum: (json['nb_album'] as num?)?.toInt(),
      nbFan: (json['nb_fan'] as num?)?.toInt(),
      radio: boolFromJson(json['radio']),
    );

Map<String, dynamic> _$DeezerArtistToJson(_DeezerArtist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'link': instance.link,
      'picture': instance.picture,
      'picture_small': instance.pictureSmall,
      'picture_medium': instance.pictureMedium,
      'picture_big': instance.pictureBig,
      'picture_xl': instance.pictureXl,
      'nb_album': instance.nbAlbum,
      'nb_fan': instance.nbFan,
      'radio': boolToJson(instance.radio),
    };
