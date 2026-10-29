import 'dart:io';
import 'dart:ui' as ui;

import 'package:doctor_bike/controller/categores/categores_controller.dart';
import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/theme/light.dart';
import 'package:doctor_bike/core/theme/store_typography.dart';
import 'package:doctor_bike/features/category/filter_screen.dart';
import 'package:doctor_bike/repository/categories/categories_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    Get.put(await SharedPreferences.getInstance());
  });
  tearDown(Get.reset);

  for (final language in ['ar', 'en', 'he']) {
    for (final night in [false, true]) {
      testWidgets(
        'filter sheet translates and preserves edits: $language dark=$night',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final preferences = Get.find<SharedPreferences>();
          final controller = Get.put<CategoresControllerImp>(
            _FilterController(
              CategoriesRepository(
                apiClient: ApiClient(sharedPreferences: preferences),
              ),
            ),
          );
          final capture = GlobalKey();
          await tester.pumpWidget(
            GetMaterialApp(
              locale: Locale(language),
              translations: MyLocale(),
              theme: night ? dark() : light(),
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
                Locale('he'),
              ],
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
                    child: RepaintBoundary(key: capture, child: child!),
                  ),
              home: Scaffold(
                body: Builder(
                  builder:
                      (context) => TextButton(
                        onPressed:
                            () => showProductFilterSheet(context, controller),
                        child: const Text('open'),
                      ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          final dictionary = MyLocale().keys[language]!;
          final title = find.text(dictionary['تصفية المنتجات']!);
          expect(title, findsOneWidget);
          expect(find.byTooltip(dictionary['إغلاق']!), findsOneWidget);
          expect(
            Directionality.of(tester.element(title)),
            language == 'en' ? TextDirection.ltr : TextDirection.rtl,
          );
          final fields = find.byType(TextField);
          expect(
            tester.widget<TextField>(fields.first).decoration!.labelText,
            dictionary['من'],
          );
          expect(
            tester.widget<TextField>(fields.last).decoration!.labelText,
            dictionary['إلى'],
          );
          final fieldContext = tester.element(fields.first);
          expect(
            tester.widget<TextField>(fields.first).decoration!.fillColor,
            Theme.of(fieldContext).scaffoldBackgroundColor,
          );
          expect(tester.takeException(), isNull);

          if (Platform.environment['STORE_EXPORT_VISUALS'] == 'true') {
            final boundary =
                capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final picture = await boundary.toImage();
              final bytes = await picture.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File(
                'build/store-review/filter-$language-${night ? 'dark' : 'light'}.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              picture.dispose();
            });
          }

          await tester.enterText(fields.first, '20');
          await tester.enterText(fields.last, '80');
          tester.testTextInput.hide();
          await tester.pumpAndSettle();
          final scrollable =
              find
                  .descendant(
                    of: find.byType(ListView),
                    matching: find.byType(Scrollable),
                  )
                  .first;
          final available = find.text(
            dictionary['المنتجات المتاحة للشراء فقط']!,
          );
          await tester.scrollUntilVisible(
            available,
            70,
            scrollable: scrollable,
          );
          await tester.pumpAndSettle();
          await tester.tap(available);
          final offers = find.text(dictionary['العروض والخصومات فقط']!);
          await tester.scrollUntilVisible(offers, 70, scrollable: scrollable);
          await tester.pumpAndSettle();
          await tester.tap(offers);
          await tester.tap(find.text(dictionary['تطبيق الفلاتر']!));
          await tester.pumpAndSettle();
          expect(controller.filters.value.minimumPrice, 20);
          expect(controller.filters.value.maximumPrice, 80);
          expect(controller.filters.value.availableOnly, isTrue);
          expect(controller.filters.value.onSale, isTrue);
          expect(title, findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

class _FilterController extends CategoresControllerImp {
  _FilterController(CategoriesRepository repository)
    : super(categoriesRepository: repository);

  @override
  Future<void> applyCatalogFilters(CatalogFilters value) async {
    filters.value = value;
  }
}
