import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';
import '../personal_dj_service.dart';
import 'dj_tts_config.dart';

class OpenAiTtsClient {
  OpenAiTtsClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.openai.com/v1',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 45),
                responseType: ResponseType.bytes,
                headers: const <String, String>{
                  'Content-Type': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Future<Uint8List> synthesize({
    required String apiKey,
    required String text,
    required String voice,
    required String instructions,
    required PersonalDjMood mood,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Uint8List(0);

    try {
      final response = await _dio.post<List<int>>(
        '/audio/speech',
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $apiKey'},
        ),
        data: <String, dynamic>{
          'model': 'gpt-4o-mini-tts',
          'input': trimmed,
          'voice': voice,
          'instructions': instructions,
          'response_format': 'mp3',
          'speed': openAiSpeedFor(mood),
        },
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return Uint8List(0);
      return Uint8List.fromList(bytes);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      appLogger.w('OpenAI TTS failed ($status): $body');
      rethrow;
    }
  }
}
