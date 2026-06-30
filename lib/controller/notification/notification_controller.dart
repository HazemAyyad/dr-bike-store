import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  var fcmToken = ''.obs; // Observable variable

  @override
  void onInit() async {
    // await iniNotifications();
    super.onInit();

    getToken();
  }

  // Future<void> iniNotifications() async {
  //   await _firebaseMessaging.requestPermission();
  //   final token = await _firebaseMessaging.getToken();
  //   print("FCM Token:-- $token");
  //   FirebaseMessaging.onBackgroundMessage(handlebackgroundMessage);
  // }

  // Future<void> handlebackgroundMessage(RemoteMessage? message) async {
  //   print('title: ${message!.notification!.title}');
  //   print('title: ${message.notification!.body}');
  //   print('title: ${message.data}');
  // }

  Future<void> getToken() async {
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    // FirebaseMessaging.onBackgroundMessage(handlebackgroundMessage);
    if (token != null) {
      fcmToken.value = token;
    }
  }
}
