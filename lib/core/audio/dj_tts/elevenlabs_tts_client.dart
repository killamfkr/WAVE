import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';
import '../personal_dj_service.dart';

class ElevenLabsTtsClient {
  ElevenLabsTtsClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.elevenlabs.io/v1',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 45),
                responseType: ResponseType.bytes,
                headers: const <String, String>{
                  'Content-Type': 'application/json',
                  'Accept': 'audio/mpeg',
                },
              ),
            );

  final Dio _dio;

  Future<Uint8List> synthesize({
    required String apiKey,
    required String voiceId,
    required String text,
    required PersonalDjMood mood,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || voiceId.trim().isEmpty) return Uint8List(0);

    try {
      final response = await _dio.post<List<int>>(
        '/text-to-speech/${Uri.encodeComponent(voiceId.trim())}',
        queryParameters: const <String, String>{
          'output_format': 'mp3_44100_128',
        },
        options: Options(
          headers: <String, String>{'xi-api-key': apiKey},
        ),
        data: <String, dynamic>{
          'text': trimmed,
          'model_id': 'eleven_turbo_v2_5',
          'voice_settings': _voiceSettingsFor(mood),
        },
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return Uint8List(0);
      return Uint8List.fromList(bytes);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      appLogger.w('ElevenLabs TTS failed ($status): $body');
      rethrow;
    }
  }

  Map<String, dynamic> _voiceSettingsFor(PersonalDjMood mood) => switch (mood) {
        PersonalDjMood.chill => const <String, dynamic>{
            'stability': 0.55,
            'similarity_boost': 0.78,
            'style': 0.25,
            'use_speaker_boost': true,
          },
        PersonalDjMood.hype => const <String, dynamic>{
            'stability': 0.38,
            'similarity_boost': 0.82,
            'style': 0.55,
            'use_speaker_boost': true,
          },
        PersonalDjMood.discover => const <String, dynamic>{
            'stability': 0.45,
            'similarity_boost': 0.8,
            'style': 0.35,
            'use_speaker_boost': true,
          },
        PersonalDjMood.mixed => const <String, dynamic>{
            'stability': 0.42,
            'similarity_boost': 0.8,
            'style': 0.4,
            'use_speaker_boost': true,
          },
      };
}
