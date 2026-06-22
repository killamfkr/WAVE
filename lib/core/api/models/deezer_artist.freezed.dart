// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deezer_artist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeezerArtist {

 int get id; String get name; String? get link; String? get picture;@JsonKey(name: 'picture_small') String? get pictureSmall;@JsonKey(name: 'picture_medium') String? get pictureMedium;@JsonKey(name: 'picture_big') String? get pictureBig;@JsonKey(name: 'picture_xl') String? get pictureXl;@JsonKey(name: 'nb_album') int? get nbAlbum;@JsonKey(name: 'nb_fan') int? get nbFan;@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? get radio;
/// Create a copy of DeezerArtist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeezerArtistCopyWith<DeezerArtist> get copyWith => _$DeezerArtistCopyWithImpl<DeezerArtist>(this as DeezerArtist, _$identity);

  /// Serializes this DeezerArtist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeezerArtist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.link, link) || other.link == link)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.pictureSmall, pictureSmall) || other.pictureSmall == pictureSmall)&&(identical(other.pictureMedium, pictureMedium) || other.pictureMedium == pictureMedium)&&(identical(other.pictureBig, pictureBig) || other.pictureBig == pictureBig)&&(identical(other.pictureXl, pictureXl) || other.pictureXl == pictureXl)&&(identical(other.nbAlbum, nbAlbum) || other.nbAlbum == nbAlbum)&&(identical(other.nbFan, nbFan) || other.nbFan == nbFan)&&(identical(other.radio, radio) || other.radio == radio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,link,picture,pictureSmall,pictureMedium,pictureBig,pictureXl,nbAlbum,nbFan,radio);

@override
String toString() {
  return 'DeezerArtist(id: $id, name: $name, link: $link, picture: $picture, pictureSmall: $pictureSmall, pictureMedium: $pictureMedium, pictureBig: $pictureBig, pictureXl: $pictureXl, nbAlbum: $nbAlbum, nbFan: $nbFan, radio: $radio)';
}


}

/// @nodoc
abstract mixin class $DeezerArtistCopyWith<$Res>  {
  factory $DeezerArtistCopyWith(DeezerArtist value, $Res Function(DeezerArtist) _then) = _$DeezerArtistCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? link, String? picture,@JsonKey(name: 'picture_small') String? pictureSmall,@JsonKey(name: 'picture_medium') String? pictureMedium,@JsonKey(name: 'picture_big') String? pictureBig,@JsonKey(name: 'picture_xl') String? pictureXl,@JsonKey(name: 'nb_album') int? nbAlbum,@JsonKey(name: 'nb_fan') int? nbFan,@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? radio
});




}
/// @nodoc
class _$DeezerArtistCopyWithImpl<$Res>
    implements $DeezerArtistCopyWith<$Res> {
  _$DeezerArtistCopyWithImpl(this._self, this._then);

  final DeezerArtist _self;
  final $Res Function(DeezerArtist) _then;

/// Create a copy of DeezerArtist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? link = freezed,Object? picture = freezed,Object? pictureSmall = freezed,Object? pictureMedium = freezed,Object? pictureBig = freezed,Object? pictureXl = freezed,Object? nbAlbum = freezed,Object? nbFan = freezed,Object? radio = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,pictureSmall: freezed == pictureSmall ? _self.pictureSmall : pictureSmall // ignore: cast_nullable_to_non_nullable
as String?,pictureMedium: freezed == pictureMedium ? _self.pictureMedium : pictureMedium // ignore: cast_nullable_to_non_nullable
as String?,pictureBig: freezed == pictureBig ? _self.pictureBig : pictureBig // ignore: cast_nullable_to_non_nullable
as String?,pictureXl: freezed == pictureXl ? _self.pictureXl : pictureXl // ignore: cast_nullable_to_non_nullable
as String?,nbAlbum: freezed == nbAlbum ? _self.nbAlbum : nbAlbum // ignore: cast_nullable_to_non_nullable
as int?,nbFan: freezed == nbFan ? _self.nbFan : nbFan // ignore: cast_nullable_to_non_nullable
as int?,radio: freezed == radio ? _self.radio : radio // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeezerArtist].
extension DeezerArtistPatterns on DeezerArtist {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeezerArtist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeezerArtist() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeezerArtist value)  $default,){
final _that = this;
switch (_that) {
case _DeezerArtist():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeezerArtist value)?  $default,){
final _that = this;
switch (_that) {
case _DeezerArtist() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? link,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl, @JsonKey(name: 'nb_album')  int? nbAlbum, @JsonKey(name: 'nb_fan')  int? nbFan, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? radio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeezerArtist() when $default != null:
return $default(_that.id,_that.name,_that.link,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl,_that.nbAlbum,_that.nbFan,_that.radio);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? link,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl, @JsonKey(name: 'nb_album')  int? nbAlbum, @JsonKey(name: 'nb_fan')  int? nbFan, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? radio)  $default,) {final _that = this;
switch (_that) {
case _DeezerArtist():
return $default(_that.id,_that.name,_that.link,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl,_that.nbAlbum,_that.nbFan,_that.radio);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? link,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl, @JsonKey(name: 'nb_album')  int? nbAlbum, @JsonKey(name: 'nb_fan')  int? nbFan, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? radio)?  $default,) {final _that = this;
switch (_that) {
case _DeezerArtist() when $default != null:
return $default(_that.id,_that.name,_that.link,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl,_that.nbAlbum,_that.nbFan,_that.radio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeezerArtist implements DeezerArtist {
  const _DeezerArtist({required this.id, required this.name, this.link, this.picture, @JsonKey(name: 'picture_small') this.pictureSmall, @JsonKey(name: 'picture_medium') this.pictureMedium, @JsonKey(name: 'picture_big') this.pictureBig, @JsonKey(name: 'picture_xl') this.pictureXl, @JsonKey(name: 'nb_album') this.nbAlbum, @JsonKey(name: 'nb_fan') this.nbFan, @JsonKey(fromJson: boolFromJson, toJson: boolToJson) this.radio});
  factory _DeezerArtist.fromJson(Map<String, dynamic> json) => _$DeezerArtistFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? link;
@override final  String? picture;
@override@JsonKey(name: 'picture_small') final  String? pictureSmall;
@override@JsonKey(name: 'picture_medium') final  String? pictureMedium;
@override@JsonKey(name: 'picture_big') final  String? pictureBig;
@override@JsonKey(name: 'picture_xl') final  String? pictureXl;
@override@JsonKey(name: 'nb_album') final  int? nbAlbum;
@override@JsonKey(name: 'nb_fan') final  int? nbFan;
@override@JsonKey(fromJson: boolFromJson, toJson: boolToJson) final  bool? radio;

/// Create a copy of DeezerArtist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeezerArtistCopyWith<_DeezerArtist> get copyWith => __$DeezerArtistCopyWithImpl<_DeezerArtist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeezerArtistToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeezerArtist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.link, link) || other.link == link)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.pictureSmall, pictureSmall) || other.pictureSmall == pictureSmall)&&(identical(other.pictureMedium, pictureMedium) || other.pictureMedium == pictureMedium)&&(identical(other.pictureBig, pictureBig) || other.pictureBig == pictureBig)&&(identical(other.pictureXl, pictureXl) || other.pictureXl == pictureXl)&&(identical(other.nbAlbum, nbAlbum) || other.nbAlbum == nbAlbum)&&(identical(other.nbFan, nbFan) || other.nbFan == nbFan)&&(identical(other.radio, radio) || other.radio == radio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,link,picture,pictureSmall,pictureMedium,pictureBig,pictureXl,nbAlbum,nbFan,radio);

@override
String toString() {
  return 'DeezerArtist(id: $id, name: $name, link: $link, picture: $picture, pictureSmall: $pictureSmall, pictureMedium: $pictureMedium, pictureBig: $pictureBig, pictureXl: $pictureXl, nbAlbum: $nbAlbum, nbFan: $nbFan, radio: $radio)';
}


}

/// @nodoc
abstract mixin class _$DeezerArtistCopyWith<$Res> implements $DeezerArtistCopyWith<$Res> {
  factory _$DeezerArtistCopyWith(_DeezerArtist value, $Res Function(_DeezerArtist) _then) = __$DeezerArtistCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? link, String? picture,@JsonKey(name: 'picture_small') String? pictureSmall,@JsonKey(name: 'picture_medium') String? pictureMedium,@JsonKey(name: 'picture_big') String? pictureBig,@JsonKey(name: 'picture_xl') String? pictureXl,@JsonKey(name: 'nb_album') int? nbAlbum,@JsonKey(name: 'nb_fan') int? nbFan,@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? radio
});




}
/// @nodoc
class __$DeezerArtistCopyWithImpl<$Res>
    implements _$DeezerArtistCopyWith<$Res> {
  __$DeezerArtistCopyWithImpl(this._self, this._then);

  final _DeezerArtist _self;
  final $Res Function(_DeezerArtist) _then;

/// Create a copy of DeezerArtist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? link = freezed,Object? picture = freezed,Object? pictureSmall = freezed,Object? pictureMedium = freezed,Object? pictureBig = freezed,Object? pictureXl = freezed,Object? nbAlbum = freezed,Object? nbFan = freezed,Object? radio = freezed,}) {
  return _then(_DeezerArtist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,pictureSmall: freezed == pictureSmall ? _self.pictureSmall : pictureSmall // ignore: cast_nullable_to_non_nullable
as String?,pictureMedium: freezed == pictureMedium ? _self.pictureMedium : pictureMedium // ignore: cast_nullable_to_non_nullable
as String?,pictureBig: freezed == pictureBig ? _self.pictureBig : pictureBig // ignore: cast_nullable_to_non_nullable
as String?,pictureXl: freezed == pictureXl ? _self.pictureXl : pictureXl // ignore: cast_nullable_to_non_nullable
as String?,nbAlbum: freezed == nbAlbum ? _self.nbAlbum : nbAlbum // ignore: cast_nullable_to_non_nullable
as int?,nbFan: freezed == nbFan ? _self.nbFan : nbFan // ignore: cast_nullable_to_non_nullable
as int?,radio: freezed == radio ? _self.radio : radio // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
