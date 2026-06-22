import 'package:freezed_annotation/freezed_annotation.dart';

part 'deezer_genre.freezed.dart';
part 'deezer_genre.g.dart';

/// A Deezer music genre.
@freezed
abstract class DeezerGenre with _$DeezerGenre {
  const factory DeezerGenre({
    required int id,
    required String name,
    String? picture,
    @JsonKey(name: 'picture_small') String? pictureSmall,
    @JsonKey(name: 'picture_medium') String? pictureMedium,
    @JsonKey(name: 'picture_big') String? pictureBig,
    @JsonKey(name: 'picture_xl') String? pictureXl,
  }) = _DeezerGenre;

  factory DeezerGenre.fromJson(Map<String, dynamic> json) =>
      _$DeezerGenreFromJson(json);
}
