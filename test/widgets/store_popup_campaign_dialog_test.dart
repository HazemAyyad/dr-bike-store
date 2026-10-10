import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/model/online_store_home_model.dart';
import 'package:doctor_bike/features/home_screen/widget/store_popup_campaign_dialog.dart';

void main() {
  const campaign = OnlineStorePopupCampaign(
    id: 7,
    imagePath: '',
    titles: {'ar': 'عرض خاص', 'en': 'Special offer'},
    contents: {'ar': 'خصم لفترة محدودة', 'en': 'Limited time discount'},
    buttons: {'ar': 'اكتشف العرض', 'en': 'Explore offer'},
    theme: 'warm',
    actionType: 'none',
  );

  test('popup campaign parses localized action data', () {
    final parsed = OnlineStorePopupCampaign.fromJson({
      'id': 9,
      'image_path': 'images/popup.jpg',
      'title_translations': {'ar': 'أهلاً'},
      'content_translations': {'ar': 'محتوى'},
      'button_translations': {'ar': 'تسوق'},
      'theme': 'success',
      'action_type': 'coupon',
      'action_target_id': 4,
      'coupon_code': 'WELCOME',
    });

    expect(parsed.id, 9);
    expect(parsed.title('ar'), 'أهلاً');
    expect(parsed.actionType, 'coupon');
    expect(parsed.actionTargetId, 4);
    expect(parsed.couponCode, 'WELCOME');
  });

  testWidgets('popup returns action when customer taps its button', (
    tester,
  ) async {
    StorePopupCampaignResult? result;
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        translations: MyLocale(),
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showStorePopupCampaignDialog(
                      context,
                      campaign,
                    );
                  },
                  child: const Text('open'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Special offer'), findsOneWidget);
    expect(find.text('Limited time discount'), findsOneWidget);

    await tester.tap(find.text('Explore offer'));
    await tester.pumpAndSettle();
    expect(result, StorePopupCampaignResult.action);
  });

  testWidgets('popup never falls back to another campaign language', (
    tester,
  ) async {
    const arabicOnly = OnlineStorePopupCampaign(
      id: 8,
      imagePath: '',
      titles: {'ar': 'عرض عربي'},
      contents: {'ar': 'محتوى عربي'},
      buttons: {'ar': 'زر عربي'},
      theme: 'brand',
      actionType: 'none',
    );

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        translations: MyLocale(),
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed:
                      () => showStorePopupCampaignDialog(context, arabicOnly),
                  child: const Text('open'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Special offer'), findsOneWidget);
    expect(find.text('Explore now'), findsOneWidget);
    expect(find.text('Selected for you'), findsOneWidget);
    expect(find.text('Do not show me this advertisement'), findsOneWidget);
    expect(find.text('عرض عربي'), findsNothing);
    expect(find.text('محتوى عربي'), findsNothing);
    expect(find.text('زر عربي'), findsNothing);
  });
}
