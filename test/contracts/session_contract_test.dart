import 'package:doctor_bike/controller/LocalizationController.dart';
import 'package:doctor_bike/core/constants/app_constants.dart';
import 'package:doctor_bike/core/functions/app_usage_service.dart';
import 'package:doctor_bike/core/model/auth_eesponse.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('retained Store session keys keep their compatibility values', () {
    expect(AppConstants.TOKEN, 'Doctor_Bike_token');
    expect(AppConstants.ISLOGIN, 'ISLOGIN');
    expect(AppConstants.userId, 'userId');
    expect(AppConstants.userName, 'userName');
    expect(AppConstants.userEmail, 'userEmail');
    expect(AppConstants.typeUser, 'typeUser');
    expect(AppConstants.LANGUAGE_CODE, 'doctorBikeLanguage_code');
    expect(AppConstants.COUNTRY_CODE, 'doctorBikeCountry_code');
  });

  test('session and locale survive SharedPreferences reconstruction', () async {
    await AppUsageService.saveToken('retained-token');
    await AppUsageService.saveIsLogin(true);
    await AppUsageService.saveUserId('user-17');
    await AppUsageService.saveUserName('حازم');
    await AppUsageService.saveUserEmail('hazem@example.test');

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(AppConstants.LANGUAGE_CODE, 'ar');
    await preferences.setString(AppConstants.COUNTRY_CODE, 'SA');

    final reloaded = await SharedPreferences.getInstance();
    final localization = LocalizationController(sharedPreferences: reloaded);

    expect(await AppUsageService.getToken(), 'retained-token');
    expect(await AppUsageService.getIsLogin(), isTrue);
    expect(await AppUsageService.getUserId(), 'user-17');
    expect(await AppUsageService.getUserName(), 'حازم');
    expect(await AppUsageService.getUserEmail(), 'hazem@example.test');
    expect(localization.locale.languageCode, 'ar');
    expect(localization.locale.countryCode, 'SA');
    expect(localization.isLtr, isFalse);
  });

  test('login and profile parsing retain authoritative accountRoles', () {
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
    expect(profile.typeUser, 'User');
    expect(UserModel.fromJson(_userJson()).accountRoles, isEmpty);
  });
}

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
