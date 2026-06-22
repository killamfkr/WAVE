import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart' as mk;

import '../api/models/deezer_track.dart';
import '../api/models/player_state.dart';
import '../api/models/queue_state.dart';
import '../utils/app_logger.dart';
import '../storage/hive_boxes.dart';
import 'music_player_service.dart';
import 'youtube_stream_resolver.dart';

/// Real audio backend powered by `media_kit` (libmpv).
/// Uses a dual-player architecture to support true overlapping crossfades.
class MediaKitMusicPlayerService extends BaseAudioHandler
    with SeekHandler
    implements MusicPlayerService {
  MediaKitMusicPlayerService({YoutubeStreamResolver? resolver})
      : _resolver = resolver ?? YoutubeStreamResolver() {
    _initPlayer(_playerA);
    _initPlayer(_playerB);
    _loadInitialSettings();
  }

  final mk.Player _playerA = mk.Player();
  final mk.Player _playerB = mk.Player();
  late mk.Player _activePlayer = _playerA;
  late mk.Player _inactivePlayer = _playerB;

  final YoutubeStreamResolver _resolver;

  final StreamController<PlayerState> _playerCtrl =
      StreamController<PlayerState>.broadcast();
  final StreamController<QueueState> _queueCtrl =
      StreamController<QueueState>.broadcast();

  PlayerState _state = const PlayerState();
  QueueState _queue = const QueueState();
  bool _loading = false;

  Timer? _crossfadeTimer;
  Object? _crossfadeTag;
  bool _isCrossfading = false;
  bool _autoCrossfadeTriggered = false;
  List<double> _equalizerBandsDb = const <double>[0, 0, 0, 0, 0];

  void _initPlayer(mk.Player player) {
    player.stream.playing.listen((v) => _onPlayingChanged(player, v));
    player.stream.buffering.listen((v) => _onBufferingChanged(player, v));
    player.stream.completed.listen((v) => _onCompleted(player, v));
    player.stream.position.listen((v) => _onPositionChanged(player, v));
    player.stream.duration.listen((v) => _onDurationChanged(player, v));
    player.stream.buffer.listen((v) => _onBufferChanged(player, v));
    player.stream.error.listen((v) => _onError(player, v));
  }

  void _loadInitialSettings() {
    try {
      final box = Hive.box<dynamic>(HiveBoxes.settings);
      final raw = box.get('app_settings');
      if (raw is String && raw.isNotEmpty) {
        final json = jsonDecode(raw);
        if (json is Map) {
          final secs = (json['crossfadeSeconds'] as num?)?.toInt() ?? 0;
          _state = _state.copyWith(crossfadeSeconds: secs);
          final bandsRaw = json['equalizerBandsDb'];
          if (bandsRaw is List) {
            final List<double> bands = bandsRaw.whereType<num>().map((n) => n.toDouble()).toList();
            if (bands.length == 5) {
              _equalizerBandsDb = bands;
            }
          }
        }
      } else if (raw is Map) {
        final secs = (raw['crossfadeSeconds'] as num?)?.toInt() ?? 0;
        _state = _state.copyWith(crossfadeSeconds: secs);
        final bandsRaw = raw['equalizerBandsDb'];
        if (bandsRaw is List) {
          final List<double> bands = bandsRaw.whereType<num>().map((n) => n.toDouble()).toList();
          if (bands.length == 5) {
            _equalizerBandsDb = bands;
          }
        }
      }
      // Apply loaded equalizer settings
      _applyEqualizerToPlayer(_playerA);
      _applyEqualizerToPlayer(_playerB);
    } catch (e) {
      appLogger.w('Failed to load initial settings: $e');
    }
  }

  Map<String, String> _buildStreamHeaders({String? userAgent}) {
    final headers = <String, String>{
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Origin': 'https://www.youtube.com',
      'Referer': 'https://www.youtube.com/',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'cross-site',
    };

    // If we got a specific User-Agent from the extractor, WE MUST USE IT.
    // Otherwise YouTube CDN returns 403 Forbidden for some streams.
    if (userAgent != null && userAgent.isNotEmpty) {
      headers['User-Agent'] = userAgent;
    } else {
      headers['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36';
    }
    return headers;
  }

  Future<void> _applyEqualizerToPlayer(mk.Player player) async {
    final isFlat = _equalizerBandsDb.every((db) => db == 0.0);
    final filter = isFlat
        ? ''
        : 'lavfi=[equalizer=f=60:t=q:w=1:g=${_equalizerBandsDb[0]},'
            'equalizer=f=230:t=q:w=1:g=${_equalizerBandsDb[1]},'
            'equalizer=f=910:t=q:w=1:g=${_equalizerBandsDb[2]},'
            'equalizer=f=4000:t=q:w=1:g=${_equalizerBandsDb[3]},'
            'equalizer=f=14000:t=q:w=1:g=${_equalizerBandsDb[4]}]';
    try {
      if (player.platform is mk.NativePlayer) {
        await (player.platform as mk.NativePlayer).setProperty('af', filter);
      }
    } catch (e) {
      appLogger.e('Failed to apply equalizer filter to player: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Streams ------------------------------------------------------------------

  @override
  Stream<PlayerState> get playerStateStream => _playerCtrl.stream;

  @override
  Stream<QueueState> get queueStateStream => _queueCtrl.stream;

  @override
  PlayerState get playerState => _state;

  @override
  QueueState get queueState => _queue;

  void _emitPlayer(PlayerState next) {
    _state = next;
    _playerCtrl.add(next);
    _syncAudioService();
  }

  void _syncAudioService() {
    final isPlaying = _state.status == PlaybackStatus.playing;
    final isBuffering = _state.status == PlaybackStatus.buffering ||
        _state.status == PlaybackStatus.loading;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: isBuffering
          ? AudioProcessingState.buffering
          : (_state.status == PlaybackStatus.idle
              ? AudioProcessingState.idle
              : AudioProcessingState.ready),
      playing: isPlaying,
      updatePosition: _state.position,
      bufferedPosition: _state.buffered,
      speed: 1.0,
    ));

    if (_state.currentTrack != null) {
      final t = _state.currentTrack!;
      final oldMediaItem = mediaItem.value;
      if (oldMediaItem?.id != t.id.toString()) {
        mediaItem.add(MediaItem(
          id: t.id.toString(),
          title: t.title,
          artist: t.artist?.name,
          album: t.album?.title,
          duration: t.duration != null
              ? Duration(seconds: t.duration!)
              : _state.duration,
          artUri: t.album?.coverMedium != null
              ? Uri.parse(t.album!.coverMedium!)
              : null,
        ));
      }
    }
  }

  void _emitQueue(QueueState next) {
    _queue = next;
    _queueCtrl.add(next);
  }

  // ---------------------------------------------------------------------------
  // media_kit -> PlayerState bridges -----------------------------------------

  void _onPlayingChanged(mk.Player p, bool playing) {
    if (p != _activePlayer || _loading) return;
    _emitPlayer(_state.copyWith(
      status: playing ? PlaybackStatus.playing : PlaybackStatus.paused,
    ));
  }

  void _onBufferingChanged(mk.Player p, bool buffering) {
    if (p != _activePlayer || _loading) return;
    if (buffering) {
      _emitPlayer(_state.copyWith(status: PlaybackStatus.buffering));
    } else if (p.state.playing) {
      _emitPlayer(_state.copyWith(status: PlaybackStatus.playing));
    }
  }

  void _onCompleted(mk.Player p, bool completed) {
    if (p != _activePlayer) return;
    if (completed && !_isCrossfading && !_autoCrossfadeTriggered) {
      unawaited(skipNext());
    }
  }

  void _onPositionChanged(mk.Player p, Duration pos) {
    if (p != _activePlayer) return;
    if (pos == _state.position) return;
    _emitPlayer(_state.copyWith(position: pos));

    // Check for automatic crossfade
    if (!_isCrossfading && !_autoCrossfadeTriggered && _state.duration > Duration.zero && _state.crossfadeSeconds > 0) {
      final remaining = _state.duration - pos;
      if (remaining <= Duration(seconds: _state.crossfadeSeconds)) {
        if (_queue.upcoming.isNotEmpty) {
          _autoCrossfadeTriggered = true;
          _triggerAutoCrossfade();
        }
      }
    }
  }

  void _triggerAutoCrossfade() async {
    if (_queue.upcoming.isEmpty) return;
    final next = _queue.upcoming.first;
    final newUpcoming = _queue.upcoming.sublist(1);
    final newHistory = <DeezerTrack>[
      ..._queue.history,
      if (_queue.current != null) _queue.current!,
    ];
    _emitQueue(_queue.copyWith(
      history: newHistory,
      current: next,
      upcoming: newUpcoming,
    ));
    await _startPlayback(next, autoCrossfade: true);
  }

  void _onDurationChanged(mk.Player p, Duration d) {
    if (p != _activePlayer) return;
    if (d == Duration.zero) return;
    _emitPlayer(_state.copyWith(duration: d));
  }

  void _onBufferChanged(mk.Player p, Duration b) {
    if (p != _activePlayer) return;
    _emitPlayer(_state.copyWith(buffered: b));
  }

  void _onError(mk.Player p, String e) {
    if (p != _activePlayer) return;
    if (_loading || _isCrossfading) return;
    appLogger.e('media_kit error: $e');
    _emitPlayer(_state.copyWith(
      status: PlaybackStatus.error,
      errorMessage: e,
    ));
  }

  // ---------------------------------------------------------------------------
  // Source loading & Crossfade -----------------------------------------------

  /// Force-stop everything and play directly with no crossfade at all.
  Future<void> _directPlay(DeezerTrack track) async {
    _crossfadeTimer?.cancel();
    _isCrossfading = false;
    _autoCrossfadeTriggered = false;
    await _activePlayer.stop();
    await _inactivePlayer.stop();
    await _loadAndPlay(track, _activePlayer);
  }

  /// Start playback with optional crossfade.
  /// Only called from auto-crossfade and skip next/prev (manual short fade).
  Future<void> _startPlayback(DeezerTrack track, {required bool autoCrossfade}) async {
    _autoCrossfadeTriggered = false;

    final int fadeSecs = _state.crossfadeSeconds;
    final crossfadeDuration = autoCrossfade
      ? Duration(seconds: fadeSecs)
      : const Duration(milliseconds: 500);

    final bool canCrossfade = _activePlayer.state.playing && crossfadeDuration > Duration.zero;

    if (!canCrossfade) {
        _crossfadeTimer?.cancel();
        _isCrossfading = false;
        await _activePlayer.stop();
        await _inactivePlayer.stop();
        
        await _loadAndPlay(track, _activePlayer);
        return;
    }

    // Cancel any in-progress crossfade cleanly
    _crossfadeTimer?.cancel();
    if (_isCrossfading) {
      // Stop the player that was fading out from the previous crossfade
      await _inactivePlayer.stop();
    }
    _isCrossfading = true;

    final fadingOutPlayer = _activePlayer;
    final fadingInPlayer = _inactivePlayer;

    // Switch active player NOW so UI updates to new track
    _activePlayer = fadingInPlayer;
    _inactivePlayer = fadingOutPlayer;

    // Start new track at volume 0
    await fadingInPlayer.setVolume(0.0);
    
    // Begin loading
    _loading = true;
    _emitPlayer(
      _state.copyWith(
        currentTrack: track,
        status: PlaybackStatus.loading,
        position: Duration.zero,
        duration: Duration.zero,
        buffered: Duration.zero,
        errorMessage: null,
        transitionDuration: crossfadeDuration,
      ),
    );

    try {
      String? url;
      String? userAgent;
      
      final localPath = _getDownloadedAudioPath(track.id);
      if (localPath == null) {
        final res = await _resolver.resolveUrl(track);
        url = res?.url;
        userAgent = res?.userAgent;
      } else {
        url = 'file://$localPath'; // Wrap local path in file:// URI
      }
      if (url == null) throw Exception('No audio source found');
      
      final headers = _buildStreamHeaders(userAgent: userAgent);

      await fadingInPlayer.open(mk.Media(
        url,
        httpHeaders: headers,
      ), play: true);
      await _applyEqualizerToPlayer(fadingInPlayer);
      
      _loading = false;
      _emitPlayer(_state.copyWith(status: PlaybackStatus.playing));
      _preloadNext();
    } catch (e, st) {
      _loading = false;
      _isCrossfading = false;
      
      // Revert the active player swap so the currently playing song isn't interrupted
      _activePlayer = fadingOutPlayer;
      _inactivePlayer = fadingInPlayer;

      appLogger.e('media_kit load failed', error: e, stackTrace: st);
      
      // Attempt to auto-skip to the next song instead of just failing silently and stopping the queue
      unawaited(skipNext());
      return;
    }

    // Now start volume fade
    // Capture a reference so we can detect if a new crossfade replaced us
    final thisTimer = Object();
    _crossfadeTag = thisTimer;

    final steps = 20;
    final stepDuration = crossfadeDuration ~/ steps;
    final targetVolume = _state.volume * 100;

    int currentStep = 0;
    _crossfadeTimer = Timer.periodic(stepDuration, (timer) async {
      // If a newer crossfade or direct play has started, bail out
      if (_crossfadeTag != thisTimer) {
        timer.cancel();
        return;
      }

      currentStep++;
      final progress = currentStep / steps;

      try {
        await fadingOutPlayer.setVolume(targetVolume * (1 - progress));
        await fadingInPlayer.setVolume(targetVolume * progress);
      } catch (_) {
        // Player may have been stopped/disposed
        timer.cancel();
        _isCrossfading = false;
        return;
      }

      if (currentStep >= steps) {
        timer.cancel();
        try { await fadingOutPlayer.stop(); } catch (_) {}
        _isCrossfading = false;
      }
    });
  }

  Future<void> _loadAndPlay(DeezerTrack track, mk.Player player) async {
    await player.pause();
    await player.setVolume(_state.volume * 100);

    _loading = true;
    _emitPlayer(
      _state.copyWith(
        currentTrack: track,
        status: PlaybackStatus.loading,
        position: Duration.zero,
        duration: Duration.zero,
        buffered: Duration.zero,
        errorMessage: null,
        transitionDuration: Duration.zero,
      ),
    );
    try {
      String? url;
      String? userAgent;
      
      final localPath = _getDownloadedAudioPath(track.id);
      if (localPath == null) {
        final res = await _resolver.resolveUrl(track);
        url = res?.url;
        userAgent = res?.userAgent;
      } else {
        url = 'file://$localPath';
      }
      if (url == null) {
        _loading = false;
        _emitPlayer(
          _state.copyWith(
            status: PlaybackStatus.error,
            errorMessage: 'No audio source found',
          ),
        );
        return;
      }
      final headers = _buildStreamHeaders(userAgent: userAgent);

      await player.open(mk.Media(
        url,
        httpHeaders: headers,
      ));
      await _applyEqualizerToPlayer(player);
      _loading = false;
      _emitPlayer(_state.copyWith(status: PlaybackStatus.playing));
      _preloadNext();
    } catch (e, st) {
      _loading = false;
      appLogger.e('media_kit load failed', error: e, stackTrace: st);
      _emitPlayer(
        _state.copyWith(
          status: PlaybackStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _preloadNext() async {
    if (_queue.upcoming.isNotEmpty) {
      // Background resolution will cache the result instantly
      await _resolver.resolveUrl(_queue.upcoming.first);
    }
  }

  // ---------------------------------------------------------------------------
  // AudioService / Playback control ------------------------------------------

  @override
  Future<void> play() => _activePlayer.play();

  @override
  Future<void> pause() => _activePlayer.pause();

  @override
  Future<void> stop() async {
    _crossfadeTimer?.cancel();
    _isCrossfading = false;
    await _activePlayer.stop();
    await _inactivePlayer.stop();
    _emitPlayer(_state.copyWith(
      status: PlaybackStatus.idle,
      position: Duration.zero,
    ));
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _activePlayer.seek(position);

  @override
  Future<void> skipToNext() async => skipNext();

  @override
  Future<void> skipToPrevious() async => skipPrevious();

  @override
  Future<void> togglePlayPause() => _activePlayer.playOrPause();

  @override
  Future<void> skipNext() async {
    if (_queue.upcoming.isEmpty) {
      await stop();
      return;
    }
    final next = _queue.upcoming.first;
    final newUpcoming = _queue.upcoming.sublist(1);
    final newHistory = <DeezerTrack>[
      ..._queue.history,
      if (_queue.current != null) _queue.current!,
    ];
    _emitQueue(_queue.copyWith(
      history: newHistory,
      current: next,
      upcoming: newUpcoming,
    ));
    await _startPlayback(next, autoCrossfade: false);
  }

  @override
  Future<void> skipPrevious() async {
    if (_activePlayer.state.position > const Duration(seconds: 3) ||
        _queue.history.isEmpty) {
      await seek(Duration.zero);
      return;
    }
    final prev = _queue.history.last;
    final newHistory = _queue.history.sublist(0, _queue.history.length - 1);
    final newUpcoming = <DeezerTrack>[
      if (_queue.current != null) _queue.current!,
      ..._queue.upcoming,
    ];
    _emitQueue(_queue.copyWith(
      history: newHistory,
      current: prev,
      upcoming: newUpcoming,
    ));
    await _startPlayback(prev, autoCrossfade: false);
  }

  @override
  Future<void> setShuffle(bool value) async {
    _emitPlayer(_state.copyWith(shuffle: value));
    if (value && _queue.upcoming.isNotEmpty) {
      final list = List<DeezerTrack>.from(_queue.upcoming)..shuffle(Random());
      _emitQueue(_queue.copyWith(shuffled: value, upcoming: list));
    } else {
      _emitQueue(_queue.copyWith(shuffled: value));
    }
  }

  @override
  Future<void> setRepeat(RepeatMode mode) async {
    _emitPlayer(_state.copyWith(repeat: mode));
    final mkMode = switch (mode) {
      RepeatMode.off => mk.PlaylistMode.none,
      RepeatMode.all => mk.PlaylistMode.loop,
      RepeatMode.one => mk.PlaylistMode.single,
    };
    await _playerA.setPlaylistMode(mkMode);
    await _playerB.setPlaylistMode(mkMode);
  }

  @override
  Future<void> setVolume(double volume) async {
    final v = volume.clamp(0.0, 1.0);
    _emitPlayer(_state.copyWith(volume: v));
    if (!_isCrossfading) {
      await _activePlayer.setVolume(v * 100);
    }
  }

  @override
  Future<void> setCrossfadeSeconds(int seconds) async {
    _emitPlayer(_state.copyWith(crossfadeSeconds: seconds.clamp(0, 12)));
  }

  // ---------------------------------------------------------------------------
  // Queue management ---------------------------------------------------------

  @override
  Future<void> playTracks(
    List<DeezerTrack> tracks, {
    int? startIndex,
  }) async {
    if (tracks.isEmpty) return;
    
    int i;
    if (startIndex != null) {
      i = startIndex.clamp(0, tracks.length - 1);
    } else {
      if (_state.shuffle) {
        i = Random().nextInt(tracks.length);
      } else {
        i = 0;
      }
    }
    
    final current = tracks[i];

    var upcoming = List<DeezerTrack>.from(tracks);
    upcoming.removeAt(i); 
    
    if (_state.shuffle && upcoming.isNotEmpty) {
      upcoming.shuffle(Random());
    } else if (!_state.shuffle) {
      upcoming = List<DeezerTrack>.from(tracks.sublist(i + 1));
    }

    _emitQueue(QueueState(
      history: const <DeezerTrack>[],
      current: current,
      upcoming: upcoming,
      shuffled: _state.shuffle,
    ));
    await _directPlay(current);
  }

  @override
  Future<void> addToQueueNext(DeezerTrack track) async {
    _emitQueue(
        _queue.copyWith(upcoming: <DeezerTrack>[track, ..._queue.upcoming]));
  }

  @override
  Future<void> addToQueueLast(DeezerTrack track) async {
    _emitQueue(
        _queue.copyWith(upcoming: <DeezerTrack>[..._queue.upcoming, track]));
  }

  @override
  Future<void> removeFromQueue(int indexInUpcoming) async {
    if (indexInUpcoming < 0 || indexInUpcoming >= _queue.upcoming.length) {
      return;
    }
    final next = <DeezerTrack>[..._queue.upcoming]..removeAt(indexInUpcoming);
    _emitQueue(_queue.copyWith(upcoming: next));
  }

  @override
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final list = <DeezerTrack>[..._queue.upcoming];
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final item = list.removeAt(oldIndex);
    final target = newIndex.clamp(0, list.length);
    list.insert(target, item);
    _emitQueue(_queue.copyWith(upcoming: list));
  }

  @override
  Future<void> clearQueue() async {
    _emitQueue(_queue.copyWith(
      upcoming: const <DeezerTrack>[],
      history: const <DeezerTrack>[],
    ));
  }

  // ---------------------------------------------------------------------------
  // Misc ---------------------------------------------------------------------

  @override
  bool isDownloaded(int trackId) {
    if (!Hive.isBoxOpen(HiveBoxes.downloads)) return false;
    return Hive.box<dynamic>(HiveBoxes.downloads).containsKey(trackId);
  }

  String? _getDownloadedAudioPath(int trackId) {
    if (!Hive.isBoxOpen(HiveBoxes.downloads)) return null;
    final data = Hive.box<dynamic>(HiveBoxes.downloads).get(trackId);
    if (data is Map) {
      return data['localAudioPath'] as String?;
    }
    return null;
  }

  @override
  Future<void> setEqualizer(List<double> bandsDb) async {
    _equalizerBandsDb = bandsDb;
    await _applyEqualizerToPlayer(_playerA);
    await _applyEqualizerToPlayer(_playerB);
  }

  @override
  Future<void> dispose() async {
    _crossfadeTimer?.cancel();
    await _playerA.dispose();
    await _playerB.dispose();
    _resolver.dispose();
    await _playerCtrl.close();
    await _queueCtrl.close();
  }
}
