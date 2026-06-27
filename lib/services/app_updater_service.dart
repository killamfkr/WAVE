import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_updater_platform.dart'
    if (dart.library.ffi) 'app_updater_platform_native.dart';

class AppUpdaterService {
  /// Default: this fork. Override via `.env` (`GITHUB_UPDATE_REPO=owner/repo`).
  static const String _defaultGithubRepo = 'killamfkr/WAVE';
  static String? _githubRepoOverride;

  static String get githubRepo => _githubRepoOverride ?? _defaultGithubRepo;

  static String get githubApiUrl =>
      'https://api.github.com/repos/$githubRepo/releases/latest';

  static Future<void> loadEnv() async {
    try {
      final content = await rootBundle.loadString('.env');
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length >= 2 && parts[0].trim() == 'GITHUB_UPDATE_REPO') {
          final value = parts.sublist(1).join('=').trim();
          if (value.isNotEmpty) {
            _githubRepoOverride = value;
          }
        }
      }
    } catch (_) {}
  }
  
  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final response = await http.get(Uri.parse(githubApiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = (data['tag_name'] as String).replaceFirst('v', '');
        final releaseNotes = data['body'] as String? ?? 'No release notes available';
        final publishedAt = DateTime.parse(data['published_at']);
        
        if (_isNewerVersion(currentVersion, latestVersion)) {
          final assets = data['assets'] as List;
          final downloadUrl = findReleaseAssetForPlatform(assets);
          
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            downloadUrl: downloadUrl ?? data['html_url'],
            releaseNotes: releaseNotes,
            publishedAt: publishedAt,
            isMacOS: Platform.isMacOS,
            isIOS: Platform.isIOS,
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return null;
    }
  }
  
  bool _isNewerVersion(String current, String latest) {
    // Strip any suffix like "-test" or "-beta" for comparison
    final currentClean = current.split('-').first;
    final latestClean = latest.split('-').first;

    final currentParts = currentClean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final latestParts = latestClean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }
  
  Future<void> openDownloadPage(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final DateTime publishedAt;
  final bool isMacOS;
  final bool isIOS;
  
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
    required this.isMacOS,
    this.isIOS = false,
  });
}
