import 'package:doctor_bike/core/functions/store_logout_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

void main() {
  test('a pending network retry cannot block a newer local logout', () async {
    final queue = StoreLogoutQueue();
    await queue.enqueue('old');
    final started = Completer<void>();
    final response = Completer<bool>();
    final flush = queue.flush((_, _) {
      started.complete();
      return response.future;
    });
    await started.future;
    await queue.enqueue('new').timeout(const Duration(seconds: 1));
    response.complete(true);
    await flush;
    final remaining = <String>[];
    await queue.flush((token, _) async {
      remaining.add(token);
      return true;
    });
    expect(remaining, ['new']);
  });
  test(
    'offline logout survives retry and keeps the originating device',
    () async {
      final queue = StoreLogoutQueue();
      await queue.enqueue('old-session', fcmToken: 'old-device');
      await queue.flush((_, _) async => false);
      final attempts = <String>[];
      await queue.flush((token, device) async {
        attempts.add('$token:$device');
        return true;
      });
      await queue.flush(
        (_, _) async => throw StateError('queue must be empty'),
      );
      expect(attempts, ['old-session:old-device']);
    },
  );

  test(
    'separate sessions are deduplicated and successful revocations removed',
    () async {
      final queue = StoreLogoutQueue();
      await queue.enqueue('first');
      await queue.enqueue('first');
      await queue.enqueue('second');
      final attempts = <String>[];
      await queue.flush((token, _) async {
        attempts.add(token);
        return token == 'first';
      });
      await queue.flush((token, _) async {
        attempts.add(token);
        return true;
      });
      expect(attempts, ['first', 'second', 'second']);
    },
  );
}
