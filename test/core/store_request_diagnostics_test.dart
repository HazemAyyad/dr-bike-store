import 'dart:async';
import 'dart:convert';

import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/functions/store_request_diagnostics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late List<StoreRequestMetric> metrics;
  late ApiClient client;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    metrics = [];
    client = ApiClient(
      sharedPreferences: preferences,
      requestDiagnostics: StoreRequestDiagnostics(sink: metrics.add),
    );
  });

  http.Response jsonResponse(
    http.Request request, {
    int status = 200,
    Object? body = const {'rows': []},
    String? responseId,
  }) => http.Response(
    jsonEncode(body),
    status,
    request: request,
    headers: {
      'content-type': 'application/json',
      if (responseId != null) 'x-request-id': responseId,
    },
  );

  test(
    'catalog duration and UUID join the outgoing request and server response',
    () async {
      late http.Request sent;
      final result = await http.runWithClient(
        () => client.getData(
          '/OnlineStore/Catalog',
          query: {'q': 'private-search'},
        ),
        () => MockClient((request) async {
          sent = request;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return jsonResponse(
            request,
            responseId: request.headers['x-request-id'],
          );
        }),
      );
      expect(result.statusCode, 200);
      expect(metrics, hasLength(1));
      final metric = metrics.single;
      expect(metric.operation, StoreRequestOperation.catalog);
      expect(metric.outcome, StoreRequestOutcome.success);
      expect(metric.statusCode, 200);
      expect(metric.durationMs, greaterThanOrEqualTo(10));
      expect(StoreRequestDiagnostics.isRequestId(metric.requestId), isTrue);
      expect(metric.requestId, sent.headers['x-request-id']);
      expect(sent.url.queryParameters['q'], 'private-search');
      expect(jsonEncode(metric.toJson()), isNot(contains('private-search')));
    },
  );

  for (final operation in [
    ('/Cities/CalculateDeliveryFee', 503, StoreRequestOperation.shipping),
    ('/OnlineStore/Checkout', 422, StoreRequestOperation.checkout),
  ]) {
    test(
      '${operation.$3.name} failure has no private request or response content',
      () async {
        final result = await http.runWithClient(
          () => client.postData(
            '${operation.$1}?email=private-email',
            body: {
              'address': 'private-address',
              'items': ['private-product'],
              'resetProof': 'private-proof',
            },
            headers: {'Authorization': 'Bearer private-token'},
          ),
          () => MockClient(
            (request) async => jsonResponse(
              request,
              status: operation.$2,
              body: {
                'message': 'private-server-error',
                'order_id': 'private-order',
              },
            ),
          ),
        );
        expect(result.statusCode, operation.$2);
        expect(metrics, hasLength(1));
        final metric = metrics.single;
        expect(metric.operation, operation.$3);
        expect(metric.outcome, StoreRequestOutcome.httpError);
        expect(metric.statusCode, operation.$2);
        expect(metric.toJson().keys.toSet(), {
          'operation',
          'request_id',
          'duration_ms',
          'status',
          'outcome',
        });
        expect(jsonEncode(metric.toJson()), isNot(contains('private')));
      },
    );
  }

  test(
    'accepted checkout response remains usable and is measured once',
    () async {
      final result = await http.runWithClient(
        () => client.postData(
          '/OnlineStore/Checkout',
          body: {'client_request_id': 'private-order-replay-id'},
        ),
        () => MockClient(
          (request) async => jsonResponse(
            request,
            status: 201,
            body: {'isSuccess': true, 'order_id': 'private-order'},
          ),
        ),
      );
      expect(result.statusCode, 201);
      expect(result.body['order_id'], 'private-order');
      expect(metrics.single.outcome, StoreRequestOutcome.success);
      expect(metrics.single.statusCode, 201);
      expect(jsonEncode(metrics.single.toJson()), isNot(contains('private')));
    },
  );

  test(
    'an HTTP 200 rejection is distinct from an accepted operation',
    () async {
      await http.runWithClient(
        () => client.postData('/OnlineStore/Checkout'),
        () => MockClient(
          (request) async => jsonResponse(
            request,
            body: {'isSuccess': false, 'message': 'private-failure'},
          ),
        ),
      );
      expect(metrics.single.outcome, StoreRequestOutcome.applicationError);
      expect(metrics.single.statusCode, 200);
      expect(
        jsonEncode(metrics.single.toJson()),
        isNot(contains('private-failure')),
      );
    },
  );

  for (final contentType in ['application/json', 'text/html']) {
    test(
      'invalid $contentType response is recorded without its content',
      () async {
        await http.runWithClient(
          () => client.getData('/OnlineStore/Catalog'),
          () => MockClient(
            (request) async => http.Response(
              'private-invalid-body',
              200,
              headers: {'content-type': contentType},
              request: request,
            ),
          ),
        );
        expect(metrics.single.outcome, StoreRequestOutcome.invalidResponse);
        expect(metrics.single.statusCode, 200);
        expect(
          jsonEncode(metrics.single.toJson()),
          isNot(contains('private-invalid-body')),
        );
      },
    );
  }

  test(
    'network error text is omitted and no HTTP status is invented',
    () async {
      final result = await http.runWithClient(
        () => client.getData('/OnlineStore/Catalog'),
        () => MockClient(
          (_) async =>
              throw http.ClientException('private-email private-token'),
        ),
      );
      expect(result.statusCode, 1);
      expect(metrics.single.outcome, StoreRequestOutcome.networkError);
      expect(metrics.single.toJson(), isNot(contains('status')));
      expect(jsonEncode(metrics.single.toJson()), isNot(contains('private')));
    },
  );

  for (final body in <Object?>[null, <Object>[], 'private-scalar']) {
    test(
      'non-object JSON response is not counted as accepted: ${body.runtimeType}',
      () async {
        await http.runWithClient(
          () => client.getData('/OnlineStore/Catalog'),
          () =>
              MockClient((request) async => jsonResponse(request, body: body)),
        );
        expect(metrics.single.outcome, StoreRequestOutcome.invalidResponse);
        expect(metrics.single.statusCode, 200);
        expect(jsonEncode(metrics.single.toJson()), isNot(contains('private')));
      },
    );
  }

  test(
    'timeout is measured once even when the transport later completes',
    () async {
      final pending = Completer<http.Response>();
      final result = await http.runWithClient(
        () => client.postData('/OnlineStore/Checkout', timeout: 0),
        () => MockClient((_) => pending.future),
      );
      expect(result.statusCode, 1);
      expect(metrics.single.outcome, StoreRequestOutcome.timeout);
      expect(metrics.single.statusCode, isNull);
      pending.complete(http.Response('{}', 200));
      await Future<void>.delayed(Duration.zero);
      expect(metrics, hasLength(1));
    },
  );

  for (final asynchronous in [false, true]) {
    test(
      'a failed monitoring sink cannot change HTTP success: async=$asynchronous',
      () async {
        var attempted = 0;
        client = ApiClient(
          sharedPreferences: preferences,
          requestDiagnostics: StoreRequestDiagnostics(
            sink: (_) {
              attempted++;
              if (asynchronous) {
                return Future<void>.error(
                  StateError('private-monitoring-error'),
                );
              }
              throw StateError('private-monitoring-error');
            },
          ),
        );
        final result = await http.runWithClient(
          () => client.getData('/OnlineStore/Catalog'),
          () => MockClient((request) async => jsonResponse(request)),
        );
        await Future<void>.delayed(Duration.zero);
        expect(result.statusCode, 200);
        expect(result.body, {'rows': []});
        expect(attempted, 1);
      },
    );
  }

  test(
    'an unfinished monitoring upload does not delay the HTTP result',
    () async {
      final upload = Completer<void>();
      addTearDown(upload.complete);
      client = ApiClient(
        sharedPreferences: preferences,
        requestDiagnostics: StoreRequestDiagnostics(sink: (_) => upload.future),
      );
      final result = await http
          .runWithClient(
            () => client.getData('/OnlineStore/Catalog'),
            () => MockClient((request) async => jsonResponse(request)),
          )
          .timeout(const Duration(seconds: 2));
      expect(result.statusCode, 200);
      expect(upload.isCompleted, isFalse);
    },
  );

  test(
    'private routes outside the operation allowlist produce no metric',
    () async {
      await http.runWithClient(
        () => client.postData(
          '/Auth/ChangePasswordToForgot',
          body: {'resetProof': 'private-proof'},
        ),
        () => MockClient((request) async => jsonResponse(request)),
      );
      expect(metrics, isEmpty);
    },
  );

  test(
    'legacy catalog fallback retains measurement without a response UUID',
    () async {
      late String sentId;
      await http.runWithClient(
        () => client.postData(
          '/Items/GetAllItemsShowByMainCategory?MainCategory=private-category',
        ),
        () => MockClient((request) async {
          sentId = request.headers['x-request-id']!;
          return jsonResponse(request);
        }),
      );
      expect(metrics.single.operation, StoreRequestOperation.catalog);
      expect(metrics.single.requestId, sentId);
      expect(
        jsonEncode(metrics.single.toJson()),
        isNot(contains('private-category')),
      );
    },
  );

  test(
    'valid case-insensitive trace headers are retained and server UUID is preferred',
    () async {
      const suppliedId = '640de648-80f4-41a6-b00b-d6e6a09ce8cb';
      const serverId = 'b6cccfb9-9018-44e0-8f86-20a90493214c';
      await http.runWithClient(
        () => client.getData(
          '/OnlineStore/Catalog',
          headers: {'x-request-id': suppliedId},
        ),
        () => MockClient((request) async {
          expect(request.headers['x-request-id'], suppliedId);
          expect(
            request.headers.keys.where(
              (key) => key.toLowerCase() == 'x-request-id',
            ),
            hasLength(1),
          );
          return jsonResponse(request, responseId: serverId);
        }),
      );
      expect(metrics.single.requestId, serverId);
    },
  );

  test(
    'invalid incoming and response trace values cannot become telemetry',
    () async {
      late String generatedId;
      await http.runWithClient(
        () => client.getData(
          '/OnlineStore/Catalog',
          headers: {'X-Request-ID': 'private-email'},
        ),
        () => MockClient((request) async {
          generatedId = request.headers['x-request-id']!;
          expect(StoreRequestDiagnostics.isRequestId(generatedId), isTrue);
          return jsonResponse(request, responseId: 'private-server-proof');
        }),
      );
      expect(metrics.single.requestId, generatedId);
      expect(jsonEncode(metrics.single.toJson()), isNot(contains('private')));
    },
  );

  test(
    'overlapping requests keep their own IDs and outcomes when completion reverses',
    () async {
      final catalog = Completer<http.Response>();
      final shipping = Completer<http.Response>();
      final requests = <String, http.Request>{};
      await http.runWithClient(
        () async {
          final catalogResult = client.getData('/OnlineStore/Catalog');
          final shippingResult = client.postData(
            '/Cities/CalculateDeliveryFee',
          );
          await Future<void>.delayed(Duration.zero);
          final shippingRequest = requests['/Cities/CalculateDeliveryFee']!;
          shipping.complete(
            jsonResponse(
              shippingRequest,
              status: 503,
              responseId: shippingRequest.headers['x-request-id'],
            ),
          );
          await shippingResult;
          final catalogRequest = requests['/OnlineStore/Catalog']!;
          catalog.complete(
            jsonResponse(
              catalogRequest,
              responseId: catalogRequest.headers['x-request-id'],
            ),
          );
          await catalogResult;
        },
        () => MockClient((request) {
          requests[request.url.path] = request;
          return request.url.path == '/OnlineStore/Catalog'
              ? catalog.future
              : shipping.future;
        }),
      );
      expect(metrics.map((metric) => metric.operation), [
        StoreRequestOperation.shipping,
        StoreRequestOperation.catalog,
      ]);
      expect(metrics.map((metric) => metric.outcome), [
        StoreRequestOutcome.httpError,
        StoreRequestOutcome.success,
      ]);
      expect(metrics.map((metric) => metric.requestId).toSet(), hasLength(2));
      for (final metric in metrics) {
        final path =
            metric.operation == StoreRequestOperation.catalog
                ? '/OnlineStore/Catalog'
                : '/Cities/CalculateDeliveryFee';
        expect(metric.requestId, requests[path]!.headers['x-request-id']);
      }
    },
  );

  test(
    'default debug diagnostics do not require Firebase or change the response',
    () async {
      client = ApiClient(sharedPreferences: preferences);
      final result = await http.runWithClient(
        () => client.getData('/OnlineStore/Catalog'),
        () => MockClient((request) async => jsonResponse(request)),
      );
      expect(result.statusCode, 200);
      expect(result.body, {'rows': []});
    },
  );
}
