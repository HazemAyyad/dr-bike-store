import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../core/classes/store_view_state.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/model/notification_model.dart';
import '../../repository/home/home_repository.dart';

typedef NotificationConnectivity = Future<bool> Function();
typedef NotificationIdentityLoader = Future<String?> Function();

class NotificationController extends GetxController {
  NotificationController({
    required this.repository,
    NotificationConnectivity? connectivityCheck,
    NotificationIdentityLoader? userIdLoader,
    FirebaseMessaging? messaging,
    this.initializePush = true,
  }) : _connectivityCheck =
           connectivityCheck ??
           (() async => await CheckInternet.checkInternet() == true),
       _userIdLoader = userIdLoader ?? AppUsageService.getUserId,
       _messaging = messaging;

  final HomeDataSource repository;
  final NotificationConnectivity _connectivityCheck;
  final NotificationIdentityLoader _userIdLoader;
  final FirebaseMessaging? _messaging;
  final bool initializePush;

  final fcmToken = ''.obs;
  StoreViewState<List<NotificationItem>> inboxState = const StoreInitial();
  final markingReadIds = <int>{};
  List<NotificationItem> notifications = const [];

  int get unreadCount => notifications.where((item) => !item.isRead).length;
  List<NotificationCategory> get availableCategories {
    final supported =
        notifications
            .map((item) => item.category)
            .where((category) => category != NotificationCategory.unknown)
            .toSet();
    return supported.toList(growable: false);
  }

  Future<void> load({bool refresh = false}) async {
    final userId = await _userIdLoader();
    if (userId == null || userId.trim().isEmpty) {
      notifications = const [];
      inboxState = const StoreError(message: 'storeLoginRequired');
      update();
      return;
    }
    if (!await _connectivityCheck()) {
      inboxState = StoreOffline(
        message: 'storeOfflineMessage',
        previousData: notifications.isEmpty ? null : notifications,
      );
      update();
      return;
    }
    inboxState = StoreLoading(
      previousData: refresh && notifications.isNotEmpty ? notifications : null,
    );
    update();
    try {
      final response = await repository.getNotification();
      if (response.statusCode != 200 || response.body is! Map) {
        throw const FormatException('notification response');
      }
      final parsed =
          NotificationResponse.fromJson(
            Map<String, dynamic>.from(response.body as Map),
          ).rows;
      notifications = parsed;
      inboxState =
          parsed.isEmpty
              ? const StoreEmpty(message: 'storeNoNotifications')
              : StoreContent(parsed);
    } catch (_) {
      inboxState = StoreError(
        message: 'storeGenericError',
        previousData: notifications.isEmpty ? null : notifications,
      );
    }
    update();
  }

  Future<bool> markRead(NotificationItem item) async {
    if (item.isRead) return true;
    if (!markingReadIds.add(item.id)) return false;
    update();
    try {
      final response = await repository.postNotificationIsRead(item.id);
      if (response.statusCode != 200 || !_isAcceptedMutation(response.body)) {
        return false;
      }
      final index = notifications.indexWhere(
        (candidate) => candidate.id == item.id,
      );
      if (index < 0) return false;
      final updated = List<NotificationItem>.from(notifications);
      updated[index] = updated[index].copyWith(isRead: true);
      notifications = updated;
      inboxState = StoreContent(updated);
      return true;
    } catch (_) {
      return false;
    } finally {
      markingReadIds.remove(item.id);
      update();
    }
  }

  bool _isAcceptedMutation(dynamic body) {
    if (body is! Map) return false;
    return body['isSuccess'] == true && body['isFailure'] != true;
  }

  Future<void> getToken() async {
    final messaging = _messaging ?? FirebaseMessaging.instance;
    await messaging.requestPermission();
    fcmToken.value = await messaging.getToken() ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    if (initializePush) getToken();
  }
}
