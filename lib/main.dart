import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/check_account/account_service.dart';
import 'core/functions/notification_api.dart';
import 'core/functions/store_product_link_service.dart';
import 'core/helper/get_di.dart';
import 'firebase_options.dart';
import 'my_app.dart';

void main() async {
  // Initialize controller
  WidgetsFlutterBinding.ensureInitialized();
  final productLinks = Get.put(StoreProductLinkService(), permanent: true);
  await productLinks.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationApi.instance.initialize();
  await Get.putAsync(() async => ApiService());
  await Get.putAsync<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
    permanent: true,
  );
  await GetStorage.init();
  // if (kReleaseMode) ErrorWidget.builder = (_) => const AppErrorWidget();
  await init();
  runApp(MyApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationApi.instance.flushPending();
  });
}
