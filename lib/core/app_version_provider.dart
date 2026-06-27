import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionInfo {
  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
  });

  final String version;
  final String buildNumber;

  String get label => 'v$version  ·  Build $buildNumber';
}

final appVersionProvider = FutureProvider<AppVersionInfo>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return AppVersionInfo(
    version: info.version,
    buildNumber: info.buildNumber,
  );
});
