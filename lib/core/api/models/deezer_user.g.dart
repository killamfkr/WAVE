// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deezer_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeezerUser _$DeezerUserFromJson(Map<String, dynamic> json) => _DeezerUser(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  lastname: json['lastname'] as String?,
  firstname: json['firstname'] as String?,
  email: json['email'] as String?,
  country: json['country'] as String?,
  lang: json['lang'] as String?,
  picture: json['picture'] as String?,
  pictureSmall: json['picture_small'] as String?,
  pictureMedium: json['picture_medium'] as String?,
  pictureBig: json['picture_big'] as String?,
  pictureXl: json['picture_xl'] as String?,
);

Map<String, dynamic> _$DeezerUserToJson(_DeezerUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'lastname': instance.lastname,
      'firstname': instance.firstname,
      'email': instance.email,
      'country': instance.country,
      'lang': instance.lang,
      'picture': instance.picture,
      'picture_small': instance.pictureSmall,
      'picture_medium': instance.pictureMedium,
      'picture_big': instance.pictureBig,
      'picture_xl': instance.pictureXl,
    };
