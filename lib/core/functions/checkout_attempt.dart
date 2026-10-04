import 'package:uuid/uuid.dart';

class CheckoutAttempt {
  CheckoutAttempt({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  String? _id;
  bool _inFlight = false;

  String get id => _id ??= _uuid.v4();
  String? get currentId => _id;
  bool get isInFlight => _inFlight;

  Map<String, dynamic> attachTo(Map<String, dynamic> payload) => {
    ...payload,
    'client_request_id': id,
  };

  bool begin() {
    if (_inFlight) return false;
    _inFlight = true;
    id;
    return true;
  }

  void finish({required bool successful}) {
    _inFlight = false;
    if (successful) _id = null;
  }
}
