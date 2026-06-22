import 'package:freezed_annotation/freezed_annotation.dart';

part 'deezer_user.freezed.dart';
part 'deezer_user.g.dart';

/// A Deezer user (the authenticated user, or a playlist creator).
@freezed
abstract class DeezerUser with _$DeezerUser {
  const factory DeezerUser({
    required int id,
    required String name,
    String? lastname,
    String? firstname,
    String? email,
    String? country,
    String? lang,
    String? picture,
    @JsonKey(name: 'picture_small') String? pictureSmall,
    @JsonKey(name: 'picture_medium') String? pictureMedium,
    @JsonKey(name: 'picture_big') String? pictureBig,
    @JsonKey(name: 'picture_xl') String? pictureXl,
  }) = _DeezerUser;

  factory DeezerUser.fromJson(Map<String, dynamic> json) =>
      _$DeezerUserFromJson(json);
}
