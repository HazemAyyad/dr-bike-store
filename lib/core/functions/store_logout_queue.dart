import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef RevokeStoreToken =
    Future<bool> Function(String token, String? fcmToken);

/// The queue is encrypted and is never treated as a signed-in session.
class StoreLogoutQueue {
  StoreLogoutQueue({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();

  static final instance = StoreLogoutQueue();
  static const _key = 'store_pending_revocations';
  final FlutterSecureStorage storage;
  Future<void> _pending = Future<void>.value();
  Future<void>? _flushing;

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<List<Map<String, dynamic>>> _read() async {
    final raw = await storage.read(key: _key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> enqueue(String token, {String? fcmToken}) => _serial(() async {
    final entries = await _read();
    if (!entries.any((entry) => entry['token'] == token)) {
      entries.add({'token': token, 'fcm_token': fcmToken});
      await storage.write(key: _key, value: jsonEncode(entries));
    }
  });

  Future<void> flush(RevokeStoreToken revoke) =>
      _flushing ??= _flush(revoke).whenComplete(() => _flushing = null);

  Future<void> _flush(RevokeStoreToken revoke) async {
    final snapshot = await _serial(_read);
    for (final entry in snapshot) {
      var revoked = false;
      try {
        revoked = await revoke(
          entry['token'] as String,
          entry['fcm_token'] as String?,
        );
      } catch (_) {
        // Retain the request after timeouts and transient failures.
      }
      if (revoked) {
        await _serial(() async {
          final remaining = await _read();
          remaining.removeWhere(
            (candidate) => candidate['token'] == entry['token'],
          );
          if (remaining.isEmpty) {
            await storage.delete(key: _key);
          } else {
            await storage.write(key: _key, value: jsonEncode(remaining));
          }
        });
      }
    }
  }
}
