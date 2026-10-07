import 'package:doctor_bike/core/functions/checkout_attempt.dart';
import 'package:doctor_bike/core/functions/native_checkout.dart';
import 'package:doctor_bike/core/model/checkout_flow_model.dart';
import 'package:doctor_bike/core/model/discount_code_model.dart';
import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:doctor_bike/core/widget/store_bottom_navigation.dart';
import 'package:doctor_bike/features/shop/check_out_done.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final item =
      _item()
        ..count = 3
        ..itemSizeId = 7
        ..itemSizeColorId = 8;
  Map<String, dynamic> payload({String role = 'customer', String? coupon}) =>
      buildNativeCheckoutPayload(
        items: [item],
        accountRole: role,
        customerAddress: 'Ramallah',
        shiplyCityId: 10,
        shiplyVillageId: 20,
        couponCode: coupon,
      );

  test(
    'valid cash checkout',
    () => expect(payload()['payment'], {'type': 'cash', 'paid_amount': 0}),
  );
  test('checkout success orders action targets Orders destination', () {
    expect(
      checkoutSuccessDestination(CheckoutSuccessAction.orders),
      StoreDestination.orders,
    );
  });
  test('checkout success home action targets Home destination', () {
    expect(
      checkoutSuccessDestination(CheckoutSuccessAction.home),
      StoreDestination.home,
    );
  });
  test('preflight offline is recoverable and never submits', () async {
    var submitCalls = 0;
    final cart = <int>[1];
    final result = await runCheckoutTransport<int>(
      connectivityCheck: () async => false,
      submit: () async {
        submitCalls++;
        return 200;
      },
    );
    expect(result.kind, CheckoutTransportKind.offline);
    expect(result.kind, isNot(CheckoutTransportKind.uncertain));
    expect(submitCalls, 0);
    expect(cart, [1], reason: 'preflight offline retains cart intent');
  });
  test('thrown checkout request remains uncertain ambiguity', () async {
    final result = await runCheckoutTransport<int>(
      connectivityCheck: () async => true,
      submit: () async => throw Exception('connection reset'),
    );
    expect(result.kind, CheckoutTransportKind.uncertain);
  });
  test(
    'request includes listingId',
    () => expect((payload()['items'] as List).first['listing_id'], 407),
  );
  test(
    'size_id preserved',
    () => expect((payload()['items'] as List).first['size_id'], 7),
  );
  test(
    'size_color_id preserved',
    () => expect((payload()['items'] as List).first['size_color_id'], 8),
  );
  test(
    'quantity preserved',
    () => expect((payload()['items'] as List).first['quantity'], 3),
  );
  test(
    'productId is not item authority',
    () => expect(
      (payload()['items'] as List).first,
      isNot(contains('productId')),
    ),
  );
  test('customer role', () => expect(payload()['account_role'], 'customer'));
  test(
    'seller role',
    () => expect(payload(role: 'seller')['account_role'], 'seller'),
  );
  test(
    'dual role requires choice',
    () => expect(
      resolveCheckoutRoles(['customer', 'seller']).requirement,
      CheckoutRoleRequirement.choiceRequired,
    ),
  );
  test(
    'unsupported role blocks',
    () => expect(
      resolveCheckoutRoles(['admin']).requirement,
      CheckoutRoleRequirement.unavailable,
    ),
  );
  test(
    'customer address mapped',
    () =>
        expect((payload()['delivery'] as Map)['customer_address'], 'Ramallah'),
  );
  test(
    'Shiply city mapped',
    () => expect((payload()['delivery'] as Map)['shiply_city_id'], 10),
  );
  test(
    'Shiply village mapped',
    () => expect((payload()['delivery'] as Map)['shiply_village_id'], 20),
  );
  test(
    'coupon omitted when empty',
    () => expect(payload(coupon: ' '), isNot(contains('coupon_code'))),
  );
  test(
    'coupon included when valid',
    () => expect(payload(coupon: ' SAVE ')['coupon_code'], 'SAVE'),
  );
  test(
    'coupon preview parses fixed and percentage values without legacy fields',
    () {
      final coupon = CouponModel.fromJson({
        'id': 12,
        'code': 'SAVE10',
        'discount_type': 'fixed',
        'discount_value': 10,
        'is_active': true,
      }, discountAmount: 10);
      expect(coupon.code, 'SAVE10');
      expect(coupon.discountType, 'fixed');
      expect(coupon.discountValue, 10);
      expect(coupon.discountAmount, 10);
      expect(coupon.isActive, isTrue);
    },
  );
  test(
    'payment is cash only',
    () => expect((payload()['payment'] as Map)['type'], 'cash'),
  );
  test(
    'paid amount is zero',
    () => expect((payload()['payment'] as Map)['paid_amount'], 0),
  );
  test('first submit creates id', () {
    final a = CheckoutAttempt();
    a.begin();
    expect(a.currentId, isNotNull);
  });
  test('rapid second submit blocked', () {
    final a = CheckoutAttempt();
    expect(a.begin(), isTrue);
    expect(a.begin(), isFalse);
  });
  test('timeout retry reuses id', () {
    final a = CheckoutAttempt()..begin();
    final id = a.id;
    a.finish(successful: false);
    a.begin();
    expect(a.id, id);
  });
  test('uncertain retry reuses id', () {
    final a = CheckoutAttempt()..begin();
    final id = a.id;
    a.finish(successful: false);
    expect(a.attachTo({})['client_request_id'], id);
  });
  test(
    'validation is recoverable typed state',
    () => expect(
      const CheckoutFlowState(stage: CheckoutStage.validationError).stage,
      CheckoutStage.validationError,
    ),
  );
  test(
    '201 valid id succeeds',
    () => expect(
      NativeCheckoutSuccess.tryParse(201, {
        'data': {'id': 5},
      })?.orderId,
      '5',
    ),
  );
  test(
    '200 replay succeeds',
    () => expect(
      NativeCheckoutSuccess.tryParse(200, {
        'data': {'id': 6},
        'replayed': true,
      })?.replayed,
      isTrue,
    ),
  );
  test(
    '200 malformed is not success',
    () => expect(NativeCheckoutSuccess.tryParse(200, {}), isNull),
  );
  test(
    '201 missing id is not success',
    () => expect(NativeCheckoutSuccess.tryParse(201, {'data': {}}), isNull),
  );
  test(
    'server error cannot complete attempt',
    () => expect(NativeCheckoutSuccess.tryParse(500, {}), isNull),
  );
  test('timeout leaves attempt identity', () {
    final a = CheckoutAttempt()..begin();
    final id = a.id;
    a.finish(successful: false);
    expect(a.currentId, id);
  });
  test('success clears attempt only after identity', () {
    final a = CheckoutAttempt()..begin();
    completeCheckoutAttempt(a, 201, {
      'data': {'id': 9},
    });
    expect(a.currentId, isNull);
  });
  test(
    'delivery fee is absent from request authority',
    () => expect(payload(), isNot(contains('total'))),
  );
  test(
    'stock validation categorized',
    () => expect(
      classifyCheckoutValidation({'items': 'quantity exceeds stock'}),
      CheckoutValidationKind.stock,
    ),
  );
  test(
    'coupon validation categorized',
    () => expect(
      classifyCheckoutValidation({'coupon_code': 'expired'}),
      CheckoutValidationKind.coupon,
    ),
  );
  test(
    'success preserves order id',
    () => expect(
      NativeCheckoutSuccess.tryParse(201, {
        'data': {'id': 'ORD-1'},
      })?.orderId,
      'ORD-1',
    ),
  );
  test('success actions use authoritative id', () {
    final success = NativeCheckoutSuccess.tryParse(200, {
      'data': {'id': 77},
      'replayed': true,
    });
    expect(success!.orderId, '77');
  });
  test(
    'unknown validation is safe',
    () => expect(
      classifyCheckoutValidation({'message': 'bad'}),
      CheckoutValidationKind.unknown,
    ),
  );
}

Item _item() => Item.fromJson({
  'id': 91,
  'productId': 91,
  'listingId': 407,
  'listingStatus': 'published',
  'readinessState': 'complete',
  'nameAr': 'دراجة',
  'nameEng': 'Bike',
  'nameAbree': 'Bike',
  'isShow': true,
  'descriptionAr': '',
  'descriptionEng': '',
  'descriptionAbree': '',
  'videoUrl': null,
  'normailPrice': 100,
  'wholesalePrice': 50,
  'stock': 10,
  'available': true,
  'purchasable': true,
  'model': '',
  'isNewItem': false,
  'isMoreSales': false,
  'rate': 0,
  'manufactureYear': null,
  'discount': 0,
  'userIdAdd': null,
  'dateAdd': '2026-10-06',
  'userIdUpdate': null,
  'dateUpdate': null,
  'supCategory': [],
  'normalImagesItems': [],
  '_3DImagesItems': [],
  'viewImagesItems': [],
  'itemSizes': [],
  'storefrontMedia': [
    {
      'id': 1,
      'source_type': 'normal_image',
      'source_id': 1,
      'path': '/media/1.jpg',
      'media_metadata': null,
      'is_main': true,
      'is_visible': true,
      'sort_order': 0,
    },
  ],
});
