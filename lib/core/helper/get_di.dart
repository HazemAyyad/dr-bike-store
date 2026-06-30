import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../controller/LocalizationController.dart';

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);

  // Repository

  // Controller
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  // Get.lazyPut(() => NotificationController());

  // Retrieving localized data
}
