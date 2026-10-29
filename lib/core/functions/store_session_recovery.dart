import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import 'store_logout_queue.dart';

class StoreSessionRecovery with WidgetsBindingObserver {
  StoreSessionRecovery(this.revoke);
  final RevokeStoreToken revoke;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _connectivity = Connectivity().onConnectivityChanged.listen((connections) {
      if (!connections.contains(ConnectivityResult.none)) unawaited(_retry());
    });
    unawaited(_retry());
  }

  Future<void> _retry() async {
    try {
      await StoreLogoutQueue.instance.flush(revoke);
    } catch (_) {
      /* Retry on the next connection/resume. */
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_retry());
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivity?.cancel();
  }
}
