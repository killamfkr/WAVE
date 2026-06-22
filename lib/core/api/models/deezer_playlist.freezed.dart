// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deezer_playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeezerPlaylist {

 int get id; String get title; String? get description; int? get duration;@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? get public;@JsonKey(name: 'is_loved_track', fromJson: boolFromJson, toJson: boolToJson) bool? get isLovedTrack;@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? get collaborative;@JsonKey(name: 'nb_tracks') int? get nbTracks; int? get fans; String? get link; String? get picture;@JsonKey(name: 'picture_small') String? get pictureSmall;@JsonKey(name: 'picture_medium') String? get pictureMedium;@JsonKey(name: 'picture_big') String? get pictureBig;@JsonKey(name: 'picture_xl') String? get pictureXl; DeezerUser? get creator;
/// Create a copy of DeezerPlaylist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeezerPlaylistCopyWith<DeezerPlaylist> get copyWith => _$DeezerPlaylistCopyWithImpl<DeezerPlaylist>(this as DeezerPlaylist, _$identity);

  /// Serializes this DeezerPlaylist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeezerPlaylist&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.public, public) || other.public == public)&&(identical(other.isLovedTrack, isLovedTrack) || other.isLovedTrack == isLovedTrack)&&(identical(other.collaborative, collaborative) || other.collaborative == collaborative)&&(identical(other.nbTracks, nbTracks) || other.nbTracks == nbTracks)&&(identical(other.fans, fans) || other.fans == fans)&&(identical(other.link, link) || other.link == link)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.pictureSmall, pictureSmall) || other.pictureSmall == pictureSmall)&&(identical(other.pictureMedium, pictureMedium) || other.pictureMedium == pictureMedium)&&(identical(other.pictureBig, pictureBig) || other.pictureBig == pictureBig)&&(identical(other.pictureXl, pictureXl) || other.pictureXl == pictureXl)&&(identical(other.creator, creator) || other.creator == creator));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,duration,public,isLovedTrack,collaborative,nbTracks,fans,link,picture,pictureSmall,pictureMedium,pictureBig,pictureXl,creator);

@override
String toString() {
  return 'DeezerPlaylist(id: $id, title: $title, description: $description, duration: $duration, public: $public, isLovedTrack: $isLovedTrack, collaborative: $collaborative, nbTracks: $nbTracks, fans: $fans, link: $link, picture: $picture, pictureSmall: $pictureSmall, pictureMedium: $pictureMedium, pictureBig: $pictureBig, pictureXl: $pictureXl, creator: $creator)';
}


}

/// @nodoc
abstract mixin class $DeezerPlaylistCopyWith<$Res>  {
  factory $DeezerPlaylistCopyWith(DeezerPlaylist value, $Res Function(DeezerPlaylist) _then) = _$DeezerPlaylistCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? description, int? duration,@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? public,@JsonKey(name: 'is_loved_track', fromJson: boolFromJson, toJson: boolToJson) bool? isLovedTrack,@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? collaborative,@JsonKey(name: 'nb_tracks') int? nbTracks, int? fans, String? link, String? picture,@JsonKey(name: 'picture_small') String? pictureSmall,@JsonKey(name: 'picture_medium') String? pictureMedium,@JsonKey(name: 'picture_big') String? pictureBig,@JsonKey(name: 'picture_xl') String? pictureXl, DeezerUser? creator
});


$DeezerUserCopyWith<$Res>? get creator;

}
/// @nodoc
class _$DeezerPlaylistCopyWithImpl<$Res>
    implements $DeezerPlaylistCopyWith<$Res> {
  _$DeezerPlaylistCopyWithImpl(this._self, this._then);

  final DeezerPlaylist _self;
  final $Res Function(DeezerPlaylist) _then;

/// Create a copy of DeezerPlaylist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? duration = freezed,Object? public = freezed,Object? isLovedTrack = freezed,Object? collaborative = freezed,Object? nbTracks = freezed,Object? fans = freezed,Object? link = freezed,Object? picture = freezed,Object? pictureSmall = freezed,Object? pictureMedium = freezed,Object? pictureBig = freezed,Object? pictureXl = freezed,Object? creator = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,isLovedTrack: freezed == isLovedTrack ? _self.isLovedTrack : isLovedTrack // ignore: cast_nullable_to_non_nullable
as bool?,collaborative: freezed == collaborative ? _self.collaborative : collaborative // ignore: cast_nullable_to_non_nullable
as bool?,nbTracks: freezed == nbTracks ? _self.nbTracks : nbTracks // ignore: cast_nullable_to_non_nullable
as int?,fans: freezed == fans ? _self.fans : fans // ignore: cast_nullable_to_non_nullable
as int?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,pictureSmall: freezed == pictureSmall ? _self.pictureSmall : pictureSmall // ignore: cast_nullable_to_non_nullable
as String?,pictureMedium: freezed == pictureMedium ? _self.pictureMedium : pictureMedium // ignore: cast_nullable_to_non_nullable
as String?,pictureBig: freezed == pictureBig ? _self.pictureBig : pictureBig // ignore: cast_nullable_to_non_nullable
as String?,pictureXl: freezed == pictureXl ? _self.pictureXl : pictureXl // ignore: cast_nullable_to_non_nullable
as String?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as DeezerUser?,
  ));
}
/// Create a copy of DeezerPlaylist
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeezerUserCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $DeezerUserCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeezerPlaylist].
extension DeezerPlaylistPatterns on DeezerPlaylist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeezerPlaylist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeezerPlaylist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeezerPlaylist value)  $default,){
final _that = this;
switch (_that) {
case _DeezerPlaylist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeezerPlaylist value)?  $default,){
final _that = this;
switch (_that) {
case _DeezerPlaylist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String? description,  int? duration, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? public, @JsonKey(name: 'is_loved_track', fromJson: boolFromJson, toJson: boolToJson)  bool? isLovedTrack, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? collaborative, @JsonKey(name: 'nb_tracks')  int? nbTracks,  int? fans,  String? link,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl,  DeezerUser? creator)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeezerPlaylist() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.duration,_that.public,_that.isLovedTrack,_that.collaborative,_that.nbTracks,_that.fans,_that.link,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl,_that.creator);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String? description,  int? duration, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? public, @JsonKey(name: 'is_loved_track', fromJson: boolFromJson, toJson: boolToJson)  bool? isLovedTrack, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? collaborative, @JsonKey(name: 'nb_tracks')  int? nbTracks,  int? fans,  String? link,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl,  DeezerUser? creator)  $default,) {final _that = this;
switch (_that) {
case _DeezerPlaylist():
return $default(_that.id,_that.title,_that.description,_that.duration,_that.public,_that.isLovedTrack,_that.collaborative,_that.nbTracks,_that.fans,_that.link,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl,_that.creator);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String? description,  int? duration, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? public, @JsonKey(name: 'is_loved_track', fromJson: boolFromJson, toJson: boolToJson)  bool? isLovedTrack, @JsonKey(fromJson: boolFromJson, toJson: boolToJson)  bool? collaborative, @JsonKey(name: 'nb_tracks')  int? nbTracks,  int? fans,  String? link,  String? picture, @JsonKey(name: 'picture_small')  String? pictureSmall, @JsonKey(name: 'picture_medium')  String? pictureMedium, @JsonKey(name: 'picture_big')  String? pictureBig, @JsonKey(name: 'picture_xl')  String? pictureXl,  DeezerUser? creator)?  $default,) {final _that = this;
switch (_that) {
case _DeezerPlaylist() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.duration,_that.public,_that.isLovedTrack,_that.collaborative,_that.nbTracks,_that.fans,_that.link,_that.picture,_that.pictureSmall,_that.pictureMedium,_that.pictureBig,_that.pictureXl,_that.creator);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeezerPlaylist implements DeezerPlaylist {
  const _DeezerPlaylist({required this.id, required this.title, this.description, this.duration, @JsonKey(fromJson: boolFromJson, toJson: boolToJson) this.public, @JsonKey(name: 'is_loved_track', fromJson: boolFromJson, toJson: boolToJson) this.isLovedTrack, @JsonKey(fromJson: boolFromJson, toJson: boolToJson) this.collaborative, @JsonKey(name: 'nb_tracks') this.nbTracks, this.fans, this.link, this.picture, @JsonKey(name: 'picture_small') this.pictureSmall, @JsonKey(name: 'picture_medium') this.pictureMedium, @JsonKey(name: 'picture_big') this.pictureBig, @JsonKey(name: 'picture_xl') this.pictureXl, this.creator});
  factory _DeezerPlaylist.fromJson(Map<String, dynamic> json) => _$DeezerPlaylistFromJson(json);

@override final  int id;
@override final  String title;
@override final  String? description;
@override final  int? duration;
@override@JsonKey(fromJson: boolFromJson, toJson: boolToJson) final  bool? public;
@override@JsonKey(name: 'is_loved_track', fromJson: boolFromJson, toJson: boolToJson) final  bool? isLovedTrack;
@override@JsonKey(fromJson: boolFromJson, toJson: boolToJson) final  bool? collaborative;
@override@JsonKey(name: 'nb_tracks') final  int? nbTracks;
@override final  int? fans;
@override final  String? link;
@override final  String? picture;
@override@JsonKey(name: 'picture_small') final  String? pictureSmall;
@override@JsonKey(name: 'picture_medium') final  String? pictureMedium;
@override@JsonKey(name: 'picture_big') final  String? pictureBig;
@override@JsonKey(name: 'picture_xl') final  String? pictureXl;
@override final  DeezerUser? creator;

/// Create a copy of DeezerPlaylist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeezerPlaylistCopyWith<_DeezerPlaylist> get copyWith => __$DeezerPlaylistCopyWithImpl<_DeezerPlaylist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeezerPlaylistToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeezerPlaylist&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.public, public) || other.public == public)&&(identical(other.isLovedTrack, isLovedTrack) || other.isLovedTrack == isLovedTrack)&&(identical(other.collaborative, collaborative) || other.collaborative == collaborative)&&(identical(other.nbTracks, nbTracks) || other.nbTracks == nbTracks)&&(identical(other.fans, fans) || other.fans == fans)&&(identical(other.link, link) || other.link == link)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.pictureSmall, pictureSmall) || other.pictureSmall == pictureSmall)&&(identical(other.pictureMedium, pictureMedium) || other.pictureMedium == pictureMedium)&&(identical(other.pictureBig, pictureBig) || other.pictureBig == pictureBig)&&(identical(other.pictureXl, pictureXl) || other.pictureXl == pictureXl)&&(identical(other.creator, creator) || other.creator == creator));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,duration,public,isLovedTrack,collaborative,nbTracks,fans,link,picture,pictureSmall,pictureMedium,pictureBig,pictureXl,creator);

@override
String toString() {
  return 'DeezerPlaylist(id: $id, title: $title, description: $description, duration: $duration, public: $public, isLovedTrack: $isLovedTrack, collaborative: $collaborative, nbTracks: $nbTracks, fans: $fans, link: $link, picture: $picture, pictureSmall: $pictureSmall, pictureMedium: $pictureMedium, pictureBig: $pictureBig, pictureXl: $pictureXl, creator: $creator)';
}


}

/// @nodoc
abstract mixin class _$DeezerPlaylistCopyWith<$Res> implements $DeezerPlaylistCopyWith<$Res> {
  factory _$DeezerPlaylistCopyWith(_DeezerPlaylist value, $Res Function(_DeezerPlaylist) _then) = __$DeezerPlaylistCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? description, int? duration,@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? public,@JsonKey(name: 'is_loved_track', fromJson: boolFromJson, toJson: boolToJson) bool? isLovedTrack,@JsonKey(fromJson: boolFromJson, toJson: boolToJson) bool? collaborative,@JsonKey(name: 'nb_tracks') int? nbTracks, int? fans, String? link, String? picture,@JsonKey(name: 'picture_small') String? pictureSmall,@JsonKey(name: 'picture_medium') String? pictureMedium,@JsonKey(name: 'picture_big') String? pictureBig,@JsonKey(name: 'picture_xl') String? pictureXl, DeezerUser? creator
});


@override $DeezerUserCopyWith<$Res>? get creator;

}
/// @nodoc
class __$DeezerPlaylistCopyWithImpl<$Res>
    implements _$DeezerPlaylistCopyWith<$Res> {
  __$DeezerPlaylistCopyWithImpl(this._self, this._then);

  final _DeezerPlaylist _self;
  final $Res Function(_DeezerPlaylist) _then;

/// Create a copy of DeezerPlaylist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? duration = freezed,Object? public = freezed,Object? isLovedTrack = freezed,Object? collaborative = freezed,Object? nbTracks = freezed,Object? fans = freezed,Object? link = freezed,Object? picture = freezed,Object? pictureSmall = freezed,Object? pictureMedium = freezed,Object? pictureBig = freezed,Object? pictureXl = freezed,Object? creator = freezed,}) {
  return _then(_DeezerPlaylist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,public: freezed == public ? _self.public : public // ignore: cast_nullable_to_non_nullable
as bool?,isLovedTrack: freezed == isLovedTrack ? _self.isLovedTrack : isLovedTrack // ignore: cast_nullable_to_non_nullable
as bool?,collaborative: freezed == collaborative ? _self.collaborative : collaborative // ignore: cast_nullable_to_non_nullable
as bool?,nbTracks: freezed == nbTracks ? _self.nbTracks : nbTracks // ignore: cast_nullable_to_non_nullable
as int?,fans: freezed == fans ? _self.fans : fans // ignore: cast_nullable_to_non_nullable
as int?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as String?,pictureSmall: freezed == pictureSmall ? _self.pictureSmall : pictureSmall // ignore: cast_nullable_to_non_nullable
as String?,pictureMedium: freezed == pictureMedium ? _self.pictureMedium : pictureMedium // ignore: cast_nullable_to_non_nullable
as String?,pictureBig: freezed == pictureBig ? _self.pictureBig : pictureBig // ignore: cast_nullable_to_non_nullable
as String?,pictureXl: freezed == pictureXl ? _self.pictureXl : pictureXl // ignore: cast_nullable_to_non_nullable
as String?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as DeezerUser?,
  ));
}

/// Create a copy of DeezerPlaylist
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeezerUserCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $DeezerUserCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}

// dart format on
