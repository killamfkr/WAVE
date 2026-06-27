import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Native platforms: pick a GitHub release asset for the current CPU ABI.
String? findReleaseAssetForPlatform(List<dynamic> assets) {
  final abi = Abi.current();
  debugPrint('Detected ABI: $abi');

  if (Platform.isAndroid) {
    return _findAndroidAsset(assets, abi);
  } else if (Platform.isWindows) {
    return _findWindowsAsset(assets, abi);
  } else if (Platform.isLinux) {
    return _findLinuxAsset(assets, abi);
  }
  return null;
}

String? _findAndroidAsset(List<dynamic> assets, Abi abi) {
  final apks = assets.where(
    (a) => (a['name'] as String).toLowerCase().endsWith('.apk'),
  ).toList();

  if (apks.isEmpty) return null;

  final List<String> archKeywords;
  switch (abi) {
    case Abi.androidArm64:
      archKeywords = ['arm64-v8a', 'arm64', 'v8a', 'aarch64'];
    case Abi.androidArm:
      archKeywords = ['armeabi-v7a', 'armeabi', 'v7a', 'armv7'];
    case Abi.androidX64:
      archKeywords = ['x86_64', 'x86-64', 'x64'];
    default:
      archKeywords = [];
  }

  for (final keyword in archKeywords) {
    final match = apks.where(
      (a) => (a['name'] as String).toLowerCase().contains(keyword),
    ).firstOrNull;
    if (match != null) {
      debugPrint('Matched APK for $abi: ${match['name']}');
      return match['browser_download_url'] as String?;
    }
  }

  final universal = apks.where(
    (a) => (a['name'] as String).toLowerCase().contains('universal'),
  ).firstOrNull;
  if (universal != null) {
    return universal['browser_download_url'] as String?;
  }

  if (apks.length == 1) {
    return apks.first['browser_download_url'] as String?;
  }

  return null;
}

String? _findWindowsAsset(List<dynamic> assets, Abi abi) {
  final windowsAssets = assets.where(
    (a) {
      final name = (a['name'] as String).toLowerCase();
      return name.contains('windows') &&
          (name.endsWith('.exe') || name.endsWith('.msix'));
    },
  ).toList();

  if (windowsAssets.isEmpty) return null;
  if (windowsAssets.length == 1) {
    return windowsAssets.first['browser_download_url'] as String?;
  }

  final archKeywords = abi == Abi.windowsArm64
      ? ['arm64', 'aarch64']
      : ['x64', 'x86_64', 'amd64'];

  for (final keyword in archKeywords) {
    final match = windowsAssets.where(
      (a) => (a['name'] as String).toLowerCase().contains(keyword),
    ).firstOrNull;
    if (match != null) return match['browser_download_url'] as String?;
  }

  return windowsAssets.first['browser_download_url'] as String?;
}

String? _findLinuxAsset(List<dynamic> assets, Abi abi) {
  final linuxAssets = assets.where(
    (a) {
      final name = (a['name'] as String).toLowerCase();
      return name.contains('linux') &&
          (name.endsWith('.appimage') ||
              name.endsWith('.deb') ||
              name.endsWith('.tar.gz'));
    },
  ).toList();

  if (linuxAssets.isEmpty) return null;
  if (linuxAssets.length == 1) {
    return linuxAssets.first['browser_download_url'] as String?;
  }

  final archKeywords = abi == Abi.linuxArm64
      ? ['arm64', 'aarch64']
      : ['x86_64', 'x64', 'amd64'];

  for (final keyword in archKeywords) {
    final match = linuxAssets.where(
      (a) => (a['name'] as String).toLowerCase().contains(keyword),
    ).firstOrNull;
    if (match != null) return match['browser_download_url'] as String?;
  }

  return linuxAssets.first['browser_download_url'] as String?;
}
