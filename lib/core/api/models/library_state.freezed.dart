// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LibraryState {

 List<DeezerTrack> get likedTracks; List<DeezerAlbum> get likedAlbums; List<DeezerArtist> get followedArtists; List<DeezerPlaylist> get playlists; List<int> get downloadedTrackIds;
/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibraryStateCopyWith<LibraryState> get copyWith => _$LibraryStateCopyWithImpl<LibraryState>(this as LibraryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibraryState&&const DeepCollectionEquality().equals(other.likedTracks, likedTracks)&&const DeepCollectionEquality().equals(other.likedAlbums, likedAlbums)&&const DeepCollectionEquality().equals(other.followedArtists, followedArtists)&&const DeepCollectionEquality().equals(other.playlists, playlists)&&const DeepCollectionEquality().equals(other.downloadedTrackIds, downloadedTrackIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(likedTracks),const DeepCollectionEquality().hash(likedAlbums),const DeepCollectionEquality().hash(followedArtists),const DeepCollectionEquality().hash(playlists),const DeepCollectionEquality().hash(downloadedTrackIds));

@override
String toString() {
  return 'LibraryState(likedTracks: $likedTracks, likedAlbums: $likedAlbums, followedArtists: $followedArtists, playlists: $playlists, downloadedTrackIds: $downloadedTrackIds)';
}


}

/// @nodoc
abstract mixin class $LibraryStateCopyWith<$Res>  {
  factory $LibraryStateCopyWith(LibraryState value, $Res Function(LibraryState) _then) = _$LibraryStateCopyWithImpl;
@useResult
$Res call({
 List<DeezerTrack> likedTracks, List<DeezerAlbum> likedAlbums, List<DeezerArtist> followedArtists, List<DeezerPlaylist> playlists, List<int> downloadedTrackIds
});




}
/// @nodoc
class _$LibraryStateCopyWithImpl<$Res>
    implements $LibraryStateCopyWith<$Res> {
  _$LibraryStateCopyWithImpl(this._self, this._then);

  final LibraryState _self;
  final $Res Function(LibraryState) _then;

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? likedTracks = null,Object? likedAlbums = null,Object? followedArtists = null,Object? playlists = null,Object? downloadedTrackIds = null,}) {
  return _then(_self.copyWith(
likedTracks: null == likedTracks ? _self.likedTracks : likedTracks // ignore: cast_nullable_to_non_nullable
as List<DeezerTrack>,likedAlbums: null == likedAlbums ? _self.likedAlbums : likedAlbums // ignore: cast_nullable_to_non_nullable
as List<DeezerAlbum>,followedArtists: null == followedArtists ? _self.followedArtists : followedArtists // ignore: cast_nullable_to_non_nullable
as List<DeezerArtist>,playlists: null == playlists ? _self.playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<DeezerPlaylist>,downloadedTrackIds: null == downloadedTrackIds ? _self.downloadedTrackIds : downloadedTrackIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [LibraryState].
extension LibraryStatePatterns on LibraryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LibraryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LibraryState value)  $default,){
final _that = this;
switch (_that) {
case _LibraryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LibraryState value)?  $default,){
final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DeezerTrack> likedTracks,  List<DeezerAlbum> likedAlbums,  List<DeezerArtist> followedArtists,  List<DeezerPlaylist> playlists,  List<int> downloadedTrackIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
return $default(_that.likedTracks,_that.likedAlbums,_that.followedArtists,_that.playlists,_that.downloadedTrackIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DeezerTrack> likedTracks,  List<DeezerAlbum> likedAlbums,  List<DeezerArtist> followedArtists,  List<DeezerPlaylist> playlists,  List<int> downloadedTrackIds)  $default,) {final _that = this;
switch (_that) {
case _LibraryState():
return $default(_that.likedTracks,_that.likedAlbums,_that.followedArtists,_that.playlists,_that.downloadedTrackIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DeezerTrack> likedTracks,  List<DeezerAlbum> likedAlbums,  List<DeezerArtist> followedArtists,  List<DeezerPlaylist> playlists,  List<int> downloadedTrackIds)?  $default,) {final _that = this;
switch (_that) {
case _LibraryState() when $default != null:
return $default(_that.likedTracks,_that.likedAlbums,_that.followedArtists,_that.playlists,_that.downloadedTrackIds);case _:
  return null;

}
}

}

/// @nodoc


class _LibraryState implements LibraryState {
  const _LibraryState({final  List<DeezerTrack> likedTracks = const <DeezerTrack>[], final  List<DeezerAlbum> likedAlbums = const <DeezerAlbum>[], final  List<DeezerArtist> followedArtists = const <DeezerArtist>[], final  List<DeezerPlaylist> playlists = const <DeezerPlaylist>[], final  List<int> downloadedTrackIds = const <int>[]}): _likedTracks = likedTracks,_likedAlbums = likedAlbums,_followedArtists = followedArtists,_playlists = playlists,_downloadedTrackIds = downloadedTrackIds;
  

 final  List<DeezerTrack> _likedTracks;
@override@JsonKey() List<DeezerTrack> get likedTracks {
  if (_likedTracks is EqualUnmodifiableListView) return _likedTracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedTracks);
}

 final  List<DeezerAlbum> _likedAlbums;
@override@JsonKey() List<DeezerAlbum> get likedAlbums {
  if (_likedAlbums is EqualUnmodifiableListView) return _likedAlbums;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedAlbums);
}

 final  List<DeezerArtist> _followedArtists;
@override@JsonKey() List<DeezerArtist> get followedArtists {
  if (_followedArtists is EqualUnmodifiableListView) return _followedArtists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_followedArtists);
}

 final  List<DeezerPlaylist> _playlists;
@override@JsonKey() List<DeezerPlaylist> get playlists {
  if (_playlists is EqualUnmodifiableListView) return _playlists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playlists);
}

 final  List<int> _downloadedTrackIds;
@override@JsonKey() List<int> get downloadedTrackIds {
  if (_downloadedTrackIds is EqualUnmodifiableListView) return _downloadedTrackIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_downloadedTrackIds);
}


/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibraryStateCopyWith<_LibraryState> get copyWith => __$LibraryStateCopyWithImpl<_LibraryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LibraryState&&const DeepCollectionEquality().equals(other._likedTracks, _likedTracks)&&const DeepCollectionEquality().equals(other._likedAlbums, _likedAlbums)&&const DeepCollectionEquality().equals(other._followedArtists, _followedArtists)&&const DeepCollectionEquality().equals(other._playlists, _playlists)&&const DeepCollectionEquality().equals(other._downloadedTrackIds, _downloadedTrackIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_likedTracks),const DeepCollectionEquality().hash(_likedAlbums),const DeepCollectionEquality().hash(_followedArtists),const DeepCollectionEquality().hash(_playlists),const DeepCollectionEquality().hash(_downloadedTrackIds));

@override
String toString() {
  return 'LibraryState(likedTracks: $likedTracks, likedAlbums: $likedAlbums, followedArtists: $followedArtists, playlists: $playlists, downloadedTrackIds: $downloadedTrackIds)';
}


}

/// @nodoc
abstract mixin class _$LibraryStateCopyWith<$Res> implements $LibraryStateCopyWith<$Res> {
  factory _$LibraryStateCopyWith(_LibraryState value, $Res Function(_LibraryState) _then) = __$LibraryStateCopyWithImpl;
@override @useResult
$Res call({
 List<DeezerTrack> likedTracks, List<DeezerAlbum> likedAlbums, List<DeezerArtist> followedArtists, List<DeezerPlaylist> playlists, List<int> downloadedTrackIds
});




}
/// @nodoc
class __$LibraryStateCopyWithImpl<$Res>
    implements _$LibraryStateCopyWith<$Res> {
  __$LibraryStateCopyWithImpl(this._self, this._then);

  final _LibraryState _self;
  final $Res Function(_LibraryState) _then;

/// Create a copy of LibraryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? likedTracks = null,Object? likedAlbums = null,Object? followedArtists = null,Object? playlists = null,Object? downloadedTrackIds = null,}) {
  return _then(_LibraryState(
likedTracks: null == likedTracks ? _self._likedTracks : likedTracks // ignore: cast_nullable_to_non_nullable
as List<DeezerTrack>,likedAlbums: null == likedAlbums ? _self._likedAlbums : likedAlbums // ignore: cast_nullable_to_non_nullable
as List<DeezerAlbum>,followedArtists: null == followedArtists ? _self._followedArtists : followedArtists // ignore: cast_nullable_to_non_nullable
as List<DeezerArtist>,playlists: null == playlists ? _self._playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<DeezerPlaylist>,downloadedTrackIds: null == downloadedTrackIds ? _self._downloadedTrackIds : downloadedTrackIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
