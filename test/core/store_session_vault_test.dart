import 'package:doctor_bike/core/constants/app_constants.dart';
import 'package:doctor_bike/core/functions/store_session_vault.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StoreSessionVault vault;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vault = StoreSessionVault();
  });

  test('migrates legacy token then removes the unprotected copy', () async {
    SharedPreferences.setMockInitialValues({AppConstants.TOKEN: 'legacy'});
    expect(await vault.readToken(), 'legacy');
    expect(
      (await SharedPreferences.getInstance()).containsKey(AppConstants.TOKEN),
      isFalse,
    );
    expect(
      await const FlutterSecureStorage().read(key: AppConstants.TOKEN),
      'legacy',
    );
  });

  test('protected token takes precedence over stale preferences', () async {
    await vault.writeToken('current');
    await (await SharedPreferences.getInstance()).setString(
      AppConstants.TOKEN,
      'stale',
    );
    expect(await vault.readToken(), 'current');
    expect(
      (await SharedPreferences.getInstance()).containsKey(AppConstants.TOKEN),
      isFalse,
    );
  });

  test(
    'logout after a concurrent migration cannot resurrect the token',
    () async {
      SharedPreferences.setMockInitialValues({AppConstants.TOKEN: 'legacy'});
      final migration = vault.readToken();
      final logout = vault.deleteToken();
      await migration;
      await logout;
      expect(await vault.readToken(), isNull);
      expect(
        await const FlutterSecureStorage().read(key: AppConstants.TOKEN),
        isNull,
      );
    },
  );

  test('new token never persists in preferences', () async {
    await vault.writeToken('protected');
    expect(
      (await SharedPreferences.getInstance()).containsKey(AppConstants.TOKEN),
      isFalse,
    );
    expect(await vault.readToken(), 'protected');
  });

  test(
    'failed secure migration preserves the legacy session for retry',
    () async {
      SharedPreferences.setMockInitialValues({AppConstants.TOKEN: 'legacy'});
      final failing = StoreSessionVault(storage: const _FailingStorage());
      await expectLater(failing.readToken(), throwsStateError);
      expect(
        (await SharedPreferences.getInstance()).getString(AppConstants.TOKEN),
        'legacy',
      );
      expect(await vault.readToken(), 'legacy');
    },
  );
}

class _FailingStorage extends FlutterSecureStorage {
  const _FailingStorage();
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw StateError('Secure storage unavailable');
}
