import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart' as mk;

import '../api/models/deezer_track.dart';
import '../api/models/player_state.dart';
import '../api/models/queue_state.dart';
import '../utils/app_logger.dart';
import '../storage/hive_boxes.dart';
import 'music_player_service.dart';
import 'similar_tracks_resolver.dart';
import 'youtube_stream_resolver.dart';
import 'android_auto_browse.dart';

class _PlayableSource {
  const _PlayableSource({
    required this.uri,
    this.httpHeaders,
    this.expiresAt,
  });

  final String uri;
  final Map<String, String>? httpHeaders;
  final DateTime? expiresAt;

  mk.Media toMedia() => mk.Media(uri, httpHeaders: httpHeaders);
}

/// Real audio backend powered by `media_kit` (libmpv).
/// Uses a dual-player architecture to support true overlapping crossfades.
class MediaKitMusicPlayerService extends BaseAudioHandler
    with QueueHandler, SeekHandler
    implements MusicPlayerService {
  MediaKitMusicPlayerService({
    YoutubeStreamResolver? resolver,
    SimilarTracksResolver? similarResolver,
  })  : _resolver = resolver ?? YoutubeStreamResolver(),
        _similarResolver = similarResolver ?? SimilarTracksResolver() {
    _initPlayer(_playerA);
    _initPlayer(_playerB);
    unawaited(_configurePlayer(_playerA));
    unawaited(_configurePlayer(_playerB));
    _loadInitialSettings();
    unawaited(_initAudioSession());
  }

  static const mk.PlayerConfiguration _playerConfig = mk.PlayerConfiguration(
    bufferSize: 64 * 1024 * 1024,
  );

  final mk.Player _playerA = mk.Player(configuration: _playerConfig);
  final mk.Player _playerB = mk.Player(configuration: _playerConfig);
  late mk.Player _activePlayer = _playerA;
  late mk.Player _inactivePlayer = _playerB;

  final YoutubeStreamResolver _resolver;
  final SimilarTracksResolver _similarResolver;

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
  int _playbackRecoveryAttempts = 0;
  static const int _maxPlaybackRecoveryAttempts = 2;
  bool _autoplayInFlight = false;
  Timer? _streamRefreshTimer;
  DateTime? _lastRecoveryAt;
  static const Duration _recoveryCooldown = Duration(seconds: 20);
  static const Duration _fallbackStreamRefresh = Duration(minutes: 45);
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _becomingNoisySub;
  bool _pausedByInterruption = false;

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      _interruptionSub = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          if (_state.status == PlaybackStatus.playing) {
            _pausedByInterruption = true;
            unawaited(pause());
          }
          return;
        }

        if (!_pausedByInterruption) return;
        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.duck:
            if (_state.currentTrack != null &&
                _state.status != PlaybackStatus.playing) {
              unawaited(play());
            }
            break;
          case AudioInterruptionType.unknown:
            break;
        }
        _pausedByInterruption = false;
      });

      _becomingNoisySub = session.becomingNoisyEventStream.listen((_) {
        if (_state.status == PlaybackStatus.playing) {
          _pausedByInterruption = false;
          unawaited(pause());
        }
      });
    } catch (e, st) {
      appLogger.w('Failed to bind audio session interruptions', error: e, stackTrace: st);
    }
  }

  Future<void> _activateAudioSession() async {
    try {
      final session = await AudioSession.instance;
      final activated = await session.setActive(true);
      if (!activated) {
        appLogger.w('Audio session activation was denied');
      }
    } catch (e) {
      appLogger.w('Failed to activate audio session: $e');
    }
  }

  Future<void> _configurePlayer(mk.Player player) async {
    try {
      if (player.platform is mk.NativePlayer) {
        final native = player.platform as mk.NativePlayer;
        await native.setProperty('cache', 'yes');
        await native.setProperty('cache-secs', '20');
        await native.setProperty('demuxer-readahead-secs', '20');
      }
    } catch (e) {
      appLogger.w('Failed to configure player streaming cache: $e');
    }
  }

  void _cancelStreamRefresh() {
    _streamRefreshTimer?.cancel();
    _streamRefreshTimer = null;
  }

  DateTime? _parseStreamExpiry(String url) {
    try {
      final exp = Uri.parse(url).queryParameters['expire'];
      final secs = int.tryParse(exp ?? '');
      if (secs == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(secs * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }

  void _scheduleStreamRefresh(DateTime? expiresAt) {
    _cancelStreamRefresh();
    final now = DateTime.now().toUtc();
    DateTime? refreshAt;
    if (expiresAt != null) {
      refreshAt = expiresAt.subtract(const Duration(minutes: 3));
    } else {
      refreshAt = now.add(_fallbackStreamRefresh);
    }
    var delay = refreshAt.difference(now);
    if (delay.isNegative) {
      delay = const Duration(seconds: 5);
    }
    _streamRefreshTimer = Timer(delay, () {
      unawaited(_refreshStreamInPlace());
    });
  }

  Future<void> _openSourceOnPlayer(
    mk.Player player,
    _PlayableSource source, {
    bool play = true,
    Duration? seekTo,
  }) async {
    if (play) {
      await _activateAudioSession();
    }
    await player.open(source.toMedia(), play: play);
    await _applyEqualizerToPlayer(player);
    if (seekTo != null && seekTo > Duration.zero) {
      await player.seek(seekTo);
    }
    _scheduleStreamRefresh(source.expiresAt);
  }

  Future<void> _refreshStreamInPlace() async {
    if (_loading || _isCrossfading || _autoplayInFlight) return;
    final track = _state.currentTrack;
    if (track == null) return;
    if (_getDownloadedAudioPath(track.id) != null) return;

    final resumeAt = _state.position;
    final wasPlaying = _activePlayer.state.playing;
    appLogger.i('Refreshing stream URL in place at $resumeAt');

    try {
      final source = await _resolvePlayableSource(track, forceRefresh: true);
      if (source == null) return;
      await _openSourceOnPlayer(
        _activePlayer,
        source,
        play: wasPlaying,
        seekTo: resumeAt,
      );
      _playbackRecoveryAttempts = 0;
      if (wasPlaying) {
        _emitPlayer(_state.copyWith(status: PlaybackStatus.playing));
      }
    } catch (e, st) {
      appLogger.w('In-place stream refresh failed', error: e, stackTrace: st);
    }
  }

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
          final autoplay = json['autoplaySimilar'] as bool? ?? true;
          _state = _state.copyWith(autoplaySimilar: autoplay);
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
        final autoplay = raw['autoplaySimilar'] as bool? ?? true;
        _state = _state.copyWith(autoplaySimilar: autoplay);
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
      mediaItem.add(trackToMediaItem(t).copyWith(
        duration: _state.duration > Duration.zero
            ? _state.duration
            : (t.duration != null ? Duration(seconds: t.duration!) : null),
      ));
    }
  }

  void _emitQueue(QueueState next) {
    _queue = next;
    _queueCtrl.add(next);
    _syncQueueToAudioService();
  }

  void _syncQueueToAudioService() {
    final upcoming = _queue.upcoming.map(trackToMediaItem).toList(growable: false);
    queue.add(upcoming);
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
    if (!completed || _isCrossfading || _autoCrossfadeTriggered) return;

    if (_state.repeat == RepeatMode.one) {
      unawaited(_activePlayer.seek(Duration.zero));
      unawaited(_activePlayer.play());
      return;
    }

    unawaited(skipNext());
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
    if (_isCrossfading) return;
    appLogger.e('media_kit error: $e');

    final now = DateTime.now();
    if (_lastRecoveryAt != null &&
        now.difference(_lastRecoveryAt!) < _recoveryCooldown) {
      return;
    }

    if (_state.currentTrack != null &&
        _playbackRecoveryAttempts < _maxPlaybackRecoveryAttempts &&
        _isRecoverablePlaybackError(e)) {
      _playbackRecoveryAttempts++;
      _lastRecoveryAt = now;
      unawaited(_recoverCurrentTrack());
      return;
    }

    _playbackRecoveryAttempts = 0;
    _emitPlayer(_state.copyWith(
      status: PlaybackStatus.error,
      errorMessage: e,
    ));
  }

  bool _isRecoverablePlaybackError(String error) {
    final lower = error.toLowerCase();
    return lower.contains('403') ||
        lower.contains('404') ||
        lower.contains('410') ||
        lower.contains('connection reset') ||
        lower.contains('connection closed') ||
        lower.contains('timed out') ||
        lower.contains('timeout') ||
        lower.contains('network is unreachable') ||
        lower.contains('end of file') ||
        lower.contains('eof');
  }

  Future<_PlayableSource?> _resolvePlayableSource(
    DeezerTrack track, {
    bool forceRefresh = false,
  }) async {
    final localPath = _getDownloadedAudioPath(track.id);
    if (localPath != null) {
      return _PlayableSource(uri: 'file://$localPath');
    }

    final res = await _resolver.resolveUrl(track, forceRefresh: forceRefresh);
    if (res == null) return null;

    final url = res.url;
    final headers = url.contains('googlevideo.com')
        ? _buildStreamHeaders(userAgent: res.userAgent)
        : null;

    return _PlayableSource(
      uri: url,
      httpHeaders: headers,
      expiresAt: _parseStreamExpiry(url),
    );
  }

  Future<void> _recoverCurrentTrack() async {
    final track = _state.currentTrack;
    if (track == null) return;

    final resumeAt = _state.position;
    _loading = true;
    _emitPlayer(
      _state.copyWith(
        status: PlaybackStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final source = await _resolvePlayableSource(track, forceRefresh: true);
      if (source == null) throw Exception('No audio source found');

      await _openSourceOnPlayer(
        _activePlayer,
        source,
        play: true,
        seekTo: resumeAt,
      );
      _loading = false;
      _playbackRecoveryAttempts = 0;
      _emitPlayer(_state.copyWith(status: PlaybackStatus.playing));
    } catch (e, st) {
      _loading = false;
      appLogger.e('Playback recovery failed', error: e, stackTrace: st);
      if (_playbackRecoveryAttempts >= _maxPlaybackRecoveryAttempts) {
        _playbackRecoveryAttempts = 0;
        _emitPlayer(
          _state.copyWith(
            status: PlaybackStatus.error,
            errorMessage: 'Playback stopped. Try skipping to the next track.',
          ),
        );
      }
    }
  }

  List<DeezerTrack> _fullPlaylistLoop() {
    return <DeezerTrack>[
      ..._queue.history,
      if (_queue.current != null) _queue.current!,
      ..._queue.upcoming,
    ];
  }

  DeezerTrack? _repeatAllNextTrack() {
    final loop = _fullPlaylistLoop();
    if (loop.isEmpty) return null;
    final current = _queue.current;
    if (current == null) return loop.first;
    final idx = loop.indexOf(current);
    if (idx == -1) return loop.first;
    return loop[(idx + 1) % loop.length];
  }

  Future<void> _playRepeatAllNext() async {
    final loop = _fullPlaylistLoop();
    final next = _repeatAllNextTrack();
    if (next == null || loop.isEmpty) {
      await stop();
      return;
    }

    final nextIndex = loop.indexOf(next);
    final newHistory = nextIndex > 0 ? loop.sublist(0, nextIndex) : const <DeezerTrack>[];
    var newUpcoming = nextIndex < loop.length - 1
        ? loop.sublist(nextIndex + 1)
        : const <DeezerTrack>[];
    if (_state.shuffle && newUpcoming.isNotEmpty) {
      newUpcoming = List<DeezerTrack>.from(newUpcoming)..shuffle(Random());
    }

    _emitQueue(_queue.copyWith(
      history: newHistory,
      current: next,
      upcoming: newUpcoming,
    ));
    await _startPlayback(next, autoCrossfade: false);
  }

  Set<int> _queuedTrackIds() {
    return <int>{
      ..._queue.history.map((t) => t.id),
      if (_queue.current != null) _queue.current!.id,
      ..._queue.upcoming.map((t) => t.id),
    };
  }

  Future<bool> _tryAutoplaySimilar() async {
    if (!_state.autoplaySimilar || _state.repeat != RepeatMode.off) return false;
    if (_autoplayInFlight) return false;

    final seed = _queue.current;
    if (seed == null) return false;

    _autoplayInFlight = true;
    _emitPlayer(_state.copyWith(status: PlaybackStatus.loading, errorMessage: null));

    try {
      final similar = await _similarResolver.resolve(
        seed,
        excludeIds: _queuedTrackIds(),
      );
      if (similar.isEmpty) return false;

      final next = similar.first;
      final rest = similar.sublist(1);
      _emitQueue(_queue.copyWith(
        history: <DeezerTrack>[..._queue.history, seed],
        current: next,
        upcoming: rest,
      ));
      await _startPlayback(next, autoCrossfade: false);
      return true;
    } catch (e, st) {
      appLogger.e('Autoplay similar failed', error: e, stackTrace: st);
      return false;
    } finally {
      _autoplayInFlight = false;
    }
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
      final source = await _resolvePlayableSource(track);
      if (source == null) throw Exception('No audio source found');

      await _openSourceOnPlayer(fadingInPlayer, source, play: true);
      
      _loading = false;
      _playbackRecoveryAttempts = 0;
      _emitPlayer(_state.copyWith(status: PlaybackStatus.playing));
      _preloadNext();
    } catch (e, st) {
      _loading = false;
      _isCrossfading = false;
      
      // Revert the active player swap so the currently playing song isn't interrupted
      _activePlayer = fadingOutPlayer;
      _inactivePlayer = fadingInPlayer;

      appLogger.e('media_kit load failed', error: e, stackTrace: st);

      try {
        final source = await _resolvePlayableSource(track, forceRefresh: true);
        if (source != null) {
          _activePlayer = fadingInPlayer;
          _inactivePlayer = fadingOutPlayer;
          await _openSourceOnPlayer(fadingInPlayer, source, play: true);
          await fadingOutPlayer.stop();
          _playbackRecoveryAttempts = 0;
          _emitPlayer(_state.copyWith(status: PlaybackStatus.playing));
          _preloadNext();
          return;
        }
      } catch (retryError, retrySt) {
        appLogger.e('Crossfade retry failed', error: retryError, stackTrace: retrySt);
      }

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
      final source = await _resolvePlayableSource(track);
      if (source == null) {
        _loading = false;
        _emitPlayer(
          _state.copyWith(
            status: PlaybackStatus.error,
            errorMessage: 'No audio source found',
          ),
        );
        return;
      }

      await _openSourceOnPlayer(player, source, play: true);
      _loading = false;
      _playbackRecoveryAttempts = 0;
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
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queue.upcoming.length) return;
    final selected = _queue.upcoming[index];
    final newUpcoming = <DeezerTrack>[
      ..._queue.upcoming.sublist(index + 1),
    ];
    final newHistory = <DeezerTrack>[
      ..._queue.history,
      if (_queue.current != null) _queue.current!,
      ..._queue.upcoming.sublist(0, index),
    ];
    _emitQueue(_queue.copyWith(
      history: newHistory,
      current: selected,
      upcoming: newUpcoming,
    ));
    await _startPlayback(selected, autoCrossfade: false);
  }

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    return androidAutoChildrenFor(parentMediaId);
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    final tracks = tracksForMediaId(mediaId);
    if (tracks.isEmpty) return;
    await playTracks(tracks);
  }

  @override
  Future<void> play() async {
    _pausedByInterruption = false;
    await _activateAudioSession();
    await _activePlayer.play();
  }

  @override
  Future<void> pause() async {
    await _activePlayer.pause();
  }

  @override
  Future<void> togglePlayPause() async {
    if (_activePlayer.state.playing) {
      _pausedByInterruption = false;
      await pause();
    } else {
      await play();
    }
  }

  @override
  Future<void> stop() async {
    _crossfadeTimer?.cancel();
    _cancelStreamRefresh();
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
  Future<void> skipNext() async {
    if (_queue.upcoming.isEmpty) {
      if (_state.repeat == RepeatMode.all) {
        final loop = _fullPlaylistLoop();
        if (loop.length == 1) {
          await _startPlayback(loop.first, autoCrossfade: false);
          return;
        }
        if (loop.length > 1) {
          await _playRepeatAllNext();
          return;
        }
      }
      if (await _tryAutoplaySimilar()) return;
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

  @override
  Future<void> setAutoplaySimilar(bool value) async {
    _emitPlayer(_state.copyWith(autoplaySimilar: value));
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
    _cancelStreamRefresh();
    await _interruptionSub?.cancel();
    await _becomingNoisySub?.cancel();
    await _playerA.dispose();
    await _playerB.dispose();
    _resolver.dispose();
    await _playerCtrl.close();
    await _queueCtrl.close();
  }
}
