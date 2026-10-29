import 'dart:io';
import 'dart:ui' as ui;

import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/theme/light.dart';
import 'package:doctor_bike/core/theme/store_colors.dart';
import 'package:doctor_bike/core/theme/store_tokens.dart';
import 'package:doctor_bike/core/theme/store_typography.dart';
import 'package:doctor_bike/features/acount/payment_methods_screen.dart';
import 'package:doctor_bike/features/support/presentation/store_support_home_screen.dart';
import 'package:doctor_bike/features/support/presentation/store_support_controller.dart';
import 'package:doctor_bike/features/support/data/store_support_repository.dart';
import 'package:doctor_bike/core/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(StoreTypography.fontFamily)
      ..addFont(rootBundle.load('assets/font/Cairo-Variable.ttf'))).load();
    await (FontLoader('NotoSansHebrew')..addFont(
      rootBundle.load('assets/font/NotoSansHebrew-Variable.ttf'),
    )).load();
    await (FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  tearDown(Get.reset);

  for (final language in ['ar', 'en', 'he']) {
    for (final night in [false, true]) {
      testWidgets('support inbox in $language dark=$night fits large text', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final controller = Get.put(
          StoreSupportController(
            repository: StoreSupportRepository(
              apiClient: ApiClient(sharedPreferences: preferences),
            ),
          ),
        );
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          GetMaterialApp(
            translations: MyLocale(),
            locale: Locale(language),
            theme: night ? dark() : light(),
            supportedLocales: const [Locale('ar'), Locale('en'), Locale('he')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.6)),
                  child: child!,
                ),
            home: const StoreSupportHomeScreen(embedded: true),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('محادثة جديدة'.tr), findsOneWidget);
        expect(tester.takeException(), isNull);
        controller.error = 'storeSupportReadError'.tr;
        controller.update();
        await tester.pumpAndSettle();
        expect(find.text('storeSupportReadError'.tr), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
      testWidgets('payment copy fits $language with dark=$night and large text', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        await tester.pumpWidget(
          GetMaterialApp(
            translations: MyLocale(),
            locale: Locale(language),
            supportedLocales: const [Locale('ar'), Locale('en'), Locale('he')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: night ? dark() : light(),
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.6)),
                  child: child!,
                ),
            home: RepaintBoundary(
              key: key,
              child: const PaymentMethodsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(MyLocale().keys[language]!['طرق الدفع']!),
          findsOneWidget,
        );
        final context = tester.element(find.byType(PaymentMethodsScreen));
        expect(
          Directionality.of(context),
          language == 'en' ? TextDirection.ltr : TextDirection.rtl,
        );
        final foreground = StoreColors.resolve(
          context,
          StorePalette.textPrimary,
        );
        final surface = StoreColors.resolve(context, StorePalette.surface);
        final contrast =
            (foreground.computeLuminance() + .05) /
            (surface.computeLuminance() + .05);
        expect(
          contrast > 1 ? contrast : 1 / contrast,
          greaterThanOrEqualTo(4.5),
        );
        expect(tester.takeException(), isNull);
        if (Platform.environment['STORE_EXPORT_VISUALS'] == 'true') {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final picture = await boundary.toImage();
            final bytes = await picture.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'build/store-review/payment-$language-${night ? 'dark' : 'light'}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            picture.dispose();
          });
        }
      });
    }
  }
}
