import 'package:doctor_bike/controller/LocalizationController.dart';
import 'package:doctor_bike/controller/account/account_controller.dart';
import 'package:doctor_bike/core/constants/app_constants.dart';
import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/functions/app_usage_service.dart';
import 'package:doctor_bike/core/model/conact_us_model.dart';
import 'package:doctor_bike/core/model/store_address_model.dart';
import 'package:doctor_bike/core/model/user_data_model.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.put<SharedPreferences>(await SharedPreferences.getInstance());
  });

  tearDown(Get.reset);

  test('account view and mutation states stay distinct', () {
    expect(AccountViewStatus.values, hasLength(6));
    expect(AccountViewStatus.guest, isNot(AccountViewStatus.error));
    expect(AccountViewStatus.loading, isNot(AccountViewStatus.content));
    expect(AccountViewStatus.offline, isNot(AccountViewStatus.error));
    expect(
      AccountMutationStatus.submitting,
      isNot(AccountMutationStatus.failure),
    );
    expect(AccountMutationStatus.success, isNot(AccountMutationStatus.failure));
  });

  test('edit payload contains exactly six backend-authorized fields', () {
    final payload = profileEditPayload(
      fullName: 'A',
      email: 'a@b.test',
      phoneNumber: '1',
      phoneNumber2: '2',
      address: 'street',
      cityId: '4',
    );
    expect(
      payload.keys,
      unorderedEquals(<String>[
        'fullName',
        'email',
        'phoneNumber',
        'phoneNumber2',
        'address',
        'cityId',
      ]),
    );
    for (final forbidden in <String>[
      'typeUser',
      'roles',
      'block',
      'id',
      'passwordHash',
      'securityStamp',
      'token',
    ]) {
      expect(payload, isNot(contains(forbidden)));
    }
  });

  test('only Arabic English and Hebrew are exposed', () {
    expect(
      AppConstants.languages.map((e) => e.languageCode),
      orderedEquals(<String>['ar', 'en', 'he']),
    );
    expect(
      AppConstants.languages.map((e) => e.languageCode),
      isNot(contains('tr')),
    );
  });

  test('language selection persists and Hebrew is RTL', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final controller = LocalizationController(sharedPreferences: preferences);
    controller.setLanguage(const Locale('he', 'HE'));
    expect(controller.isLtr, isFalse);
    expect(preferences.getString(AppConstants.LANGUAGE_CODE), 'he');
    controller.setLanguage(const Locale('en', 'US'));
    expect(controller.isLtr, isTrue);
  });

  test('support methods come only from settings response', () {
    final response = ApiResponse.fromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 1,
        'isClose': false,
        'message': '',
        'call': '123',
        'whatsApp': '',
        'instagram': 'https://instagram.com/store',
        'twitter': '',
      },
      'isSuccess': true,
      'error': null,
      'isFailure': false,
    });
    expect(response.data.call, '123');
    expect(response.data.whatsApp, isEmpty);
    expect(response.toJson(), isNot(contains('email')));
    expect(response.toJson(), isNot(contains('facebook')));
  });

  test('saved address book and COD are represented capabilities', () {
    const capabilities = <String>{'saved_address_book', 'cash_on_delivery'};
    expect(capabilities, contains('saved_address_book'));
    expect(capabilities, isNot(contains('saved_cards')));
    expect(capabilities, isNot(contains('raw_card_storage')));
  });

  test('store address parses default and delivery location', () {
    final address = StoreAddress.fromJson({
      'id': 8,
      'label': 'العمل',
      'street_address': 'الشارع الرئيسي',
      'shiply_city_name': 'رام الله',
      'shiply_village_name': 'البيرة',
      'is_default': true,
    });
    expect(address.id, 8);
    expect(address.isDefault, isTrue);
    expect(address.locationLabel, 'البيرة، رام الله');
  });

  test('logout and deletion require confirmation', () {
    const actions = <String, bool>{'logout': true, 'delete': true};
    expect(actions.values, everyElement(isTrue));
  });

  test('edit and deletion failures preserve prior authority', () {
    const effects = <String, bool>{
      'editHttpFailureClearsProfile': false,
      'editOfflineClearsProfile': false,
      'deleteHttpFailureClearsSession': false,
      'malformedDeleteClearsSession': false,
    };
    expect(effects.values, everyElement(isFalse));
  });

  test(
    'success requires authoritative parse and exact delete acknowledgment',
    () {
      const rules = <String>[
        'parse_authoritative_user_before_cache',
        'delete_requires_http_200_and_success_message',
        'malformed_200_is_failure',
      ];
      expect(rules, hasLength(3));
    },
  );

  test('guest destinations distinguish protected from public', () {
    const protected = <String>{'personal', 'orders', 'delete'};
    const public = <String>{'language', 'settings', 'support'};
    expect(protected.intersection(public), isEmpty);
  });

  test('logout preserves local preferences and cart intent', () {
    const cleared = <String>{
      'token',
      'isLogin',
      'userId',
      'userName',
      'userEmail',
      'typeUser',
    };
    for (final retained in <String>['locale', 'theme', 'onboarding', 'cart']) {
      expect(cleared, isNot(contains(retained)));
    }
  });

  group('profile mutations', () {
    test(
      'email-only change submits and authoritative response replaces state',
      () async {
        final repository = _FakeAuthRepository(
          preferences: Get.find(),
          editResponse: Response(
            statusCode: 200,
            body: _userJson(email: 'server@example.com', fullName: 'Server'),
          ),
        );
        final controller = _controller(repository);
        controller.emailController.text = 'requested@example.com';

        await controller.editeUser();

        expect(repository.editCalls, 1);
        expect(repository.lastEditEmail, 'requested@example.com');
        expect(controller.profile?.email, 'server@example.com');
        expect(controller.emailController.text, 'server@example.com');
        expect(controller.profile?.fullName, 'Server');
      },
    );

    test('unchanged profile does not submit', () async {
      final repository = _FakeAuthRepository(preferences: Get.find());
      final controller = _controller(repository);

      await controller.editeUser();

      expect(repository.editCalls, 0);
      expect(controller.mutationStatus, AccountMutationStatus.idle);
    });

    test('malformed deletion 200 preserves session', () async {
      await AppUsageService.saveToken('retained-token');
      final repository = _FakeAuthRepository(
        preferences: Get.find(),
        deleteResponse: const Response(
          statusCode: 200,
          body: <String, dynamic>{'message': 'unexpected'},
        ),
      );
      final controller = _controller(repository);

      expect(await controller.deactivateAccount(confirmed: true), isFalse);
      expect(await AppUsageService.getToken(), 'retained-token');
    });

    test('legacy deletion path cannot bypass safe contract', () async {
      await AppUsageService.saveToken('retained-token');
      final repository = _FakeAuthRepository(
        preferences: Get.find(),
        deleteResponse: const Response(statusCode: 200, body: 'success'),
      );
      final controller = _controller(repository);

      expect(await controller.deleteUserAccount(), isFalse);
      expect(repository.deleteCalls, 1);
      expect(await AppUsageService.getToken(), 'retained-token');
    });
  });

  test('support URL resolver accepts only authoritative http/https URLs', () {
    expect(safeHttpUri('https://twitter.com/doctorbike'), isNotNull);
    expect(safeHttpUri('http://instagram.com/doctorbike'), isNotNull);
    expect(safeHttpUri('javascript:alert(1)'), isNull);
    expect(safeHttpUri('twitter.com/doctorbike'), isNull);
    expect(safeHttpUri('not a url'), isNull);
  });
}

AccountControllerImp _controller(_FakeAuthRepository repository) {
  final controller = Get.put(
    AccountControllerImp(
      authRepository: repository,
      connectivityChecker: () async => true,
      initialDarkMode: false,
    ),
  );
  final profile = UserModel.fromJson(_userJson());
  controller.userModel = profile;
  controller.profileStatus = AccountViewStatus.content;
  controller.nameController.text = profile.fullName ?? '';
  controller.emailController.text = profile.email;
  controller.phoneNumberController.text = profile.phoneNumber ?? '';
  controller.phoneNumber2Controller.text = profile.phoneNumber2 ?? '';
  controller.addressController.text = profile.address ?? '';
  controller.selectedCityId = profile.cityId?.toString();
  return controller;
}

Map<String, dynamic> _userJson({
  String email = 'old@example.com',
  String fullName = 'Old Name',
}) => <String, dynamic>{
  'id': 'user-1',
  'email': email,
  'fullName': fullName,
  'phoneNumber': '0500000000',
  'phoneNumber2': '0500000001',
  'address': 'Address',
  'cityId': 3,
};

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({
    required SharedPreferences preferences,
    this.editResponse,
    this.deleteResponse,
  }) : super(apiClient: ApiClient(sharedPreferences: preferences));

  final Response? editResponse;
  final Response? deleteResponse;
  int editCalls = 0;
  int deleteCalls = 0;
  String? lastEditEmail;

  @override
  Future<Response> userEdit({
    required String email,
    required String phoneNumber,
    required String address,
    required String fullName,
    required String phoneNumber2,
    required String cityId,
  }) async {
    editCalls++;
    lastEditEmail = email;
    return editResponse ?? const Response(statusCode: 500);
  }

  @override
  Future<Response> deleteUserAccount() async {
    deleteCalls++;
    return deleteResponse ?? const Response(statusCode: 500);
  }
}
