import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../model/notification_model.dart';

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

class NotificationRouteResolver {
  const NotificationRouteResolver._();

  static NotificationRouteTarget? resolve(Map<String, dynamic> data) {
    final destination = NotificationDestination.fromJson(data);
    if (destination == null) return null;
    return switch (destination.type) {
      NotificationDestinationType.order => NotificationOrderTarget(
        destination.id,
      ),
      NotificationDestinationType.product => NotificationProductTarget(
        destination.id,
      ),
      NotificationDestinationType.unknown => null,
    };
  }
}

class NotificationApi {
  NotificationApi._();
  static final NotificationApi instance = NotificationApi._();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    await setupFlutterNotifications();
    FirebaseMessaging.onMessage.listen(showNotification);
  }

  Future<void> setupFlutterNotifications() async {
    if (_initialized) return;
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload == null) return;
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            NotificationRouteResolver.resolve(
              Map<String, dynamic>.from(decoded),
            );
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
    if (notification == null) return;
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationRouteResolver.resolve(message.data);
  await NotificationApi.instance.setupFlutterNotifications();
  await NotificationApi.instance.showNotification(message);
}
