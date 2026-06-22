// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deezer_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeezerUser {

 int get id; String get name; String? get lastname; String? get firstname; String? get email; String? get country; String? get lang; String? get picture;@JsonKey(name: 'picture_small') String? get pictureSmall;@JsonKey(name: 'picture_medium') String? get pictureMedium;@JsonKey(name: 'picture_big') String? get pictureBig;@JsonKey(name: 'picture_xl') String? get pictureXl;
/// Create a copy of DeezerUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeezerUserCopyWith<DeezerUser> get copyWith => _$DeezerUserCopyWithImpl<DeezerUser>(this as DeezerUser, _$identity);

  /// Serializes this DeezerUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeezerUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.lastname, lastname) || other.lastname == lastname)&&(identical(other.firstname, firstname) || other.firstname == firstname)&&(identical(other.email, email) || other.email == email)&&(identical(other.country, country) || other.country == country)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.pictureSmall, pictureSmall) || other.pictureSmall == pictureSmall)&&(identical(other.pictureMedium, pictureMedium) || other.pictureMedium == pictureMedium)&&(identical(other.pictureBig, pictureBig) || other.pictureBig == pictureBig)&&(identical(other.pictureXl, pictureXl) || other.pictureXl == pictureXl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,lastname,firstname,email,country,lang,picture,pictureSmall,pictureMedium,pictureBig,pictureXl);

@override
String toString() {
  return 'DeezerUser(id: $id, name: $name, lastname: $lastname, firstname: $firstname, email: $email, country: $country, lang: $lang, picture: $picture, pictureSmall: $pictureSmall, pictureMedium: $pictureMedium, pictureBig: $pictureBig, pictureXl: $pictureXl)';
}


}

/// @nodoc
abstract mixin class $DeezerUserCopyWith<$Res>  {
  factory $DeezerUserCopyWith(DeezerUser value, $Res Function(DeezerUser) _then) = _$DeezerUserCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? lastname, String? firstname, String? email, String? country, String? lang, String? picture,@JsonKey(name: 'picture_small') String? pictureSmall,@JsonKey(name: 'picture_medium') String? pictureMedium,@JsonKey(name: 'picture_big') String? pictureBig,@JsonKey(name: 'picture_xl') String? pictureXl
});




}
/// @nodoc
class _$DeezerUserCopyWithImpl<$Res>
    implements $DeezerUserCopyWith<$Res> {
  _$DeezerUserCopyWithImpl(this._self, this._then);

  final DeezerUser _self;
  final $Res Function(DeezerUser) _then;

/// Create a copy of DeezerUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? lastname = freezed,Object? firstname = freezed,Object? email = freezed,Object? country = freezed,Object? lang = freezed,Object? picture = freezed,Object? pictureSmall = freezed,Object? pictureMedium = freezed,Object? pictureBig = freezed,Object? pictureXl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lastname: freezed == lastname ? _self.lastname : lastname // ignore: cast_nullable_to_non_nullable
as String?,firstname: freezed == firstname ? _self.firstname : firstname // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,pictureSmall: freezed == pictureSmall ? _self.pictureSmall : pictureSmall // ignore: cast_nullable_to_non_nullable
as String?,pictureMedium: freezed == pictureMedium ? _self.pictureMedium : pictureMedium // ignore: cast_nullable_to_non_nullable
as String?,pictureBig: freezed == pictureBig ? _self.pictureBig : pictureBig // ignore: cast_nullable_to_non_nullable
as String?,pictureXl: freezed == pictureXl ? _self.pictureXl : pictureXl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeezerUser].
extension DeezerUserPatterns on DeezerUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeezerUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeezerUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeezerUser value)  $default,){
final _that = this;
switch (_that) {
case _DeezerUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeezerUser value)?  $default,){
final _that = this;
switch (_that) {
case _DeezerUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? lastname,  String? firstname,  String? email,  String? country,  String? lang,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeezerUser() when $default != null:
return $default(_that.id,_that.name,_that.lastname,_that.firstname,_that.email,_that.country,_that.lang,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? lastname,  String? firstname,  String? email,  String? country,  String? lang,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl)  $default,) {final _that = this;
switch (_that) {
case _DeezerUser():
return $default(_that.id,_that.name,_that.lastname,_that.firstname,_that.email,_that.country,_that.lang,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? lastname,  String? firstname,  String? email,  String? country,  String? lang,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl)?  $default,) {final _that = this;
switch (_that) {
case _DeezerUser() when $default != null:
return $default(_that.id,_that.name,_that.lastname,_that.firstname,_that.email,_that.country,_that.lang,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeezerUser implements DeezerUser {
  const _DeezerUser({required this.id, required this.name, this.lastname, this.firstname, this.email, this.country, this.lang, this.picture, @JsonKey(name: 'picture_small') this.pictureSmall, @JsonKey(name: 'picture_medium') this.pictureMedium, @JsonKey(name: 'picture_big') this.pictureBig, @JsonKey(name: 'picture_xl') this.pictureXl});
  factory _DeezerUser.fromJson(Map<String, dynamic> json) => _$DeezerUserFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? lastname;
@override final  String? firstname;
@override final  String? email;
@override final  String? country;
@override final  String? lang;
@override final  String? picture;
@override@JsonKey(name: 'picture_small') final  String? pictureSmall;
@override@JsonKey(name: 'picture_medium') final  String? pictureMedium;
@override@JsonKey(name: 'picture_big') final  String? pictureBig;
@override@JsonKey(name: 'picture_xl') final  String? pictureXl;

/// Create a copy of DeezerUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeezerUserCopyWith<_DeezerUser> get copyWith => __$DeezerUserCopyWithImpl<_DeezerUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeezerUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeezerUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.lastname, lastname) || other.lastname == lastname)&&(identical(other.firstname, firstname) || other.firstname == firstname)&&(identical(other.email, email) || other.email == email)&&(identical(other.country, country) || other.country == country)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.pictureSmall, pictureSmall) || other.pictureSmall == pictureSmall)&&(identical(other.pictureMedium, pictureMedium) || other.pictureMedium == pictureMedium)&&(identical(other.pictureBig, pictureBig) || other.pictureBig == pictureBig)&&(identical(other.pictureXl, pictureXl) || other.pictureXl == pictureXl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,lastname,firstname,email,country,lang,picture,pictureSmall,pictureMedium,pictureBig,pictureXl);

@override
String toString() {
  return 'DeezerUser(id: $id, name: $name, lastname: $lastname, firstname: $firstname, email: $email, country: $country, lang: $lang, picture: $picture, pictureSmall: $pictureSmall, pictureMedium: $pictureMedium, pictureBig: $pictureBig, pictureXl: $pictureXl)';
}


}

/// @nodoc
abstract mixin class _$DeezerUserCopyWith<$Res> implements $DeezerUserCopyWith<$Res> {
  factory _$DeezerUserCopyWith(_DeezerUser value, $Res Function(_DeezerUser) _then) = __$DeezerUserCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? lastname, String? firstname, String? email, String? country, String? lang, String? picture,@JsonKey(name: 'picture_small') String? pictureSmall,@JsonKey(name: 'picture_medium') String? pictureMedium,@JsonKey(name: 'picture_big') String? pictureBig,@JsonKey(name: 'picture_xl') String? pictureXl
});




}
/// @nodoc
class __$DeezerUserCopyWithImpl<$Res>
    implements _$DeezerUserCopyWith<$Res> {
  __$DeezerUserCopyWithImpl(this._self, this._then);

  final _DeezerUser _self;
  final $Res Function(_DeezerUser) _then;

/// Create a copy of DeezerUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? lastname = freezed,Object? firstname = freezed,Object? email = freezed,Object? country = freezed,Object? lang = freezed,Object? picture = freezed,Object? pictureSmall = freezed,Object? pictureMedium = freezed,Object? pictureBig = freezed,Object? pictureXl = freezed,}) {
  return _then(_DeezerUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lastname: freezed == lastname ? _self.lastname : lastname // ignore: cast_nullable_to_non_nullable
as String?,firstname: freezed == firstname ? _self.firstname : firstname // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,pictureSmall: freezed == pictureSmall ? _self.pictureSmall : pictureSmall // ignore: cast_nullable_to_non_nullable
as String?,pictureMedium: freezed == pictureMedium ? _self.pictureMedium : pictureMedium // ignore: cast_nullable_to_non_nullable
as String?,pictureBig: freezed == pictureBig ? _self.pictureBig : pictureBig // ignore: cast_nullable_to_non_nullable
as String?,pictureXl: freezed == pictureXl ? _self.pictureXl : pictureXl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
