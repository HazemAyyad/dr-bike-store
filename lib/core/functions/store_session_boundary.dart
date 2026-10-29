import 'package:get/get.dart';

/// Invalidates in-flight account reads and clears private controller caches.
abstract final class StoreSessionBoundary {
  static int _generation = 0;
  static int get generation => _generation;
  static final _listeners = <void Function()>{};

  static void reset() {
    _generation++;
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }
}

mixin StoreSessionAware on GetxController {
  int get sessionGeneration => StoreSessionBoundary.generation;
  bool sessionIsCurrent(int generation) =>
      generation == sessionGeneration && !isClosed;
  void clearSessionData();

  @override
  void onInit() {
    StoreSessionBoundary._listeners.add(clearSessionData);
    super.onInit();
  }

  @override
  void onClose() {
    StoreSessionBoundary._listeners.remove(clearSessionData);
    super.onClose();
  }
}
