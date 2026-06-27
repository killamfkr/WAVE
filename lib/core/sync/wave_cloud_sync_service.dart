import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../utils/app_logger.dart';
import 'supabase_sync_config.dart';
import 'wave_library_bundle.dart';

class WaveCloudException implements Exception {
  const WaveCloudException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Supabase auth + `user_settings` sync for WAVE (same project as PlayTorrio/Stories).
class WaveCloudSyncService {
  WaveCloudSyncService._();
  static final WaveCloudSyncService instance = WaveCloudSyncService._();

  static const _accessKey = 'wave_supabase_access_token';
  static const _refreshKey = 'wave_supabase_refresh_token';
  static const _emailKey = 'wave_supabase_email';
  static const _restSettings = '/rest/v1/user_settings';
  static const _preferUpsert = 'return=minimal,resolution=merge-duplicates';

  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  String? _access;
  String? _refresh;

  String? get _base {
    final u = SupabaseSyncConfig.url?.trim();
    if (u == null || u.isEmpty) return null;
    return u.replaceAll(RegExp(r'/+$'), '');
  }

  String? get _anon {
    final k = SupabaseSyncConfig.anonKey?.trim();
    return k == null || k.isEmpty ? null : k;
  }

  bool get isConfigured => _base != null && _anon != null;

  void _requireConfig() {
    if (!isConfigured) {
      throw const WaveCloudException(
        'Cloud sync is not configured in this build.',
      );
    }
  }

  Future<String?> _readSecure(String key) async {
    try {
      return await _secure.read(key: key).timeout(const Duration(seconds: 4));
    } catch (e) {
      appLogger.w('Secure read failed for $key: $e');
      return null;
    }
  }

  Future<String?> get _accessToken async {
    if (_access != null && _access!.isNotEmpty) return _access;
    _access = await _readSecure(_accessKey);
    return _access;
  }

  Future<String?> get _refreshToken async {
    if (_refresh != null && _refresh!.isNotEmpty) return _refresh;
    _refresh = await _readSecure(_refreshKey);
    return _refresh;
  }

  Future<void> _saveSession(
    String access,
    String? refresh, {
    String? email,
  }) async {
    _access = access;
    await _secure.write(key: _accessKey, value: access);
    if (refresh != null && refresh.isNotEmpty) {
      _refresh = refresh;
      await _secure.write(key: _refreshKey, value: refresh);
    }
    if (email != null && email.isNotEmpty) {
      await _secure.write(key: _emailKey, value: email);
    }
  }

  Map<String, String> _headers(String token) => <String, String>{
        'apikey': _anon!,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  static bool isJwtAccessExpired(String jwt, {int leewaySeconds = 60}) {
    final exp = jwtExpUnixSeconds(jwt);
    if (exp == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= exp - leewaySeconds;
  }

  static int? jwtExpUnixSeconds(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) return null;
    var seg = parts[1];
    final m = seg.length % 4;
    if (m > 0) seg += '=' * (4 - m);
    try {
      final map = json.decode(utf8.decode(base64Url.decode(seg)))
          as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp is int) return exp;
      if (exp is num) return exp.toInt();
    } catch (_) {
      return null;
    }
    return null;
  }

  static String? userIdFromJwt(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) return null;
    var seg = parts[1];
    final m = seg.length % 4;
    if (m > 0) seg += '=' * (4 - m);
    try {
      final map = json.decode(utf8.decode(base64Url.decode(seg)))
          as Map<String, dynamic>;
      return map['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearAccessTokenOnly() async {
    _access = null;
    await _secure.delete(key: _accessKey);
  }

  Future<http.Response> _withAccessRetry(
    Future<http.Response> Function(String accessToken) send,
  ) async {
    await _ensureAccess();
    var token = await _accessToken;
    if (token == null || token.isEmpty) {
      throw const WaveCloudException('Not signed in');
    }
    var res = await send(token);
    if (res.statusCode != 401) return res;
    await _clearAccessTokenOnly();
    try {
      await _ensureAccess();
    } catch (_) {
      await signOut();
      return res;
    }
    token = await _accessToken;
    if (token == null || token.isEmpty) {
      await signOut();
      return res;
    }
    res = await send(token);
    if (res.statusCode == 401) await signOut();
    return res;
  }

  Future<void> _ensureAccess() async {
    final existing = await _accessToken;
    if (existing != null &&
        existing.isNotEmpty &&
        !isJwtAccessExpired(existing)) {
      return;
    }
    _access = null;
    final rt = await _refreshToken;
    if (rt == null || rt.isEmpty) {
      throw const WaveCloudException('Not signed in');
    }
    _requireConfig();
    final res = await http.post(
      Uri.parse('$_base/auth/v1/token?grant_type=refresh_token'),
      headers: <String, String>{
        'apikey': _anon!,
        'Content-Type': 'application/json',
      },
      body: json.encode(<String, dynamic>{'refresh_token': rt}),
    );
    if (res.statusCode != 200) {
      await signOut();
      throw const WaveCloudException('Session expired. Sign in again.');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    await _saveSession(
      data['access_token'] as String,
      data['refresh_token'] as String?,
    );
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _requireConfig();
    final res = await http.post(
      Uri.parse('$_base/auth/v1/token?grant_type=password'),
      headers: <String, String>{
        'apikey': _anon!,
        'Content-Type': 'application/json',
      },
      body: json.encode(<String, dynamic>{
        'email': email.trim(),
        'password': password,
      }),
    );
    if (res.statusCode != 200) {
      var msg = res.body;
      try {
        final m = json.decode(res.body) as Map<String, dynamic>?;
        msg = m?['error_description']?.toString() ??
            m?['message']?.toString() ??
            msg;
      } catch (_) {}
      throw WaveCloudException(msg);
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    await _saveSession(
      data['access_token'] as String,
      data['refresh_token'] as String?,
      email: email.trim(),
    );
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    _requireConfig();
    final res = await http.post(
      Uri.parse('$_base/auth/v1/signup'),
      headers: <String, String>{
        'apikey': _anon!,
        'Content-Type': 'application/json',
      },
      body: json.encode(<String, dynamic>{
        'email': email.trim(),
        'password': password,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      var msg = res.body;
      try {
        final m = json.decode(res.body) as Map<String, dynamic>?;
        msg = m?['error_description']?.toString() ??
            m?['message']?.toString() ??
            msg;
      } catch (_) {}
      throw WaveCloudException(msg);
    }
    final data = json.decode(res.body) as Map<String, dynamic>?;
    final at = data?['access_token'] as String?;
    if (at != null && at.isNotEmpty) {
      await _saveSession(
        at,
        data!['refresh_token'] as String?,
        email: email.trim(),
      );
      return;
    }
    await signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    final token = await _accessToken;
    if (token != null && token.isNotEmpty && isConfigured) {
      try {
        unawaited(http.post(
          Uri.parse('$_base/auth/v1/logout'),
          headers: <String, String>{
            'apikey': _anon!,
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
      } catch (_) {}
    }
    _access = null;
    _refresh = null;
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
    await _secure.delete(key: _emailKey);
  }

  Future<bool> hasStoredSession() async =>
      (await _accessToken)?.isNotEmpty == true ||
      (await _refreshToken)?.isNotEmpty == true;

  Future<String?> signedInEmail() => _readSecure(_emailKey);

  Future<Map<String, dynamic>> _fetchRemotePrefs() async {
    final res = await _withAccessRetry((token) {
      final userId = userIdFromJwt(token);
      if (userId == null) {
        return Future.value(
          http.Response('{"message":"no sub in access token"}', 400),
        );
      }
      return http.get(
        Uri.parse(
          '$_base$_restSettings?select=prefs&user_id=eq.$userId&profile_id=eq.${WaveLibraryBundle.profileId}',
        ),
        headers: _headers(token),
      );
    });
    if (res.statusCode != 200) {
      debugPrint('[WAVE Cloud] fetch prefs: ${res.statusCode}');
      return <String, dynamic>{};
    }
    final decoded = json.decode(res.body);
    if (decoded is! List || decoded.isEmpty) return <String, dynamic>{};
    final first = decoded.first;
    if (first is! Map) return <String, dynamic>{};
    final prefs = first['prefs'];
    if (prefs is! Map) return <String, dynamic>{};
    return prefs.map((k, v) => MapEntry(k.toString(), v));
  }

  Future<WaveLibraryBundle?> pullWaveLibrary() async {
    if (!isConfigured || !await hasStoredSession()) return null;
    final prefs = await _fetchRemotePrefs();
    return WaveLibraryBundle.parse(prefs[WaveLibraryBundle.prefsKey]);
  }

  Future<void> pushWaveLibrary(WaveLibraryBundle bundle) async {
    if (!isConfigured || !await hasStoredSession()) return;

    final remotePrefs = await _fetchRemotePrefs();
    final merged = <String, dynamic>{...remotePrefs}
      ..[WaveLibraryBundle.prefsKey] = bundle.toJson();

    final res = await _withAccessRetry((token) {
      final uid = userIdFromJwt(token);
      if (uid == null) {
        return Future.value(
          http.Response('{"message":"no sub in access token"}', 400),
        );
      }
      return http.post(
        Uri.parse('$_base$_restSettings?on_conflict=user_id,profile_id'),
        headers: <String, String>{
          ..._headers(token),
          'Prefer': _preferUpsert,
        },
        body: json.encode(<String, dynamic>{
          'user_id': uid,
          'profile_id': WaveLibraryBundle.profileId,
          'prefs': merged,
        }),
      );
    });
    if (res.statusCode < 200 || res.statusCode >= 300) {
      appLogger.w(
        'WAVE cloud push failed: HTTP ${res.statusCode} ${res.body}',
      );
      throw WaveCloudException('Could not upload library to cloud.');
    }
  }
}
