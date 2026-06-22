// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deezer_album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeezerAlbum {

 int get id; String get title; String? get link; String? get cover;@JsonKey(name: 'cover_small') String? get coverSmall;@JsonKey(name: 'cover_medium') String? get coverMedium;@JsonKey(name: 'cover_big') String? get coverBig;@JsonKey(name: 'cover_xl') String? get coverXl;@JsonKey(name: 'md5_image') String? get md5Image;@JsonKey(name: 'release_date') String? get releaseDate;@JsonKey(name: 'record_type') String? get recordType; int? get duration;@JsonKey(name: 'nb_tracks') int? get nbTracks; DeezerArtist? get artist;
/// Create a copy of DeezerAlbum
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeezerAlbumCopyWith<DeezerAlbum> get copyWith => _$DeezerAlbumCopyWithImpl<DeezerAlbum>(this as DeezerAlbum, _$identity);

  /// Serializes this DeezerAlbum to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeezerAlbum&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.link, link) || other.link == link)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.coverSmall, coverSmall) || other.coverSmall == coverSmall)&&(identical(other.coverMedium, coverMedium) || other.coverMedium == coverMedium)&&(identical(other.coverBig, coverBig) || other.coverBig == coverBig)&&(identical(other.coverXl, coverXl) || other.coverXl == coverXl)&&(identical(other.md5Image, md5Image) || other.md5Image == md5Image)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.recordType, recordType) || other.recordType == recordType)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.nbTracks, nbTracks) || other.nbTracks == nbTracks)&&(identical(other.artist, artist) || other.artist == artist));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,link,cover,coverSmall,coverMedium,coverBig,coverXl,md5Image,releaseDate,recordType,duration,nbTracks,artist);

@override
String toString() {
  return 'DeezerAlbum(id: $id, title: $title, link: $link, cover: $cover, coverSmall: $coverSmall, coverMedium: $coverMedium, coverBig: $coverBig, coverXl: $coverXl, md5Image: $md5Image, releaseDate: $releaseDate, recordType: $recordType, duration: $duration, nbTracks: $nbTracks, artist: $artist)';
}


}

/// @nodoc
abstract mixin class $DeezerAlbumCopyWith<$Res>  {
  factory $DeezerAlbumCopyWith(DeezerAlbum value, $Res Function(DeezerAlbum) _then) = _$DeezerAlbumCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? link, String? cover,@JsonKey(name: 'cover_small') String? coverSmall,@JsonKey(name: 'cover_medium') String? coverMedium,@JsonKey(name: 'cover_big') String? coverBig,@JsonKey(name: 'cover_xl') String? coverXl,@JsonKey(name: 'md5_image') String? md5Image,@JsonKey(name: 'release_date') String? releaseDate,@JsonKey(name: 'record_type') String? recordType, int? duration,@JsonKey(name: 'nb_tracks') int? nbTracks, DeezerArtist? artist
});


$DeezerArtistCopyWith<$Res>? get artist;

}
/// @nodoc
class _$DeezerAlbumCopyWithImpl<$Res>
    implements $DeezerAlbumCopyWith<$Res> {
  _$DeezerAlbumCopyWithImpl(this._self, this._then);

  final DeezerAlbum _self;
  final $Res Function(DeezerAlbum) _then;

/// Create a copy of DeezerAlbum
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? link = freezed,Object? cover = freezed,Object? coverSmall = freezed,Object? coverMedium = freezed,Object? coverBig = freezed,Object? coverXl = freezed,Object? md5Image = freezed,Object? releaseDate = freezed,Object? recordType = freezed,Object? duration = freezed,Object? nbTracks = freezed,Object? artist = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,coverSmall: freezed == coverSmall ? _self.coverSmall : coverSmall // ignore: cast_nullable_to_non_nullable
as String?,coverMedium: freezed == coverMedium ? _self.coverMedium : coverMedium // ignore: cast_nullable_to_non_nullable
as String?,coverBig: freezed == coverBig ? _self.coverBig : coverBig // ignore: cast_nullable_to_non_nullable
as String?,coverXl: freezed == coverXl ? _self.coverXl : coverXl // ignore: cast_nullable_to_non_nullable
as String?,md5Image: freezed == md5Image ? _self.md5Image : md5Image // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,recordType: freezed == recordType ? _self.recordType : recordType // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,nbTracks: freezed == nbTracks ? _self.nbTracks : nbTracks // ignore: cast_nullable_to_non_nullable
as int?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as DeezerArtist?,
  ));
}
/// Create a copy of DeezerAlbum
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeezerArtistCopyWith<$Res>? get artist {
    if (_self.artist == null) {
    return null;
  }

  return $DeezerArtistCopyWith<$Res>(_self.artist!, (value) {
    return _then(_self.copyWith(artist: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeezerAlbum].
extension DeezerAlbumPatterns on DeezerAlbum {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeezerAlbum value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeezerAlbum() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeezerAlbum value)  $default,){
final _that = this;
switch (_that) {
case _DeezerAlbum():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeezerAlbum value)?  $default,){
final _that = this;
switch (_that) {
case _DeezerAlbum() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String? link,  String? cover, @JsonKey(name: 'cover_small')  String? coverSmall, @JsonKey(name: 'cover_medium')  String? coverMedium, @JsonKey(name: 'cover_big')  String? coverBig, @JsonKey(name: 'cover_xl')  String? coverXl, @JsonKey(name: 'md5_image')  String? md5Image, @JsonKey(name: 'release_date')  String? releaseDate, @JsonKey(name: 'record_type')  String? recordType,  int? duration, @JsonKey(name: 'nb_tracks')  int? nbTracks,  DeezerArtist? artist)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeezerAlbum() when $default != null:
return $default(_that.id,_that.title,_that.link,_that.cover,_that.coverSmall,_that.coverMedium,_that.coverBig,_that.coverXl,_that.md5Image,_that.releaseDate,_that.recordType,_that.duration,_that.nbTracks,_that.artist);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String? link,  String? cover, @JsonKey(name: 'cover_small')  String? coverSmall, @JsonKey(name: 'cover_medium')  String? coverMedium, @JsonKey(name: 'cover_big')  String? coverBig, @JsonKey(name: 'cover_xl')  String? coverXl, @JsonKey(name: 'md5_image')  String? md5Image, @JsonKey(name: 'release_date')  String? releaseDate, @JsonKey(name: 'record_type')  String? recordType,  int? duration, @JsonKey(name: 'nb_tracks')  int? nbTracks,  DeezerArtist? artist)  $default,) {final _that = this;
switch (_that) {
case _DeezerAlbum():
return $default(_that.id,_that.title,_that.link,_that.cover,_that.coverSmall,_that.coverMedium,_that.coverBig,_that.coverXl,_that.md5Image,_that.releaseDate,_that.recordType,_that.duration,_that.nbTracks,_that.artist);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String? link,  String? cover, @JsonKey(name: 'cover_small')  String? coverSmall, @JsonKey(name: 'cover_medium')  String? coverMedium, @JsonKey(name: 'cover_big')  String? coverBig, @JsonKey(name: 'cover_xl')  String? coverXl, @JsonKey(name: 'md5_image')  String? md5Image, @JsonKey(name: 'release_date')  String? releaseDate, @JsonKey(name: 'record_type')  String? recordType,  int? duration, @JsonKey(name: 'nb_tracks')  int? nbTracks,  DeezerArtist? artist)?  $default,) {final _that = this;
switch (_that) {
case _DeezerAlbum() when $default != null:
return $default(_that.id,_that.title,_that.link,_that.cover,_that.coverSmall,_that.coverMedium,_that.coverBig,_that.coverXl,_that.md5Image,_that.releaseDate,_that.recordType,_that.duration,_that.nbTracks,_that.artist);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeezerAlbum implements DeezerAlbum {
  const _DeezerAlbum({required this.id, required this.title, this.link, this.cover, @JsonKey(name: 'cover_small') this.coverSmall, @JsonKey(name: 'cover_medium') this.coverMedium, @JsonKey(name: 'cover_big') this.coverBig, @JsonKey(name: 'cover_xl') this.coverXl, @JsonKey(name: 'md5_image') this.md5Image, @JsonKey(name: 'release_date') this.releaseDate, @JsonKey(name: 'record_type') this.recordType, this.duration, @JsonKey(name: 'nb_tracks') this.nbTracks, this.artist});
  factory _DeezerAlbum.fromJson(Map<String, dynamic> json) => _$DeezerAlbumFromJson(json);

@override final  int id;
@override final  String title;
@override final  String? link;
@override final  String? cover;
@override@JsonKey(name: 'cover_small') final  String? coverSmall;
@override@JsonKey(name: 'cover_medium') final  String? coverMedium;
@override@JsonKey(name: 'cover_big') final  String? coverBig;
@override@JsonKey(name: 'cover_xl') final  String? coverXl;
@override@JsonKey(name: 'md5_image') final  String? md5Image;
@override@JsonKey(name: 'release_date') final  String? releaseDate;
@override@JsonKey(name: 'record_type') final  String? recordType;
@override final  int? duration;
@override@JsonKey(name: 'nb_tracks') final  int? nbTracks;
@override final  DeezerArtist? artist;

/// Create a copy of DeezerAlbum
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeezerAlbumCopyWith<_DeezerAlbum> get copyWith => __$DeezerAlbumCopyWithImpl<_DeezerAlbum>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeezerAlbumToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeezerAlbum&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.link, link) || other.link == link)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.coverSmall, coverSmall) || other.coverSmall == coverSmall)&&(identical(other.coverMedium, coverMedium) || other.coverMedium == coverMedium)&&(identical(other.coverBig, coverBig) || other.coverBig == coverBig)&&(identical(other.coverXl, coverXl) || other.coverXl == coverXl)&&(identical(other.md5Image, md5Image) || other.md5Image == md5Image)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.recordType, recordType) || other.recordType == recordType)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.nbTracks, nbTracks) || other.nbTracks == nbTracks)&&(identical(other.artist, artist) || other.artist == artist));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,link,cover,coverSmall,coverMedium,coverBig,coverXl,md5Image,releaseDate,recordType,duration,nbTracks,artist);

@override
String toString() {
  return 'DeezerAlbum(id: $id, title: $title, link: $link, cover: $cover, coverSmall: $coverSmall, coverMedium: $coverMedium, coverBig: $coverBig, coverXl: $coverXl, md5Image: $md5Image, releaseDate: $releaseDate, recordType: $recordType, duration: $duration, nbTracks: $nbTracks, artist: $artist)';
}


}

/// @nodoc
abstract mixin class _$DeezerAlbumCopyWith<$Res> implements $DeezerAlbumCopyWith<$Res> {
  factory _$DeezerAlbumCopyWith(_DeezerAlbum value, $Res Function(_DeezerAlbum) _then) = __$DeezerAlbumCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? link, String? cover,@JsonKey(name: 'cover_small') String? coverSmall,@JsonKey(name: 'cover_medium') String? coverMedium,@JsonKey(name: 'cover_big') String? coverBig,@JsonKey(name: 'cover_xl') String? coverXl,@JsonKey(name: 'md5_image') String? md5Image,@JsonKey(name: 'release_date') String? releaseDate,@JsonKey(name: 'record_type') String? recordType, int? duration,@JsonKey(name: 'nb_tracks') int? nbTracks, DeezerArtist? artist
});


@override $DeezerArtistCopyWith<$Res>? get artist;

}
/// @nodoc
class __$DeezerAlbumCopyWithImpl<$Res>
    implements _$DeezerAlbumCopyWith<$Res> {
  __$DeezerAlbumCopyWithImpl(this._self, this._then);

  final _DeezerAlbum _self;
  final $Res Function(_DeezerAlbum) _then;

/// Create a copy of DeezerAlbum
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? link = freezed,Object? cover = freezed,Object? coverSmall = freezed,Object? coverMedium = freezed,Object? coverBig = freezed,Object? coverXl = freezed,Object? md5Image = freezed,Object? releaseDate = freezed,Object? recordType = freezed,Object? duration = freezed,Object? nbTracks = freezed,Object? artist = freezed,}) {
  return _then(_DeezerAlbum(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,coverSmall: freezed == coverSmall ? _self.coverSmall : coverSmall // ignore: cast_nullable_to_non_nullable
as String?,coverMedium: freezed == coverMedium ? _self.coverMedium : coverMedium // ignore: cast_nullable_to_non_nullable
as String?,coverBig: freezed == coverBig ? _self.coverBig : coverBig // ignore: cast_nullable_to_non_nullable
as String?,coverXl: freezed == coverXl ? _self.coverXl : coverXl // ignore: cast_nullable_to_non_nullable
as String?,md5Image: freezed == md5Image ? _self.md5Image : md5Image // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,recordType: freezed == recordType ? _self.recordType : recordType // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,nbTracks: freezed == nbTracks ? _self.nbTracks : nbTracks // ignore: cast_nullable_to_non_nullable
as int?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as DeezerArtist?,
  ));
}

/// Create a copy of DeezerAlbum
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeezerArtistCopyWith<$Res>? get artist {
    if (_self.artist == null) {
    return null;
  }

  return $DeezerArtistCopyWith<$Res>(_self.artist!, (value) {
    return _then(_self.copyWith(artist: value));
  });
}
}

// dart format on
