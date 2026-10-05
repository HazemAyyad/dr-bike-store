import 'dart:io';

import 'package:doctor_bike/controller/LocalizationController.dart';
import 'package:doctor_bike/core/constants/app_constants.dart';
import 'package:doctor_bike/features/splash/splash.dart';
import 'package:doctor_bike/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory storageDirectory;

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({
      AppConstants.LANGUAGE_CODE: 'ar',
      AppConstants.COUNTRY_CODE: 'SA',
      AppConstants.FirstLog: true,
    });
    final preferences = await SharedPreferences.getInstance();
    storageDirectory = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'doctor-bike-store-widget-test',
    );
    await storageDirectory.create(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (_) async => storageDirectory.path,
        );
    await GetStorage.init();
    await GetStorage().erase();
    Get.put(
      LocalizationController(sharedPreferences: preferences),
      permanent: true,
    );
  });

  tearDown(() async {
    await GetStorage().erase();
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  testWidgets('Store app bootstrap builds the configured initial route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(GetMaterialApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
