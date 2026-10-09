import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/widget/custom_snackbar.dart';
import 'package:doctor_bike/core/widget/store_feedback_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() {
    StoreFeedbackNotice.dismissActive();
    Get.reset();
  });

  testWidgets('custom feedback uses the shared success card', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyLocale(),
        locale: const Locale('ar'),
        home: const Scaffold(body: Text('home')),
      ),
    );

    showCustomSnackBar('تم الحفظ', isError: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));

    expect(find.byKey(const Key('store-feedback-card')), findsOneWidget);
    expect(find.text('تمت العملية بنجاح'), findsOneWidget);
    expect(find.text('تم الحفظ'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pump(StoreFeedbackNotice.successDuration);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byKey(const Key('store-feedback-card')), findsNothing);
  });

  testWidgets('action feedback runs its action and closes', (tester) async {
    var actionCount = 0;
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: Text('home'))),
    );

    StoreFeedbackNotice.show(
      title: 'تمت الإضافة',
      message: 'تمت إضافة المنتج إلى السلة.',
      tone: StoreFeedbackTone.success,
      actionLabel: 'عرض السلة',
      onAction: () => actionCount++,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    await tester.tap(find.byKey(const Key('store-feedback-action')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(actionCount, 1);
    expect(find.byKey(const Key('store-feedback-card')), findsNothing);
  });

  testWidgets('action feedback disappears when no action is selected', (
    tester,
  ) async {
    var actionCount = 0;
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: Text('home'))),
    );

    StoreFeedbackNotice.show(
      title: 'تمت الإضافة',
      message: 'تمت إضافة المنتج إلى المفضلة.',
      tone: StoreFeedbackTone.success,
      actionLabel: 'عرض المفضلة',
      onAction: () => actionCount++,
      duration: const Duration(milliseconds: 500),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));

    expect(actionCount, 0);
    expect(find.byKey(const Key('store-feedback-card')), findsNothing);
  });
}
