import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dj_tts_env.dart';

/// Stores user-supplied TTS API keys on-device.
class DjTtsKeyStore {
  DjTtsKeyStore._();
  static final DjTtsKeyStore instance = DjTtsKeyStore._();

  static const _openAiKey = 'wave_dj_openai_api_key';
  static const _elevenLabsKey = 'wave_dj_elevenlabs_api_key';

  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  String? _openAiCached;
  String? _elevenLabsCached;

  Future<String?> openAiKey() async {
    final user = _openAiCached ??= await _secure.read(key: _openAiKey);
    if (user != null && user.trim().isNotEmpty) return user.trim();
    return DjTtsEnv.openAiApiKey?.trim();
  }

  Future<String?> elevenLabsKey() async {
    final user =
        _elevenLabsCached ??= await _secure.read(key: _elevenLabsKey);
    if (user != null && user.trim().isNotEmpty) return user.trim();
    return DjTtsEnv.elevenLabsApiKey?.trim();
  }

  Future<bool> hasUserOpenAiKey() async {
    final v = await _secure.read(key: _openAiKey);
    return v != null && v.trim().isNotEmpty;
  }

  Future<bool> hasUserElevenLabsKey() async {
    final v = await _secure.read(key: _elevenLabsKey);
    return v != null && v.trim().isNotEmpty;
  }

  Future<void> saveOpenAiKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      await _secure.delete(key: _openAiKey);
      _openAiCached = null;
      return;
    }
    await _secure.write(key: _openAiKey, value: trimmed);
    _openAiCached = trimmed;
  }

  Future<void> saveElevenLabsKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      await _secure.delete(key: _elevenLabsKey);
      _elevenLabsCached = null;
      return;
    }
    await _secure.write(key: _elevenLabsKey, value: trimmed);
    _elevenLabsCached = trimmed;
  }

  Future<void> clearOpenAiKey() => saveOpenAiKey('');
  Future<void> clearElevenLabsKey() => saveElevenLabsKey('');

  void invalidateCache() {
    _openAiCached = null;
    _elevenLabsCached = null;
  }
}

final djTtsKeyStoreProvider = Provider<DjTtsKeyStore>(
  (ref) => DjTtsKeyStore.instance,
);
