import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/categores/categores_controller.dart';
import '../../controller/order/order_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../firebase_options.dart';
import '../helper/route_helper.dart';
import '../model/notification_model.dart';
import 'app_usage_service.dart';

sealed class NotificationRouteTarget {
  const NotificationRouteTarget();
}

class NotificationOrderTarget extends NotificationRouteTarget {
  const NotificationOrderTarget(this.orderId);
  final int orderId;
}

class NotificationProductTarget extends NotificationRouteTarget {
  const NotificationProductTarget(this.productId);
  final int productId;
}

class NotificationCategoryTarget extends NotificationRouteTarget {
  const NotificationCategoryTarget(this.categoryId);
  final int categoryId;
}

class NotificationSupportTarget extends NotificationRouteTarget {
  const NotificationSupportTarget(this.conversationId);
  final int conversationId;
}

class NotificationUrlTarget extends NotificationRouteTarget {
  const NotificationUrlTarget(this.url);
  final String url;
}

class NotificationHomeTarget extends NotificationRouteTarget {
  const NotificationHomeTarget();
}

class NotificationRouteResolver {
  const NotificationRouteResolver._();

  static NotificationRouteTarget? resolve(Map<String, dynamic> data) {
    final destination = NotificationDestination.fromJson(data);
    if (destination == null) return null;
    return switch (destination.type) {
      NotificationDestinationType.order => NotificationOrderTarget(
        destination.id!,
      ),
      NotificationDestinationType.product => NotificationProductTarget(
        destination.id!,
      ),
      NotificationDestinationType.category => NotificationCategoryTarget(
        destination.id!,
      ),
      NotificationDestinationType.support => NotificationSupportTarget(
        destination.id!,
      ),
      NotificationDestinationType.url => NotificationUrlTarget(
        destination.url!,
      ),
      NotificationDestinationType.home => const NotificationHomeTarget(),
      NotificationDestinationType.unknown => null,
    };
  }
}

class NotificationApi {
  NotificationApi._();
  static final NotificationApi instance = NotificationApi._();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Map<String, dynamic>? _pendingOpenData;

  Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    await setupFlutterNotifications();
    FirebaseMessaging.onMessage.listen(showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      unawaited(openData(message.data));
    });
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _pendingOpenData = initial.data;
  }

  Future<void> setupFlutterNotifications() async {
    if (_initialized) return;
    const channel = AndroidNotificationChannel(
      'dr_bike_store_notifications',
      'إشعارات متجر دكتور بايك',
      description: 'العروض والإعلانات وتحديثات الطلبات',
      importance: Importance.high,
      enableVibration: true,
      showBadge: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload == null) return;
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            unawaited(openData(Map<String, dynamic>.from(decoded)));
          }
        } catch (_) {
          // Invalid and unknown payloads intentionally do not navigate.
        }
      },
    );
    _initialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if (title == null || title.trim().isEmpty) return;
    await _localNotifications.show(
      message.messageId?.hashCode ?? message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'dr_bike_store_notifications',
          'إشعارات متجر دكتور بايك',
          channelDescription: 'العروض والإعلانات وتحديثات الطلبات',
          icon: 'ic_notification',
          color: const Color(0xFF6B65BD),
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
          styleInformation: BigTextStyleInformation(
            body ?? '',
            contentTitle: title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> flushPending() async {
    final data = _pendingOpenData;
    _pendingOpenData = null;
    if (data != null) await openData(data);
  }

  Future<void> openData(Map<String, dynamic> data) async {
    final target = NotificationRouteResolver.resolve(data);
    if (target == null) return;
    if (Get.key.currentState == null) {
      _pendingOpenData = data;
      return;
    }
    switch (target) {
      case NotificationHomeTarget():
        await Get.offAllNamed(RouteHelper.homePage);
        return;
      case NotificationOrderTarget(:final orderId):
        if (!Get.isRegistered<OrderController>()) {
          await Get.toNamed(RouteHelper.ordersScreen);
          return;
        }
        final orders = Get.find<OrderController>();
        await orders.load();
        final order = orders.orders.firstWhereOrNull(
          (row) => row.id == orderId,
        );
        if (order == null) {
          await Get.toNamed(RouteHelper.ordersScreen);
        } else {
          orders.selectOrder(order);
          await Get.toNamed(RouteHelper.orderDetailsScreen, arguments: order);
        }
        return;
      case NotificationProductTarget(:final productId):
        if (Get.isRegistered<ProductControllerImp>()) {
          await Get.find<ProductControllerImp>().getCategoryById(
            itemId: productId,
          );
        }
        return;
      case NotificationCategoryTarget(:final categoryId):
        if (Get.isRegistered<CategoresControllerImp>()) {
          await Get.find<CategoresControllerImp>()
              .getProductsByOnlineStoreCategory(categoryId);
        }
        return;
      case NotificationSupportTarget(:final conversationId):
        if (!await AppUsageService.getIsLogin()) {
          await Get.toNamed(RouteHelper.intoLog);
          return;
        }
        await Get.toNamed(
          RouteHelper.supportConversation,
          arguments: conversationId,
        );
        return;
      case NotificationUrlTarget(:final url):
        final uri = Uri.tryParse(url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
    }
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationApi.instance.setupFlutterNotifications();
}
