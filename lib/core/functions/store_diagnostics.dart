import 'dart:async';
import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'store_request_diagnostics.dart';

class StoreDiagnostics {
  static bool _requestCollectionEnabled = false;
  static final requests = StoreRequestDiagnostics(sink: _recordRequest);

  static Future<void> _recordRequest(StoreRequestMetric metric) async {
    if (!_requestCollectionEnabled) return;
    await FirebaseCrashlytics.instance.log(
      'store_request ${jsonEncode(metric.toJson())}',
    );
  }

  static Future<void> initialize() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);
    _requestCollectionEnabled = kReleaseMode;
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
