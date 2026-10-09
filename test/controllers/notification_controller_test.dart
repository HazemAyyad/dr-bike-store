import 'dart:async';

import 'package:doctor_bike/controller/notification/notification_controller.dart';
import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/functions/notification_api.dart';
import 'package:doctor_bike/core/model/notification_model.dart';
import 'package:doctor_bike/repository/home/home_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  Map<String, dynamic> row({
    int id = 7,
    bool read = false,
    String title = 'طلب',
    String content = 'عرض خاص',
    Map<String, dynamic> extra = const {},
  }) => {
    'id': id,
    'isRead': read,
    'title': title,
    'content': content,
    'toUser': 'u1',
    'createdAt': '2026-10-06T10:00:00Z',
    'updatedAt': '2026-10-06T11:00:00Z',
    ...extra,
  };

  test(
    'parses required notification identity',
    () => expect(NotificationItem.fromJson(row()).id, 7),
  );
  test(
    'rejects non-positive identity',
    () => expect(
      () => NotificationItem.fromJson(row(id: 0)),
      throwsFormatException,
    ),
  );
  test(
    'preserves isRead',
    () => expect(NotificationItem.fromJson(row(read: true)).isRead, isTrue),
  );
  test('parses title and content safely', () {
    final value = NotificationItem.fromJson(row(title: 'أ', content: 'ب'));
    expect([value.title, value.content], ['أ', 'ب']);
  });
  test(
    'parses timestamps',
    () => expect(NotificationItem.fromJson(row()).createdAt, isNotNull),
  );
  test(
    'malformed timestamps stay null',
    () => expect(
      NotificationItem.fromJson(row(extra: {'createdAt': 'bad'})).createdAt,
      isNull,
    ),
  );
  test(
    'explicit supported category parses',
    () => expect(
      NotificationItem.fromJson(row(extra: {'category': 'order'})).category,
      NotificationCategory.order,
    ),
  );
  test(
    'missing category is unknown',
    () => expect(
      NotificationItem.fromJson(row()).category,
      NotificationCategory.unknown,
    ),
  );
  test(
    'unknown category is unknown',
    () => expect(
      NotificationItem.fromJson(row(extra: {'type': 'other'})).category,
      NotificationCategory.unknown,
    ),
  );
  test(
    'does not infer category from text',
    () => expect(
      NotificationItem.fromJson(row(title: 'تم شحن الطلب')).category,
      NotificationCategory.unknown,
    ),
  );
  test(
    'explicit destination parses',
    () => expect(
      NotificationItem.fromJson(
        row(extra: {'destination_type': 'order', 'destination_id': 9}),
      ).destination?.id,
      9,
    ),
  );
  test(
    'unknown destination is gated',
    () => expect(
      NotificationItem.fromJson(
        row(extra: {'destination_type': 'url', 'destination_id': 9}),
      ).destination,
      isNull,
    ),
  );
  test(
    'malformed destination id is gated',
    () => expect(
      NotificationItem.fromJson(
        row(extra: {'destination_type': 'order', 'destination_id': 0}),
      ).destination,
      isNull,
    ),
  );
  test(
    'known order deep-link allow-list',
    () => expect(
      NotificationRouteResolver.resolve({
        'destination_type': 'order',
        'destination_id': 4,
      }),
      isA<NotificationOrderTarget>(),
    ),
  );
  test(
    'known product deep-link allow-list',
    () => expect(
      NotificationRouteResolver.resolve({
        'destination_type': 'product',
        'destination_id': 4,
      }),
      isA<NotificationProductTarget>(),
    ),
  );
  test(
    'known category deep-link allow-list',
    () => expect(
      NotificationRouteResolver.resolve({
        'destination_type': 'category',
        'destination_id': 12,
      }),
      isA<NotificationCategoryTarget>(),
    ),
  );
  test(
    'home deep-link needs no identifier',
    () => expect(
      NotificationRouteResolver.resolve({'destination_type': 'home'}),
      isA<NotificationHomeTarget>(),
    ),
  );
  test(
    'safe web URL deep-link is supported',
    () => expect(
      NotificationRouteResolver.resolve({
        'destination_type': 'url',
        'destination_url': 'https://dr-bike.duosparktech.com/store',
      }),
      isA<NotificationUrlTarget>(),
    ),
  );
  test(
    'unknown deep-link has safe fallback',
    () => expect(
      NotificationRouteResolver.resolve({
        'destination_type': 'promotion',
        'destination_id': 4,
      }),
      isNull,
    ),
  );
  test(
    'arbitrary URL is never routed',
    () => expect(
      NotificationRouteResolver.resolve({
        'destination_type': 'https://x.test',
        'destination_id': 4,
      }),
      isNull,
    ),
  );

  group('inbox controller', () {
    late FakeHomeRepository repository;
    late NotificationController controller;
    setUp(() {
      Get.testMode = true;
      repository = FakeHomeRepository();
      controller = NotificationController(
        repository: repository,
        connectivityCheck: () async => true,
        userIdLoader: () async => 'foreign-looking-id',
        initializePush: false,
      );
    });

    test('load exposes loading before completion', () async {
      final pending = Completer<Response>();
      repository.notificationResponse = pending.future;
      final future = controller.load();
      await Future<void>.delayed(Duration.zero);
      expect(
        controller.inboxState,
        isA<StoreLoading<List<NotificationItem>>>(),
      );
      pending.complete(const Response(statusCode: 200, body: {'rows': []}));
      await future;
    });
    test('empty state', () async {
      await controller.load();
      expect(controller.inboxState, isA<StoreEmpty<List<NotificationItem>>>());
    });
    test('content state and unread count', () async {
      repository.rows = [row(), row(id: 8, read: true)];
      await controller.load();
      expect(
        controller.inboxState,
        isA<StoreContent<List<NotificationItem>>>(),
      );
      expect(controller.unreadCount, 1);
    });
    test('offline state avoids repository', () async {
      controller = NotificationController(
        repository: repository,
        connectivityCheck: () async => false,
        userIdLoader: () async => 'u',
        initializePush: false,
      );
      await controller.load();
      expect(
        controller.inboxState,
        isA<StoreOffline<List<NotificationItem>>>(),
      );
      expect(repository.loadCalls, 0);
    });
    test('error state', () async {
      repository.status = 500;
      await controller.load();
      expect(controller.inboxState, isA<StoreError<List<NotificationItem>>>());
    });
    test(
      'real Laravel response marks item read and decrements unread',
      () async {
        repository.rows = [row()];
        await controller.load();
        repository.markCompleter = Future.value(
          const Response(
            statusCode: 200,
            body: {
              'message': 'success',
              'isSuccess': true,
              'error': null,
              'isFailure': false,
            },
          ),
        );
        expect(
          await controller.markRead(controller.notifications.single),
          isTrue,
        );
        expect(repository.marked, [7]);
        expect(controller.unreadCount, 0);
      },
    );
    test('isSuccess false preserves unread', () async {
      repository.rows = [row()];
      await controller.load();
      repository.markCompleter = Future.value(
        const Response(
          statusCode: 200,
          body: {'isSuccess': false, 'isFailure': false},
        ),
      );
      expect(
        await controller.markRead(controller.notifications.single),
        isFalse,
      );
      expect(controller.unreadCount, 1);
    });
    test('isFailure true preserves unread', () async {
      repository.rows = [row()];
      await controller.load();
      repository.markCompleter = Future.value(
        const Response(
          statusCode: 200,
          body: {'isSuccess': true, 'isFailure': true},
        ),
      );
      expect(
        await controller.markRead(controller.notifications.single),
        isFalse,
      );
      expect(controller.notifications.single.isRead, isFalse);
    });
    test('backend failure preserves unread', () async {
      repository.rows = [row()];
      await controller.load();
      repository.markCompleter = Future.value(
        const Response(statusCode: 500, body: {'message': 'no'}),
      );
      expect(
        await controller.markRead(controller.notifications.single),
        isFalse,
      );
      expect(controller.notifications.single.isRead, isFalse);
    });
    test('malformed success preserves unread', () async {
      repository.rows = [row()];
      await controller.load();
      repository.markCompleter = Future.value(const Response(statusCode: 200));
      await controller.markRead(controller.notifications.single);
      expect(controller.notifications.single.isRead, isFalse);
    });
    test('refresh reconciles server truth', () async {
      repository.rows = [row()];
      await controller.load();
      repository.rows = [row(read: true)];
      await controller.load(refresh: true);
      expect(controller.unreadCount, 0);
    });
    test('submitted user id is not a controller authorization field', () async {
      await controller.load();
      expect(repository.loadCalls, 1);
    });
  });
}

class FakeHomeRepository implements HomeDataSource {
  int status = 200;
  int loadCalls = 0;
  List<Map<String, dynamic>> rows = [];
  List<int> marked = [];
  Future<Response>? notificationResponse;
  Future<Response>? markCompleter;
  @override
  Future<Response> getNotification() {
    loadCalls++;
    return notificationResponse ??
        Future.value(Response(statusCode: status, body: {'rows': rows}));
  }

  @override
  Future<Response> postNotificationIsRead(id) {
    marked.add(id as int);
    return markCompleter ??
        Future.value(
          const Response(
            statusCode: 200,
            body: {
              'message': 'success',
              'isSuccess': true,
              'error': null,
              'isFailure': false,
            },
          ),
        );
  }

  @override
  Future<Response> getMainCategories() async => const Response();
  @override
  Future<Response> getOnlineAds() async => const Response();
  @override
  Future<Response> getAllItemIsMoreSales() async => const Response();
  @override
  Future<Response> search(name, lang) async => const Response();
}
