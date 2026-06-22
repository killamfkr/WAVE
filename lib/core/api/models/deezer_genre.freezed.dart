// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deezer_genre.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeezerGenre {

 int get id; String get name; String? get picture;@JsonKey(name: 'picture_small') String? get pictureSmall;@JsonKey(name: 'picture_medium') String? get pictureMedium;@JsonKey(name: 'picture_big') String? get pictureBig;@JsonKey(name: 'picture_xl') String? get pictureXl;
/// Create a copy of DeezerGenre
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeezerGenreCopyWith<DeezerGenre> get copyWith => _$DeezerGenreCopyWithImpl<DeezerGenre>(this as DeezerGenre, _$identity);

  /// Serializes this DeezerGenre to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeezerGenre&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.pictureSmall, pictureSmall) || other.pictureSmall == pictureSmall)&&(identical(other.pictureMedium, pictureMedium) || other.pictureMedium == pictureMedium)&&(identical(other.pictureBig, pictureBig) || other.pictureBig == pictureBig)&&(identical(other.pictureXl, pictureXl) || other.pictureXl == pictureXl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,picture,pictureSmall,pictureMedium,pictureBig,pictureXl);

@override
String toString() {
  return 'DeezerGenre(id: $id, name: $name, picture: $picture, pictureSmall: $pictureSmall, pictureMedium: $pictureMedium, pictureBig: $pictureBig, pictureXl: $pictureXl)';
}


}

/// @nodoc
abstract mixin class $DeezerGenreCopyWith<$Res>  {
  factory $DeezerGenreCopyWith(DeezerGenre value, $Res Function(DeezerGenre) _then) = _$DeezerGenreCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? picture,@JsonKey(name: 'picture_small') String? pictureSmall,@JsonKey(name: 'picture_medium') String? pictureMedium,@JsonKey(name: 'picture_big') String? pictureBig,@JsonKey(name: 'picture_xl') String? pictureXl
});




}
/// @nodoc
class _$DeezerGenreCopyWithImpl<$Res>
    implements $DeezerGenreCopyWith<$Res> {
  _$DeezerGenreCopyWithImpl(this._self, this._then);

  final DeezerGenre _self;
  final $Res Function(DeezerGenre) _then;

/// Create a copy of DeezerGenre
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? picture = freezed,Object? pictureSmall = freezed,Object? pictureMedium = freezed,Object? pictureBig = freezed,Object? pictureXl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,pictureSmall: freezed == pictureSmall ? _self.pictureSmall : pictureSmall // ignore: cast_nullable_to_non_nullable
as String?,pictureMedium: freezed == pictureMedium ? _self.pictureMedium : pictureMedium // ignore: cast_nullable_to_non_nullable
as String?,pictureBig: freezed == pictureBig ? _self.pictureBig : pictureBig // ignore: cast_nullable_to_non_nullable
as String?,pictureXl: freezed == pictureXl ? _self.pictureXl : pictureXl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeezerGenre].
extension DeezerGenrePatterns on DeezerGenre {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeezerGenre value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeezerGenre() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeezerGenre value)  $default,){
final _that = this;
switch (_that) {
case _DeezerGenre():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeezerGenre value)?  $default,){
final _that = this;
switch (_that) {
case _DeezerGenre() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeezerGenre() when $default != null:
return $default(_that.id,_that.name,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl)  $default,) {final _that = this;
switch (_that) {
case _DeezerGenre():
return $default(_that.id,_that.name,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl)?  $default,) {final _that = this;
switch (_that) {
case _DeezerGenre() when $default != null:
return $default(_that.id,_that.name,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeezerGenre implements DeezerGenre {
  const _DeezerGenre({required this.id, required this.name, this.picture, @JsonKey(name: 'picture_small') this.pictureSmall, @JsonKey(name: 'picture_medium') this.pictureMedium, @JsonKey(name: 'picture_big') this.pictureBig, @JsonKey(name: 'picture_xl') this.pictureXl});
  factory _DeezerGenre.fromJson(Map<String, dynamic> json) => _$DeezerGenreFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? picture;
@override@JsonKey(name: 'picture_small') final  String? pictureSmall;
@override@JsonKey(name: 'picture_medium') final  String? pictureMedium;
@override@JsonKey(name: 'picture_big') final  String? pictureBig;
@override@JsonKey(name: 'picture_xl') final  String? pictureXl;

/// Create a copy of DeezerGenre
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeezerGenreCopyWith<_DeezerGenre> get copyWith => __$DeezerGenreCopyWithImpl<_DeezerGenre>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeezerGenreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeezerGenre&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.pictureSmall, pictureSmall) || other.pictureSmall == pictureSmall)&&(identical(other.pictureMedium, pictureMedium) || other.pictureMedium == pictureMedium)&&(identical(other.pictureBig, pictureBig) || other.pictureBig == pictureBig)&&(identical(other.pictureXl, pictureXl) || other.pictureXl == pictureXl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,picture,pictureSmall,pictureMedium,pictureBig,pictureXl);

@override
String toString() {
  return 'DeezerGenre(id: $id, name: $name, picture: $picture, pictureSmall: $pictureSmall, pictureMedium: $pictureMedium, pictureBig: $pictureBig, pictureXl: $pictureXl)';
}


}

/// @nodoc
abstract mixin class _$DeezerGenreCopyWith<$Res> implements $DeezerGenreCopyWith<$Res> {
  factory _$DeezerGenreCopyWith(_DeezerGenre value, $Res Function(_DeezerGenre) _then) = __$DeezerGenreCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? picture,@JsonKey(name: 'picture_small') String? pictureSmall,@JsonKey(name: 'picture_medium') String? pictureMedium,@JsonKey(name: 'picture_big') String? pictureBig,@JsonKey(name: 'picture_xl') String? pictureXl
});




}
/// @nodoc
class __$DeezerGenreCopyWithImpl<$Res>
    implements _$DeezerGenreCopyWith<$Res> {
  __$DeezerGenreCopyWithImpl(this._self, this._then);

  final _DeezerGenre _self;
  final $Res Function(_DeezerGenre) _then;

/// Create a copy of DeezerGenre
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? picture = freezed,Object? pictureSmall = freezed,Object? pictureMedium = freezed,Object? pictureBig = freezed,Object? pictureXl = freezed,}) {
  return _then(_DeezerGenre(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,pictureSmall: freezed == pictureSmall ? _self.pictureSmall : pictureSmall // ignore: cast_nullable_to_non_nullable
as String?,pictureMedium: freezed == pictureMedium ? _self.pictureMedium : pictureMedium // ignore: cast_nullable_to_non_nullable
as String?,pictureBig: freezed == pictureBig ? _self.pictureBig : pictureBig // ignore: cast_nullable_to_non_nullable
as String?,pictureXl: freezed == pictureXl ? _self.pictureXl : pictureXl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
