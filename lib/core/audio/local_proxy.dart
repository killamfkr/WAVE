import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

class LocalProxy {
  static HttpServer? _server;
  static int? _port;
  static bool get isRunning => _server != null;
  static int get port => _port ?? 0;

  static Future<void> start() async {
    if (isRunning) return;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _port = _server!.port;
      appLogger.i('LocalProxy listening on $_port');

      _server!.listen((HttpRequest request) async {
        final targetUrl = request.uri.queryParameters['url'];
        final userAgent = request.uri.queryParameters['ua'];

        if (targetUrl == null) {
          request.response.statusCode = HttpStatus.badRequest;
          await request.response.close();
          return;
        }

        try {
          final uri = Uri.parse(targetUrl);
          
          final proxyRequest = http.Request('GET', uri);
          
          // Add essential headers to bypass YouTube restrictions
          proxyRequest.headers['User-Agent'] = userAgent ?? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36';
          proxyRequest.headers['Origin'] = 'https://www.youtube.com';
          proxyRequest.headers['Referer'] = 'https://www.youtube.com/';
          proxyRequest.headers['Accept'] = '*/*';
          proxyRequest.headers['Accept-Language'] = 'en-US,en;q=0.9';
          
          // Pass range header if media_kit requests a specific chunk
          if (request.headers.value('range') != null) {
            proxyRequest.headers['Range'] = request.headers.value('range')!;
          }

          final client = http.Client();
          final response = await client.send(proxyRequest);

          request.response.statusCode = response.statusCode;
          
          // Copy headers back to media_kit
          response.headers.forEach((key, value) {
            if (['content-type', 'content-length', 'accept-ranges', 'content-range'].contains(key.toLowerCase())) {
              request.response.headers.set(key, value);
            }
          });

          await response.stream.pipe(request.response);
          client.close();
        } catch (e) {
          appLogger.e('Proxy error: $e');
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
        }
      });
    } catch (e) {
      appLogger.e('Failed to start LocalProxy: $e');
    }
  }

  static void stop() {
    _server?.close();
    _server = null;
  }
}
