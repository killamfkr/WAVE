import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api/models/deezer_track.dart';
import '../core/utils/app_logger.dart';

/// Fallback audio resolver using public Invidious and Piped instances.
///
/// These services proxy YouTube and often work for users whose direct
/// InnerTube access is blocked by IP reputation, geo restrictions, or bot
/// challenges. Instances are tried in order with short timeouts; the first
/// successful audio URL wins.
class InvidiousPipedResolver {
  InvidiousPipedResolver({
    http.Client? httpClient,
    Duration? requestTimeout,
    List<String>? invidiousInstances,
    List<String>? pipedInstances,
  })  : _client = httpClient ?? http.Client(),
        _timeout = requestTimeout ?? const Duration(seconds: 8),
        _invidiousInstances = invidiousInstances ?? _defaultInvidiousInstances,
        _pipedInstances = pipedInstances ?? _defaultPipedInstances;

  final http.Client _client;
  final Duration _timeout;
  final List<String> _invidiousInstances;
  final List<String> _pipedInstances;

  static const String _tag = 'InvidiousPipedResolver';

  // ---------------------------------------------------------------------------
  // Public instances lists.
  // These are rotated periodically by the community; feel free to update them.
  // ---------------------------------------------------------------------------
  static final List<String> _defaultInvidiousInstances = [
    'https://iv.datura.network',
    'https://iv.nboeck.de',
    'https://iv.melmac.space',
    'https://iv.nboeck.de',
    'https://yt.artemislena.eu',
    'https://iv.datura.network',
  ];

  static final List<String> _defaultPipedInstances = [
    'https://api.piped.projectsegfault.com',
    'https://pipedapi.moomoo.me',
    'https://pipedapi.adminforge.de',
    'https://api.piped.privacydev.net',
    'https://pipedapi.qdi.fi',
  ];

  /// Returns a directly-playable audio URL for [track], or `null` if no
  /// instance could resolve it.
  Future<({String url, String? userAgent})?> resolve(
    DeezerTrack track, {
    String suffix = 'lyrics',
  }) async {
    final query = '${track.title} ${track.artist?.name ?? ''} $suffix'.trim();

    // Try Invidious first (usually fastest and most stable).
    for (final base in _invidiousInstances) {
      try {
        final result = await _resolveInvidious(base, query);
        if (result != null) {
          appLogger.i('Resolved via Invidious ($base) for ${track.title}');
          return result;
        }
      } catch (e) {
        if (kDebugMode) _log('Invidious $base failed: $e');
      }
    }

    // Fall back to Piped.
    for (final base in _pipedInstances) {
      try {
        final result = await _resolvePiped(base, query);
        if (result != null) {
          appLogger.i('Resolved via Piped ($base) for ${track.title}');
          return result;
        }
      } catch (e) {
        if (kDebugMode) _log('Piped $base failed: $e');
      }
    }

    return null;
  }

  Future<({String url, String? userAgent})?> _resolveInvidious(
    String base,
    String query,
  ) async {
    // 1. Search.
    final searchUri = Uri.parse(
      '$base/api/v1/search?q=${Uri.encodeQueryComponent(query)}&type=video',
    );
    final searchResp = await _client
        .get(searchUri, headers: _jsonHeaders)
        .timeout(_timeout);

    if (searchResp.statusCode != 200) {
      throw StateError('search HTTP ${searchResp.statusCode}');
    }

    final results = jsonDecode(searchResp.body);
    if (results is! List || results.isEmpty) return null;

    String? videoId;
    for (final item in results.take(5)) {
      if (item is! Map) continue;
      if ((item['type']?.toString() ?? 'video') != 'video') continue;
      final id = item['videoId']?.toString();
      if (id == null || id.length != 11) continue;

      final lengthSeconds = int.tryParse(item['lengthSeconds']?.toString() ?? '');
      if (lengthSeconds != null && lengthSeconds < 30) continue;

      videoId = id;
      break;
    }
    if (videoId == null) return null;

    // 2. Get stream info.
    final videoUri = Uri.parse('$base/api/v1/videos/$videoId');
    final videoResp = await _client
        .get(videoUri, headers: _jsonHeaders)
        .timeout(_timeout);

    if (videoResp.statusCode != 200) {
      throw StateError('video HTTP ${videoResp.statusCode}');
    }

    final data = jsonDecode(videoResp.body);
    if (data is! Map) return null;

    // Prefer adaptive audio-only formats.
    final adaptive = _asList(data['adaptiveFormats']);
    String? bestUrl;
    int bestBitrate = 0;
    for (final f in adaptive) {
      if (f is! Map) continue;
      final type = f['type']?.toString() ?? '';
      if (!type.startsWith('audio/')) continue;
      final url = f['url']?.toString();
      if (url == null || url.isEmpty) continue;
      final bitrate = int.tryParse(f['bitrate']?.toString() ?? '') ??
          int.tryParse(f['avgBitrate']?.toString() ?? '') ??
          0;
      if (bitrate > bestBitrate) {
        bestBitrate = bitrate;
        bestUrl = url;
      }
    }

    // Fall back to plain progressive streams.
    if (bestUrl == null) {
      final formats = _asList(data['formatStreams']);
      for (final f in formats) {
        if (f is! Map) continue;
        final url = f['url']?.toString();
        if (url == null || url.isEmpty) continue;
        final bitrate = int.tryParse(f['bitrate']?.toString() ?? '') ?? 0;
        if (bitrate > bestBitrate) {
          bestBitrate = bitrate;
          bestUrl = url;
        }
      }
    }

    if (bestUrl == null) return null;
    return (url: bestUrl, userAgent: null);
  }

  Future<({String url, String? userAgent})?> _resolvePiped(
    String base,
    String query,
  ) async {
    // 1. Search.
    final searchUri = Uri.parse(
      '$base/search?q=${Uri.encodeQueryComponent(query)}&filter=videos',
    );
    final searchResp = await _client
        .get(searchUri, headers: _jsonHeaders)
        .timeout(_timeout);

    if (searchResp.statusCode != 200) {
      throw StateError('search HTTP ${searchResp.statusCode}');
    }

    final results = jsonDecode(searchResp.body);
    if (results is! List || results.isEmpty) return null;

    String? videoId;
    for (final item in results.take(5)) {
      if (item is! Map) continue;
      if (item['uploaderVerified'] == null) continue; // skip non-video items
      final url = item['url']?.toString();
      if (url == null || url.isEmpty) continue;
      final id = url.split('/').lastOrNull;
      if (id == null || id.length != 11) continue;

      final duration = int.tryParse(item['duration']?.toString() ?? '');
      if (duration != null && duration < 30) continue;

      videoId = id;
      break;
    }
    if (videoId == null) return null;

    // 2. Get stream info.
    final streamUri = Uri.parse('$base/streams/$videoId');
    final streamResp = await _client
        .get(streamUri, headers: _jsonHeaders)
        .timeout(_timeout);

    if (streamResp.statusCode != 200) {
      throw StateError('streams HTTP ${streamResp.statusCode}');
    }

    final data = jsonDecode(streamResp.body);
    if (data is! Map) return null;

    final audioStreams = _asList(data['audioStreams']);
    String? bestUrl;
    int bestBitrate = 0;
    for (final s in audioStreams) {
      if (s is! Map) continue;
      final url = s['url']?.toString();
      if (url == null || url.isEmpty) continue;
      final bitrate = int.tryParse(s['bitrate']?.toString() ?? '') ??
          int.tryParse(s['bitrateKbps']?.toString() ?? '') ??
          0;
      if (bitrate > bestBitrate) {
        bestBitrate = bitrate;
        bestUrl = url;
      }
    }

    if (bestUrl == null) return null;
    return (url: bestUrl, userAgent: null);
  }

  List<dynamic> _asList(dynamic v) {
    if (v is List) return v;
    return const [];
  }

  Map<String, String> get _jsonHeaders => {
        'Accept': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
      };

  static void _log(String msg) {
    if (kDebugMode) debugPrint('[$_tag] $msg');
  }

  void dispose() {
    _client.close();
  }
}
