import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Serializes migration and logout so a late read cannot restore a removed token.
class StoreSessionVault {
  StoreSessionVault({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage storage;
  Future<void> _pending = Future<void>.value();

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<String?> readToken() => _serial(() async {
    final preferences = await SharedPreferences.getInstance();
    final protected = await storage.read(key: AppConstants.TOKEN);
    if (protected != null) {
      await preferences.remove(AppConstants.TOKEN);
      return protected;
    }
    final legacy = preferences.getString(AppConstants.TOKEN);
    if (legacy == null || legacy.isEmpty) return null;
    await _writeVerified(legacy);
    await preferences.remove(AppConstants.TOKEN);
    return legacy;
  });

  Future<void> writeToken(String token) => _serial(() async {
    await _writeVerified(token);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(AppConstants.TOKEN);
  });

  Future<void> _writeVerified(String token) async {
    await storage.write(key: AppConstants.TOKEN, value: token);
    if (await storage.read(key: AppConstants.TOKEN) != token) {
      throw StateError('Secure session persistence failed');
    }
  }

  Future<void> deleteToken() => _serial(() async {
    await storage.delete(key: AppConstants.TOKEN);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(AppConstants.TOKEN);
  });

  Future<bool> invalidateIfCurrent(String token) => _serial(() async {
    final preferences = await SharedPreferences.getInstance();
    final current =
        await storage.read(key: AppConstants.TOKEN) ??
        preferences.getString(AppConstants.TOKEN);
    if (current != token) return false;
    await storage.delete(key: AppConstants.TOKEN);
    for (final key in [
      AppConstants.TOKEN,
      AppConstants.ISLOGIN,
      AppConstants.userId,
      AppConstants.userName,
      AppConstants.userEmail,
      AppConstants.typeUser,
    ]) {
      await preferences.remove(key);
    }
    return true;
  });
}
