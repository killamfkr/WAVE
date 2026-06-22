// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deezer_genre.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeezerGenre _$DeezerGenreFromJson(Map<String, dynamic> json) => _DeezerGenre(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  picture: json['picture'] as String?,
  pictureSmall: json['picture_small'] as String?,
  pictureMedium: json['picture_medium'] as String?,
  pictureBig: json['picture_big'] as String?,
  pictureXl: json['picture_xl'] as String?,
);

Map<String, dynamic> _$DeezerGenreToJson(_DeezerGenre instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'picture': instance.picture,
      'picture_small': instance.pictureSmall,
      'picture_medium': instance.pictureMedium,
      'picture_big': instance.pictureBig,
      'picture_xl': instance.pictureXl,
    };
