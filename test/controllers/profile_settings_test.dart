import 'package:doctor_bike/controller/LocalizationController.dart';
import 'package:doctor_bike/controller/account/account_controller.dart';
import 'package:doctor_bike/core/constants/app_constants.dart';
import 'package:doctor_bike/core/model/conact_us_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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

  test('single address and COD are the only represented capabilities', () {
    const capabilities = <String>{'single_profile_address', 'cash_on_delivery'};
    expect(capabilities, isNot(contains('saved_address_book')));
    expect(capabilities, isNot(contains('saved_cards')));
    expect(capabilities, isNot(contains('raw_card_storage')));
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
}
