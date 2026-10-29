import 'dart:async';

enum StoreRequestOperation { catalog, shipping, checkout }

enum StoreRequestOutcome {
  success,
  httpError,
  applicationError,
  invalidResponse,
  timeout,
  networkError,
}

/// Contains only fixed operation/outcome names, a UUID and numeric measurements.
/// Request/response bodies, URLs, headers and exception messages cannot enter it.
class StoreRequestMetric {
  const StoreRequestMetric._({
    required this.operation,
    required this.requestId,
    required this.durationMs,
    required this.outcome,
    this.statusCode,
  });

  final StoreRequestOperation operation;
  final String requestId;
  final int durationMs;
  final int? statusCode;
  final StoreRequestOutcome outcome;

  Map<String, Object> toJson() => {
    'operation': operation.name,
    'request_id': requestId,
    'duration_ms': durationMs,
    if (statusCode != null) 'status': statusCode!,
    'outcome': outcome.name,
  };
}

typedef StoreRequestMetricSink =
    FutureOr<void> Function(StoreRequestMetric metric);

class StoreRequestDiagnostics {
  const StoreRequestDiagnostics({required StoreRequestMetricSink sink})
    : _sink = sink;

  final StoreRequestMetricSink _sink;

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static bool isRequestId(String? value) =>
      value != null && value.length == 36 && _uuid.hasMatch(value);

  StoreRequestTrace? start({
    required String method,
    required String uri,
    required String requestId,
  }) {
    final path = Uri.tryParse(uri)?.path;
    final operation = switch ((method, path)) {
      ('GET', '/OnlineStore/Catalog') ||
      (
        'POST',
        '/Items/GetAllItemsShowByMainCategory',
      ) => StoreRequestOperation.catalog,
      ('POST', '/Cities/CalculateDeliveryFee') =>
        StoreRequestOperation.shipping,
      ('POST', '/OnlineStore/Checkout') => StoreRequestOperation.checkout,
      _ => null,
    };
    if (operation == null || !isRequestId(requestId)) return null;
    return StoreRequestTrace._(operation, requestId, _sink);
  }
}

class StoreRequestTrace {
  StoreRequestTrace._(this._operation, this._requestId, this._sink);

  final StoreRequestOperation _operation;
  final String _requestId;
  final StoreRequestMetricSink _sink;
  final Stopwatch _watch = Stopwatch()..start();
  bool _finished = false;

  void finish({
    required StoreRequestOutcome outcome,
    int? statusCode,
    String? responseRequestId,
  }) {
    if (_finished) return;
    _finished = true;
    _watch.stop();
    final metric = StoreRequestMetric._(
      operation: _operation,
      requestId:
          StoreRequestDiagnostics.isRequestId(responseRequestId)
              ? responseRequestId!
              : _requestId,
      durationMs: _watch.elapsedMilliseconds,
      statusCode:
          statusCode != null && statusCode >= 100 && statusCode <= 599
              ? statusCode
              : null,
      outcome: outcome,
    );
    // Neither an unavailable plugin nor a slow/failed sink can change a request.
    unawaited(
      Future<void>.sync(
        () => _sink(metric),
      ).catchError((Object _, StackTrace __) {}),
    );
  }
}
