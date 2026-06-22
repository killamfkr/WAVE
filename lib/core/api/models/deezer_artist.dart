import 'package:freezed_annotation/freezed_annotation.dart';
import 'bool_converter.dart';

part 'deezer_artist.freezed.dart';
part 'deezer_artist.g.dart';

/// A Deezer artist.
@freezed
abstract class DeezerArtist with _$DeezerArtist {
  const factory DeezerArtist({
    required int id,
    required String name,
    String? link,
    String? picture,
    @JsonKey(name: 'picture_small') String? pictureSmall,
    @JsonKey(name: 'picture_medium') String? pictureMedium,
    @JsonKey(name: 'picture_big') String? pictureBig,
    @JsonKey(name: 'picture_xl') String? pictureXl,
    @JsonKey(name: 'nb_album') int? nbAlbum,
    @JsonKey(name: 'nb_fan') int? nbFan,
    @JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? radio,
  }) = _DeezerArtist;

  factory DeezerArtist.fromJson(Map<String, dynamic> json) =>
      _$DeezerArtistFromJson(json);
}
