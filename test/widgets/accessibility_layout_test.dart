import 'package:doctor_bike/core/widget/store_bottom_navigation.dart';
import 'package:doctor_bike/core/widget/store_media.dart';
import 'package:doctor_bike/core/widget/store_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget app({required Locale locale, required Widget child, double scale = 1}) =>
    GetMaterialApp(
      locale: locale,
      home: Directionality(
        textDirection:
            locale.languageCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(scale),
            padding: const EdgeInsets.only(top: 24, bottom: 20),
          ),
          child: Scaffold(body: SafeArea(child: child)),
        ),
      ),
    );

void main() {
  testWidgets('Arabic and Hebrew are RTL while English is LTR', (tester) async {
    for (final locale in const <Locale>[Locale('ar'), Locale('he')]) {
      await tester.pumpWidget(
        app(
          locale: locale,
          child: Builder(
            builder: (context) => Text(Directionality.of(context).name),
          ),
        ),
      );
      expect(find.text('rtl'), findsOneWidget);
    }
    await tester.pumpWidget(
      app(
        locale: const Locale('en'),
        child: Builder(
          builder: (context) => Text(Directionality.of(context).name),
        ),
      ),
    );
    expect(find.text('ltr'), findsOneWidget);
  });

  testWidgets('mixed and long titles survive narrow large-text viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    await tester.pumpWidget(
      app(
        locale: const Locale('ar'),
        scale: 1.6,
        child: ListView(
          children: const [
            Text('دراجة Doctor Bike X200'),
            Text(
              'عنوان عربي طويل جدًا لاختبار الالتفاف والوصول عند تكبير النص',
            ),
            Text(
              'A very long English product title that must remain reachable',
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('media fallback and navigation actions are semantic', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        locale: const Locale('ar'),
        child: Column(
          children: [
            const Expanded(
              child: StoreMediaPlaceholder(message: 'صورة المنتج غير متاحة'),
            ),
            StoreBottomNavigation(
              current: StoreDestination.home,
              onSelected: (_) {},
            ),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('صورة المنتج غير متاحة'), findsOneWidget);
    expect(find.bySemanticsLabel('storeNavOrders'), findsOneWidget);
    expect(find.bySemanticsLabel('storeNavProfile'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'safe area and large text keep destructive confirmation explicit',
    (tester) async {
      await tester.pumpWidget(
        app(
          locale: const Locale('ar'),
          scale: 1.3,
          child: const StoreMessageState(
            kind: StoreMessageKind.error,
            title: 'تأكيد حذف الحساب',
            message: 'لن يتم حذف الجلسة قبل قبول الخادم',
          ),
        ),
      );
      expect(find.text('تأكيد حذف الحساب'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('تأكيد حذف الحساب')).dy,
        greaterThanOrEqualTo(24),
      );
    },
  );
}
