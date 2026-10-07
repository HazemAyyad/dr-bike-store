enum CheckoutStage {
  idle,
  loadingProfile,
  address,
  shipping,
  payment,
  review,
  submitting,
  offline,
  uncertain,
  validationError,
  success,
  error,
}

enum CheckoutTransportKind { response, offline, uncertain }

class CheckoutTransportResult<T> {
  const CheckoutTransportResult._(this.kind, [this.response]);

  final CheckoutTransportKind kind;
  final T? response;

  const CheckoutTransportResult.response(T response)
    : this._(CheckoutTransportKind.response, response);
  const CheckoutTransportResult.offline()
    : this._(CheckoutTransportKind.offline);
  const CheckoutTransportResult.uncertain()
    : this._(CheckoutTransportKind.uncertain);
}

Future<CheckoutTransportResult<T>> runCheckoutTransport<T>({
  required Future<bool> Function() connectivityCheck,
  required Future<T> Function() submit,
}) async {
  if (!await connectivityCheck()) {
    return const CheckoutTransportResult.offline();
  }
  try {
    return CheckoutTransportResult.response(await submit());
  } catch (_) {
    return const CheckoutTransportResult.uncertain();
  }
}

enum CheckoutPaymentCapability { cash }

enum CheckoutValidationKind {
  listing,
  stock,
  variant,
  coupon,
  location,
  accountRole,
  payment,
  unknown,
}

class CheckoutFlowState {
  const CheckoutFlowState({
    this.stage = CheckoutStage.idle,
    this.selectedRole,
    this.availableRoles = const [],
    this.message,
    this.orderId,
    this.orderNumber,
    this.replayed = false,
    this.validationKind,
  });

  final CheckoutStage stage;
  final String? selectedRole;
  final List<String> availableRoles;
  final String? message;
  final String? orderId;
  final String? orderNumber;
  final bool replayed;
  final CheckoutValidationKind? validationKind;

  CheckoutFlowState copyWith({
    CheckoutStage? stage,
    String? selectedRole,
    List<String>? availableRoles,
    String? message,
    String? orderId,
    String? orderNumber,
    bool? replayed,
    CheckoutValidationKind? validationKind,
  }) => CheckoutFlowState(
    stage: stage ?? this.stage,
    selectedRole: selectedRole ?? this.selectedRole,
    availableRoles: availableRoles ?? this.availableRoles,
    message: message,
    orderId: orderId ?? this.orderId,
    orderNumber: orderNumber ?? this.orderNumber,
    replayed: replayed ?? this.replayed,
    validationKind: validationKind,
  );
}

CheckoutValidationKind classifyCheckoutValidation(dynamic body) {
  final text = body.toString().toLowerCase();
  if (text.contains('coupon')) return CheckoutValidationKind.coupon;
  if (text.contains('stock') || text.contains('quantity')) {
    return CheckoutValidationKind.stock;
  }
  if (text.contains('variant') || text.contains('size')) {
    return CheckoutValidationKind.variant;
  }
  if (text.contains('listing')) return CheckoutValidationKind.listing;
  if (text.contains('city') ||
      text.contains('village') ||
      text.contains('location')) {
    return CheckoutValidationKind.location;
  }
  if (text.contains('account_role') || text.contains('role')) {
    return CheckoutValidationKind.accountRole;
  }
  if (text.contains('payment')) return CheckoutValidationKind.payment;
  return CheckoutValidationKind.unknown;
}
