import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'dart:math';

import 'package:crypto/crypto.dart';

/// Edge TTS client with correct binary audio frame handling.
class WaveEdgeTts {
  /// Male voices currently available on the Edge consumer API.
  static const preferredMaleVoices = <String>[
    'en-US-AndrewNeural',
    'en-US-ChristopherNeural',
    'en-US-GuyNeural',
    'en-US-BrianNeural',
    'en-US-EricNeural',
  ];

  static const defaultVoice = 'en-US-AndrewNeural';

  WaveEdgeTts({
    this.voice = defaultVoice,
    this.voiceLocale = 'en-US',
  });

  static const _trustedClientToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';
  static const _wssUrl =
      'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1';
  static const _secMsGecVersion = '1-143.0.3650.75';
  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0';

  final String voice;
  final String voiceLocale;

  Future<Uint8List> synthesize(
    String text, {
    String rate = '+6%',
    String pitch = '+0Hz',
    String volume = '+0%',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Uint8List(0);

    final ssml = _buildSsml(trimmed, rate: rate, pitch: pitch, volume: volume);

    final connectionId = _randomHex(16);
    final url = _buildSynthesisUrl(connectionId);
    final configTimestamp = _formatTimestamp();

    WebSocket? socket;
    try {
      socket = await _connect(url);

      final done = Completer<void>();
      final audio = BytesBuilder(copy: false);

      final sub = socket.listen(
        (message) {
          if (message is String) {
            if (message.contains('Path:turn.end')) {
              if (!done.isCompleted) done.complete();
            }
            return;
          }
          if (message is List<int>) {
            final chunk = _parseAudioChunk(Uint8List.fromList(message));
            if (chunk != null && chunk.isNotEmpty) {
              audio.add(chunk);
            }
          }
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
        onError: (Object e, StackTrace st) {
          if (!done.isCompleted) done.completeError(e, st);
        },
        cancelOnError: true,
      );

      socket.add(_speechConfig(configTimestamp));
      socket.add(
        _ssmlMessage(
          ssml: ssml,
          requestId: connectionId,
          timestamp: _formatTimestamp(),
        ),
      );

      await done.future.timeout(const Duration(seconds: 30));
      await sub.cancel();
      return audio.toBytes();
    } finally {
      await socket?.close();
    }
  }

  Uint8List? _parseAudioChunk(Uint8List data) {
    if (data.length < 2) return null;

    final headerLength = (data[0] << 8) | data[1];
    if (headerLength <= 0 || 2 + headerLength > data.length) return null;

    final headerText = utf8.decode(data.sublist(2, 2 + headerLength));
    if (!headerText.contains('Path:audio')) return null;
    if (!headerText.contains('Content-Type:audio/mpeg')) {
      // Termination frame with no audio payload.
      return null;
    }

    final audioStart = 2 + headerLength;
    if (audioStart >= data.length) return null;
    return data.sublist(audioStart);
  }

  Future<WebSocket> _connect(String url) async {
    final uri = Uri.parse(url);
    final requestUri = uri.replace(scheme: 'https');
    final httpClient = HttpClient()..userAgent = _userAgent;
    try {
      final request = await httpClient.openUrl('GET', requestUri);
      request.headers.set(HttpHeaders.hostHeader, uri.host);
      request.headers.set(HttpHeaders.upgradeHeader, 'websocket');
      request.headers.set(HttpHeaders.connectionHeader, 'Upgrade');
      request.headers.set('Sec-WebSocket-Key', _webSocketKey());
      request.headers.set('Sec-WebSocket-Version', '13');
      request.headers.set(
        'Sec-WebSocket-Extensions',
        'permessage-deflate; client_max_window_bits',
      );
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'gzip, deflate, br, zstd');
      request.headers.set(HttpHeaders.acceptLanguageHeader, 'en-US,en;q=0.9');
      request.headers.set('Pragma', 'no-cache');
      request.headers.set('Cache-Control', 'no-cache');
      request.headers.set('Origin', 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold');
      request.headers.set(HttpHeaders.cookieHeader, 'muid=${_randomHex(16).toUpperCase()};');

      final response = await request.close();
      if (response.statusCode != HttpStatus.switchingProtocols) {
        final body = await response.transform(utf8.decoder).join();
        throw StateError('Edge TTS websocket failed: ${response.statusCode} $body');
      }

      final upgraded = await response.detachSocket();
      return WebSocket.fromUpgradedSocket(
        upgraded,
        serverSide: false,
        compression: CompressionOptions.compressionDefault,
      );
    } finally {
      httpClient.close(force: true);
    }
  }

  String _buildSynthesisUrl(String connectionId) {
    final secMsGec = _secMsGec();
    return '$_wssUrl?TrustedClientToken=$_trustedClientToken'
        '&ConnectionId=$connectionId'
        '&Sec-MS-GEC=$secMsGec'
        '&Sec-MS-GEC-Version=$_secMsGecVersion';
  }

  String _buildSsml(
    String text, {
    required String rate,
    required String pitch,
    required String volume,
  }) {
    final escaped = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
    return "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' "
        "xml:lang='$voiceLocale'>"
        "<voice name='$voice'>"
        "<prosody pitch='$pitch' rate='$rate' volume='$volume'>"
        '$escaped'
        '</prosody></voice></speak>';
  }

  String _speechConfig(String timestamp) {
    return 'X-Timestamp:$timestamp\r\n'
        'Content-Type:application/json; charset=utf-8\r\n'
        'Path:speech.config\r\n'
        '\r\n'
        '{"context":{"synthesis":{"audio":{"metadataoptions":'
        '{"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"false"},'
        '"outputFormat":"audio-24khz-48kbitrate-mono-mp3"}}}}\r\n';
  }

  String _ssmlMessage({
    required String ssml,
    required String requestId,
    required String timestamp,
  }) {
    return 'X-RequestId:$requestId\r\n'
        'Content-Type:application/ssml+xml\r\n'
        'X-Timestamp:${timestamp}Z\r\n'
        'Path:ssml\r\n'
        '\r\n'
        '${ssml.trim()}';
  }

  String _secMsGec() {
    final ticks = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 11644473600;
    final rounded = ticks - (ticks % 300);
    final windowsTicks = rounded * 10000000;
    final digest = sha256.convert(utf8.encode('$windowsTicks$_trustedClientToken'));
    return digest.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }

  String _formatTimestamp() {
    final utc = DateTime.now().toUtc();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final wd = weekdays[utc.weekday - 1];
    final mo = months[utc.month - 1];
    final d = utc.day.toString().padLeft(2, '0');
    final h = utc.hour.toString().padLeft(2, '0');
    final mi = utc.minute.toString().padLeft(2, '0');
    final s = utc.second.toString().padLeft(2, '0');
    return '$wd $mo $d ${utc.year} $h:$mi:$s GMT+0000 (Coordinated Universal Time)';
  }

  String _webSocketKey() {
    final values = List<int>.generate(16, (_) => _rand.nextInt(256));
    return base64Encode(values);
  }

  String _randomHex(int bytes) {
    return List<int>.generate(bytes, (_) => _rand.nextInt(256))
        .map((v) => v.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static final _rand = Random.secure();
}
