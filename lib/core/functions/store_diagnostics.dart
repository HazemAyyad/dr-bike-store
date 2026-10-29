import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class StoreDiagnostics {
  static Future<void> initialize() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);
    FlutterError.onError = (details) {
      if (kDebugMode) FlutterError.presentError(details);
      unawaited(
        crashlytics.recordError(
          details.exception.runtimeType.toString(),
          details.stack,
          fatal: true,
        ),
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        crashlytics.recordError(
          error.runtimeType.toString(),
          stack,
          fatal: true,
        ),
      );
      return true;
    };
  }
}
