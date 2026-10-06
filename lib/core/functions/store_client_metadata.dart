import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef PackageInfoLoader = Future<PackageInfo> Function();

class StoreClientMetadata {
  StoreClientMetadata({
    PackageInfoLoader? packageInfoLoader,
    TargetPlatform? platform,
  }) : _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform,
       _platform = platform;

  final PackageInfoLoader _packageInfoLoader;
  final TargetPlatform? _platform;

  Future<Map<String, dynamic>> asJson() async {
    final packageInfo = await _packageInfoLoader();
    final platform = _platform ?? defaultTargetPlatform;
    final platformName = switch (platform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ =>
        throw UnsupportedError(
          'Secure password reset is supported only on Android and iOS.',
        ),
    };

    return {
      'app': 'store',
      'platform': platformName,
      'current_version': packageInfo.version,
      'current_build': int.parse(packageInfo.buildNumber),
    };
  }
}
