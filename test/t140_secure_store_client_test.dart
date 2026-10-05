import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/functions/checkout_attempt.dart';
import 'package:doctor_bike/core/functions/native_checkout.dart';
import 'package:doctor_bike/core/functions/store_client_metadata.dart';
import 'package:doctor_bike/core/functions/upgrade_required.dart';
import 'package:doctor_bike/core/model/otp_model.dart';
import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:doctor_bike/core/model/auth_eesponse.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:doctor_bike/repository/shop/shop_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingApiClient extends ApiClient {
  RecordingApiClient(SharedPreferences sharedPreferences)
    : super(sharedPreferences: sharedPreferences);

  String? method;
  String? uri;
  Map<String, dynamic>? sentBody;
  Response response = const Response(statusCode: 200, body: {});

  @override
  Future<Response> postData(
    String uri, {
    Map<String, String>? headers,
    int? timeout,
    dynamic body,
  }) async {
    method = 'POST';
    this.uri = uri;
    sentBody = Map<String, dynamic>.from(body as Map);
    return response;
  }

  @override
  Future<Response> patch(
    String uri, {
    Map<String, String>? headers,
    int? timeout,
    dynamic body,
  }) async {
    method = 'PATCH';
    this.uri = uri;
    sentBody = Map<String, dynamic>.from(body as Map);
    return response;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecordingApiClient apiClient;
  late AuthRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    apiClient = RecordingApiClient(preferences);
    repository = AuthRepository(
      apiClient: apiClient,
      clientMetadata: StoreClientMetadata(
        platform: TargetPlatform.android,
        packageInfoLoader:
            () async => PackageInfo(
              appName: 'Doctor Bike Store',
              packageName: 'com.example.store',
              version: '2.2.1',
              buildNumber: '10',
            ),
      ),
    );
  });

  test('forgot password sends Store metadata and expects no OTP', () async {
    apiClient.response = const Response(
      statusCode: 200,
      body: {'status': 'success', 'message': 'success'},
    );

    final response = await repository.forgotPassword(email: 'a@example.com');
    final model = ForgotPasswordResponse.fromJson(response.body);

    expect(apiClient.uri, '/Auth/ForgotPassword');
    expect(apiClient.sentBody, {
      'Email': 'a@example.com',
      'app': 'store',
      'platform': 'android',
      'current_version': '2.2.1',
      'current_build': 10,
    });
    expect(model.status, 'success');
    expect(apiClient.sentBody, isNot(contains('otp')));
  });

  test('OTP verification sends entered OTP and retains opaque proof', () async {
    apiClient.response = const Response(
      statusCode: 200,
      body: {
        'status': 'success',
        'resetProof': 'opaque.proof.value',
        'message': 'success',
      },
    );

    final response = await repository.verifyForgotPasswordOtp(
      email: 'a@example.com',
      otp: '654321',
    );
    final model = OtpVerificationResponse.fromJson(response.body);

    expect(apiClient.uri, '/Auth/VerifyForgotPasswordOtp');
    expect(apiClient.sentBody?['otp'], '654321');
    expect(model.resetProof, 'opaque.proof.value');
  });

  test('reset sends resetProof and never sends userId', () async {
    await repository.changePasswordToForgot(
      resetProof: 'opaque-proof',
      newPassword: 'new-secret',
      confirmPassword: 'new-secret',
    );

    expect(apiClient.method, 'PATCH');
    expect(apiClient.uri, '/Auth/ChangePasswordToForgot');
    expect(apiClient.sentBody?['resetProof'], 'opaque-proof');
    expect(apiClient.sentBody, isNot(contains('userId')));
  });

  test('HTTP 426 maps to explicit upgrade-required Arabic UX', () {
    const response = Response(
      statusCode: 426,
      body: {
        'status': 'upgrade_required',
        'message':
            'A Store app update is required to reset the password securely.',
        'minimum_build': 10,
      },
    );
    expect(
      upgradeRequiredMessage(response),
      'يجب تحديث التطبيق إلى أحدث إصدار لمتابعة استعادة كلمة المرور.',
    );
    expect(upgradeRequiredMessage(const Response(statusCode: 400)), isNull);
  });

  test('API debug output redacts OTP, proof, and passwords', () async {
    final messages = <String>[];
    final previous = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = previous);

    final request = http.Request(
      'PATCH',
      Uri.parse('https://example.test/Auth/ChangePasswordToForgot'),
    );
    final response = http.Response(
      '{"resetProof":"opaque-proof","otp":"654321","newPassword":"secret"}',
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
    apiClient.handleResponse(response, '/Auth/ChangePasswordToForgot');

    final output = messages.join('\n');
    expect(output, isNot(contains('opaque-proof')));
    expect(output, isNot(contains('654321')));
    expect(output, isNot(contains('secret')));
  });

  test('checkout attempt reuses UUID until success then creates a new one', () {
    final attempt = CheckoutAttempt();
    expect(attempt.begin(), isTrue);
    final first = attempt.id;
    expect(attempt.attachTo({'order': 1})['client_request_id'], first);
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(first),
      isTrue,
    );

    expect(attempt.begin(), isFalse, reason: 'in-flight taps are coalesced');
    expect(attempt.id, first);
    attempt.finish(successful: false);
    expect(attempt.begin(), isTrue);
    expect(attempt.id, first, reason: 'transport retries reuse the ID');

    attempt.finish(successful: true);
    expect(attempt.begin(), isTrue);
    expect(attempt.id, isNot(first));
  });

  test(
    'rapid duplicate submission executes once and retry keeps identity',
    () async {
      final attempt = CheckoutAttempt();
      final submittedIds = <String>[];

      Future<void> submit({required bool successful}) async {
        if (!attempt.begin()) return;
        submittedIds.add(attempt.id);
        await Future<void>.delayed(Duration.zero);
        attempt.finish(successful: successful);
      }

      final first = submit(successful: false);
      final duplicate = submit(successful: false);
      await Future.wait([first, duplicate]);

      expect(submittedIds, hasLength(1));
      final retainedId = submittedIds.single;

      await submit(successful: false);
      expect(submittedIds, [retainedId, retainedId]);

      await submit(successful: true);
      await submit(successful: false);
      expect(submittedIds.last, isNot(retainedId));
    },
  );

  test('Item persists listingId through cart serialization', () {
    final item = Item.fromJson(_itemJson(productId: 91, listingId: 407));
    final restored = Item.fromJson2(item.toJson());

    expect(item.id, 91);
    expect(item.listingId, 407);
    expect(restored.id, 91);
    expect(restored.listingId, 407);
  });

  test('native checkout blocks cart rows without a listingId', () {
    final item = Item.fromJson(_itemJson(productId: 91));

    expect(
      () => buildNativeCheckoutPayload(
        items: [item],
        accountRole: 'customer',
        customerAddress: 'Ramallah',
        shiplyCityId: 10,
        shiplyVillageId: 20,
      ),
      throwsA(isA<MissingListingIdException>()),
    );
  });

  test('native checkout payload uses listing identity and COD contract', () {
    final item = Item.fromJson(_itemJson(productId: 91, listingId: 407))
      ..count = 3;
    item.itemSizeId = 7;
    item.itemSizeColorId = 8;

    final attempt = CheckoutAttempt()..begin();
    final payload = attempt.attachTo(
      buildNativeCheckoutPayload(
        items: [item],
        accountRole: 'seller',
        customerAddress: 'Ramallah',
        shiplyCityId: 10,
        shiplyVillageId: 20,
        couponCode: ' SAVE10 ',
      ),
    );

    expect(payload['client_request_id'], matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(payload['account_role'], 'seller');
    expect(payload['payment'], {'type': 'cash', 'paid_amount': 0});
    expect(payload['coupon_code'], 'SAVE10');
    expect(payload['delivery'], {
      'customer_address': 'Ramallah',
      'shiply_city_id': 10,
      'shiply_village_id': 20,
    });
    expect(payload['items'], [
      {'listing_id': 407, 'size_id': 7, 'size_color_id': 8, 'quantity': 3},
    ]);
    expect((payload['items'] as List).first['listing_id'], isNot(item.id));
    expect(payload, isNot(contains('details')));
  });

  test('login and profile user models retain accountRoles', () {
    final login = AuthResponse.fromJson({
      'user': _userJson(accountRoles: ['customer', 'seller']),
      'token': 'token',
    });
    final profile = UserModel.fromJson(
      _userJson(accountRoles: ['seller'], typeUser: 'User'),
    );

    expect(login.user.accountRoles, ['customer', 'seller']);
    expect(login.toJson()['user']['accountRoles'], ['customer', 'seller']);
    expect(profile.accountRoles, ['seller']);
    expect(profile.toJson()['accountRoles'], ['seller']);
    expect(UserModel.fromJson(_userJson()).accountRoles, isEmpty);
  });

  test('authoritative account roles resolve single, dual, and unavailable', () {
    final customer = resolveCheckoutRoles(['customer']);
    final seller = resolveCheckoutRoles(['seller']);
    final none = resolveCheckoutRoles([]);
    final dual = resolveCheckoutRoles(['seller', 'customer']);

    expect(customer.role, 'customer');
    expect(seller.role, 'seller');
    expect(none.requirement, CheckoutRoleRequirement.unavailable);
    expect(dual.requirement, CheckoutRoleRequirement.choiceRequired);
    expect(dual.role, isNull, reason: 'dual role must never default');
    expect(confirmCheckoutRole(dual, 'customer'), 'customer');
    expect(confirmCheckoutRole(dual, 'seller'), 'seller');
  });

  test('unknown roles never grant checkout access', () {
    expect(
      resolveCheckoutRoles(['admin']).requirement,
      CheckoutRoleRequirement.unavailable,
    );
    expect(resolveCheckoutRoles(['admin', 'seller']).role, 'seller');
  });

  test('canceled dual-role choice creates no UUID and keeps cart intact', () {
    final cart = [Item.fromJson(_itemJson(productId: 91, listingId: 407))];
    final attempt = CheckoutAttempt();
    final resolution = resolveCheckoutRoles(['customer', 'seller']);

    expect(confirmCheckoutRole(resolution, null), isNull);
    expect(attempt.currentId, isNull);
    expect(cart, hasLength(1));
    expect(cart.single.listingId, 407);
  });

  test('typeUser cannot influence native checkout account_role', () {
    final item = Item.fromJson(_itemJson(productId: 91, listingId: 407));
    final user = UserModel.fromJson(
      _userJson(accountRoles: ['seller'], typeUser: 'User'),
    );
    final role = resolveCheckoutRoles(user.accountRoles).role!;
    final payload = buildNativeCheckoutPayload(
      items: [item],
      accountRole: role,
      customerAddress: 'Ramallah',
      shiplyCityId: 10,
      shiplyVillageId: 20,
    );

    expect(user.typeUser, 'User');
    expect(payload['account_role'], 'seller');
  });

  test('ShopRepository submits native checkout endpoint unchanged', () async {
    final payload = {'client_request_id': 'request-id', 'items': <Object>[]};
    await ShopRepository(apiClient: apiClient).createOrder(body: payload);

    expect(apiClient.uri, '/OnlineStore/Checkout');
    expect(apiClient.sentBody, payload);
  });

  test('201 create and 200 replay read data.id and clear attempt', () {
    for (final status in [201, 200]) {
      final attempt = CheckoutAttempt();
      attempt.begin();
      final previousId = attempt.id;
      final success = completeCheckoutAttempt(attempt, status, {
        'data': {'id': status == 201 ? 501 : 502},
        'replayed': status == 200,
      });

      expect(success?.orderId, status == 201 ? '501' : '502');
      expect(success?.replayed, status == 200);
      attempt.begin();
      expect(attempt.id, isNot(previousId));
    }
  });

  test('malformed success retains UUID for safe idempotent retry', () {
    final attempt = CheckoutAttempt();
    attempt.begin();
    final id = attempt.id;

    expect(completeCheckoutAttempt(attempt, 201, {'replayed': false}), isNull);
    attempt.finish(successful: false);
    attempt.begin();
    expect(attempt.id, id);
  });

  test('transport retry keeps UUID through a 200 replay', () {
    final attempt = CheckoutAttempt();
    attempt.begin();
    final first = attempt.id;
    attempt.finish(successful: false);

    attempt.begin();
    expect(attempt.id, first);
    final replay = completeCheckoutAttempt(attempt, 200, {
      'data': {'id': 777},
      'replayed': true,
    });
    expect(replay?.orderId, '777');

    attempt.begin();
    expect(attempt.id, isNot(first));
  });

  test('missing reset proof is rejected before loading can begin', () {
    expect(missingResetProofMessage(null), isNotNull);
    expect(missingResetProofMessage(''), isNotNull);
    expect(missingResetProofMessage('opaque-proof'), isNull);
  });
}

Map<String, dynamic> _itemJson({required int productId, int? listingId}) => {
  'id': productId,
  'listingId': listingId,
  'nameAr': 'منتج',
  'nameEng': 'Product',
  'nameAbree': 'Product',
  'isShow': true,
  'descriptionAr': '',
  'descriptionEng': '',
  'descriptionAbree': '',
  'normailPrice': 10,
  'wholesalePrice': 8,
  'stock': 5,
  'model': '',
  'isNewItem': false,
  'isMoreSales': false,
  'rate': 0,
  'discount': 0,
  'dateAdd': '2026-10-04T00:00:00Z',
  'dateUpdate': '2026-10-04T00:00:00Z',
  'supCategory': <Object>[],
  'normalImagesItems': <Object>[],
  '_3DImagesItems': <Object>[],
  'viewImagesItems': <Object>[],
  'itemSizes': <Object>[],
};

Map<String, dynamic> _userJson({
  List<String>? accountRoles,
  String typeUser = 'User',
}) => {
  'id': '1',
  'userName': 'user@example.test',
  'normalizedUserName': 'USER@EXAMPLE.TEST',
  'email': 'user@example.test',
  'normalizedEmail': 'USER@EXAMPLE.TEST',
  'emailConfirmed': true,
  'passwordHash': '',
  'securityStamp': '',
  'concurrencyStamp': '',
  'phoneNumber': null,
  'phoneNumberConfirmed': false,
  'twoFactorEnabled': false,
  'lockoutEnd': null,
  'lockoutEnabled': false,
  'accessFailedCount': 0,
  'address': null,
  'block': false,
  'fullName': 'User',
  'phoneNumber2': null,
  'typeUser': typeUser,
  if (accountRoles != null) 'accountRoles': accountRoles,
  'userToken': '',
  'dateAdd': '',
  'userUpdate': '',
  'dateUpdate': '',
  'cityId': null,
  'city': <String, dynamic>{},
  'mainOrders': <Object>[],
  'roles': <Object>[],
};
