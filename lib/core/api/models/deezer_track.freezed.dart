// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deezer_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeezerTrack {

 int get id; String get title;@JsonKey(name: 'title_short') String? get titleShort;@JsonKey(name: 'title_version') String? get titleVersion; String? get link; int? get duration; int? get rank;@JsonKey(name: 'explicit_lyrics', fromJson: boolFromJson, toJson: boolToJson) bool? get explicitLyrics; String? get preview; DeezerArtist? get artist; DeezerAlbum? get album;
/// Create a copy of DeezerTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeezerTrackCopyWith<DeezerTrack> get copyWith => _$DeezerTrackCopyWithImpl<DeezerTrack>(this as DeezerTrack, _$identity);

  /// Serializes this DeezerTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeezerTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.titleShort, titleShort) || other.titleShort == titleShort)&&(identical(other.titleVersion, titleVersion) || other.titleVersion == titleVersion)&&(identical(other.link, link) || other.link == link)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.explicitLyrics, explicitLyrics) || other.explicitLyrics == explicitLyrics)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,titleShort,titleVersion,link,duration,rank,explicitLyrics,preview,artist,album);

@override
String toString() {
  return 'DeezerTrack(id: $id, title: $title, titleShort: $titleShort, titleVersion: $titleVersion, link: $link, duration: $duration, rank: $rank, explicitLyrics: $explicitLyrics, preview: $preview, artist: $artist, album: $album)';
}


}

/// @nodoc
abstract mixin class $DeezerTrackCopyWith<$Res>  {
  factory $DeezerTrackCopyWith(DeezerTrack value, $Res Function(DeezerTrack) _then) = _$DeezerTrackCopyWithImpl;
@useResult
$Res call({
 int id, String title,@JsonKey(name: 'title_short') String? titleShort,@JsonKey(name: 'title_version') String? titleVersion, String? link, int? duration, int? rank,@JsonKey(name: 'explicit_lyrics', fromJson: boolFromJson, toJson: boolToJson) bool? explicitLyrics, String? preview, DeezerArtist? artist, DeezerAlbum? album
});


$DeezerArtistCopyWith<$Res>? get artist;$DeezerAlbumCopyWith<$Res>? get album;

}
/// @nodoc
class _$DeezerTrackCopyWithImpl<$Res>
    implements $DeezerTrackCopyWith<$Res> {
  _$DeezerTrackCopyWithImpl(this._self, this._then);

  final DeezerTrack _self;
  final $Res Function(DeezerTrack) _then;

/// Create a copy of DeezerTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? titleShort = freezed,Object? titleVersion = freezed,Object? link = freezed,Object? duration = freezed,Object? rank = freezed,Object? explicitLyrics = freezed,Object? preview = freezed,Object? artist = freezed,Object? album = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,titleShort: freezed == titleShort ? _self.titleShort : titleShort // ignore: cast_nullable_to_non_nullable
as String?,titleVersion: freezed == titleVersion ? _self.titleVersion : titleVersion // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,explicitLyrics: freezed == explicitLyrics ? _self.explicitLyrics : explicitLyrics // ignore: cast_nullable_to_non_nullable
as bool?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as DeezerArtist?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as DeezerAlbum?,
  ));
}
/// Create a copy of DeezerTrack
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
}/// Create a copy of DeezerTrack
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeezerAlbumCopyWith<$Res>? get album {
    if (_self.album == null) {
    return null;
  }

  return $DeezerAlbumCopyWith<$Res>(_self.album!, (value) {
    return _then(_self.copyWith(album: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeezerTrack].
extension DeezerTrackPatterns on DeezerTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeezerTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeezerTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeezerTrack value)  $default,){
final _that = this;
switch (_that) {
case _DeezerTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeezerTrack value)?  $default,){
final _that = this;
switch (_that) {
case _DeezerTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title, @JsonKey(name: 'title_short')  String? titleShort, @JsonKey(name: 'title_version')  String? titleVersion,  String? link,  int? duration,  int? rank, @JsonKey(name: 'explicit_lyrics', fromJson: boolFromJson, toJson: boolToJson)  bool? explicitLyrics,  String? preview,  DeezerArtist? artist,  DeezerAlbum? album)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeezerTrack() when $default != null:
return $default(_that.id,_that.title,_that.titleShort,_that.titleVersion,_that.link,_that.duration,_that.rank,_that.explicitLyrics,_that.preview,_that.artist,_that.album);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title, @JsonKey(name: 'title_short')  String? titleShort, @JsonKey(name: 'title_version')  String? titleVersion,  String? link,  int? duration,  int? rank, @JsonKey(name: 'explicit_lyrics', fromJson: boolFromJson, toJson: boolToJson)  bool? explicitLyrics,  String? preview,  DeezerArtist? artist,  DeezerAlbum? album)  $default,) {final _that = this;
switch (_that) {
case _DeezerTrack():
return $default(_that.id,_that.title,_that.titleShort,_that.titleVersion,_that.link,_that.duration,_that.rank,_that.explicitLyrics,_that.preview,_that.artist,_that.album);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title, @JsonKey(name: 'title_short')  String? titleShort, @JsonKey(name: 'title_version')  String? titleVersion,  String? link,  int? duration,  int? rank, @JsonKey(name: 'explicit_lyrics', fromJson: boolFromJson, toJson: boolToJson)  bool? explicitLyrics,  String? preview,  DeezerArtist? artist,  DeezerAlbum? album)?  $default,) {final _that = this;
switch (_that) {
case _DeezerTrack() when $default != null:
return $default(_that.id,_that.title,_that.titleShort,_that.titleVersion,_that.link,_that.duration,_that.rank,_that.explicitLyrics,_that.preview,_that.artist,_that.album);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeezerTrack implements DeezerTrack {
  const _DeezerTrack({required this.id, required this.title, @JsonKey(name: 'title_short') this.titleShort, @JsonKey(name: 'title_version') this.titleVersion, this.link, this.duration, this.rank, @JsonKey(name: 'explicit_lyrics', fromJson: boolFromJson, toJson: boolToJson) this.explicitLyrics, this.preview, this.artist, this.album});
  factory _DeezerTrack.fromJson(Map<String, dynamic> json) => _$DeezerTrackFromJson(json);

@override final  int id;
@override final  String title;
@override@JsonKey(name: 'title_short') final  String? titleShort;
@override@JsonKey(name: 'title_version') final  String? titleVersion;
@override final  String? link;
@override final  int? duration;
@override final  int? rank;
@override@JsonKey(name: 'explicit_lyrics', fromJson: boolFromJson, toJson: boolToJson) final  bool? explicitLyrics;
@override final  String? preview;
@override final  DeezerArtist? artist;
@override final  DeezerAlbum? album;

/// Create a copy of DeezerTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeezerTrackCopyWith<_DeezerTrack> get copyWith => __$DeezerTrackCopyWithImpl<_DeezerTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeezerTrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeezerTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.titleShort, titleShort) || other.titleShort == titleShort)&&(identical(other.titleVersion, titleVersion) || other.titleVersion == titleVersion)&&(identical(other.link, link) || other.link == link)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.explicitLyrics, explicitLyrics) || other.explicitLyrics == explicitLyrics)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,titleShort,titleVersion,link,duration,rank,explicitLyrics,preview,artist,album);

@override
String toString() {
  return 'DeezerTrack(id: $id, title: $title, titleShort: $titleShort, titleVersion: $titleVersion, link: $link, duration: $duration, rank: $rank, explicitLyrics: $explicitLyrics, preview: $preview, artist: $artist, album: $album)';
}


}

/// @nodoc
abstract mixin class _$DeezerTrackCopyWith<$Res> implements $DeezerTrackCopyWith<$Res> {
  factory _$DeezerTrackCopyWith(_DeezerTrack value, $Res Function(_DeezerTrack) _then) = __$DeezerTrackCopyWithImpl;
@override @useResult
$Res call({
 int id, String title,@JsonKey(name: 'title_short') String? titleShort,@JsonKey(name: 'title_version') String? titleVersion, String? link, int? duration, int? rank,@JsonKey(name: 'explicit_lyrics', fromJson: boolFromJson, toJson: boolToJson) bool? explicitLyrics, String? preview, DeezerArtist? artist, DeezerAlbum? album
});


@override $DeezerArtistCopyWith<$Res>? get artist;@override $DeezerAlbumCopyWith<$Res>? get album;

}
/// @nodoc
class __$DeezerTrackCopyWithImpl<$Res>
    implements _$DeezerTrackCopyWith<$Res> {
  __$DeezerTrackCopyWithImpl(this._self, this._then);

  final _DeezerTrack _self;
  final $Res Function(_DeezerTrack) _then;

/// Create a copy of DeezerTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? titleShort = freezed,Object? titleVersion = freezed,Object? link = freezed,Object? duration = freezed,Object? rank = freezed,Object? explicitLyrics = freezed,Object? preview = freezed,Object? artist = freezed,Object? album = freezed,}) {
  return _then(_DeezerTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,titleShort: freezed == titleShort ? _self.titleShort : titleShort // ignore: cast_nullable_to_non_nullable
as String?,titleVersion: freezed == titleVersion ? _self.titleVersion : titleVersion // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,explicitLyrics: freezed == explicitLyrics ? _self.explicitLyrics : explicitLyrics // ignore: cast_nullable_to_non_nullable
as bool?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as DeezerArtist?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as DeezerAlbum?,
  ));
}

/// Create a copy of DeezerTrack
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
}/// Create a copy of DeezerTrack
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeezerAlbumCopyWith<$Res>? get album {
    if (_self.album == null) {
    return null;
  }

  return $DeezerAlbumCopyWith<$Res>(_self.album!, (value) {
    return _then(_self.copyWith(album: value));
  });
}
}

// dart format on
