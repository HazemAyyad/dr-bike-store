import '../model/get_all_item_model.dart';
import 'checkout_attempt.dart';

class MissingListingIdException implements Exception {}

class UnsupportedStoreAccountRoleException implements Exception {}

enum CheckoutRoleRequirement { unavailable, resolved, choiceRequired }

class CheckoutRoleResolution {
  const CheckoutRoleResolution({
    required this.requirement,
    required this.availableRoles,
    this.role,
  });

  final CheckoutRoleRequirement requirement;
  final List<String> availableRoles;
  final String? role;
}

CheckoutRoleResolution resolveCheckoutRoles(Iterable<String> accountRoles) {
  const supported = ['customer', 'seller'];
  final roles = supported.where(accountRoles.toSet().contains).toList();
  if (roles.isEmpty) {
    return const CheckoutRoleResolution(
      requirement: CheckoutRoleRequirement.unavailable,
      availableRoles: [],
    );
  }
  if (roles.length == 1) {
    return CheckoutRoleResolution(
      requirement: CheckoutRoleRequirement.resolved,
      availableRoles: roles,
      role: roles.single,
    );
  }
  return CheckoutRoleResolution(
    requirement: CheckoutRoleRequirement.choiceRequired,
    availableRoles: roles,
  );
}

String? confirmCheckoutRole(
  CheckoutRoleResolution resolution,
  String? selectedRole,
) {
  if (resolution.requirement == CheckoutRoleRequirement.resolved) {
    return resolution.role;
  }
  return resolution.availableRoles.contains(selectedRole) ? selectedRole : null;
}

Map<String, dynamic> buildNativeCheckoutPayload({
  required List<Item> items,
  required String accountRole,
  required String customerAddress,
  required int shiplyCityId,
  required int shiplyVillageId,
  String? couponCode,
}) {
  if (items.any((item) => item.listingId == null)) {
    throw MissingListingIdException();
  }
  if (accountRole != 'customer' && accountRole != 'seller') {
    throw UnsupportedStoreAccountRoleException();
  }

  return {
    'account_role': accountRole,
    'payment': {'type': 'cash', 'paid_amount': 0},
    if (couponCode?.trim().isNotEmpty == true)
      'coupon_code': couponCode!.trim(),
    'delivery': {
      'customer_address': customerAddress.trim(),
      'shiply_city_id': shiplyCityId,
      'shiply_village_id': shiplyVillageId,
    },
    'items':
        items
            .map(
              (item) => {
                'listing_id': item.listingId,
                'size_id': item.itemSizeId,
                'size_color_id': item.itemSizeColorId,
                'quantity': item.count,
              },
            )
            .toList(),
  };
}

class NativeCheckoutSuccess {
  const NativeCheckoutSuccess({
    required this.orderId,
    required this.orderNumber,
    required this.replayed,
  });

  final String orderId;
  final String orderNumber;
  final bool replayed;

  static NativeCheckoutSuccess? tryParse(int? statusCode, dynamic body) {
    if (statusCode != 200 && statusCode != 201) return null;
    if (body is! Map || body['data'] is! Map) return null;
    final data = body['data'] as Map;
    final id = data['id'];
    if (id == null || id.toString().isEmpty) return null;
    final number =
        data['orderNumber'] ?? data['serialNumber'] ?? data['serial_number'];
    return NativeCheckoutSuccess(
      orderId: id.toString(),
      orderNumber:
          number?.toString().trim().isNotEmpty == true
              ? number.toString().trim()
              : id.toString(),
      replayed: body['replayed'] == true,
    );
  }
}

NativeCheckoutSuccess? completeCheckoutAttempt(
  CheckoutAttempt attempt,
  int? statusCode,
  dynamic body,
) {
  final success = NativeCheckoutSuccess.tryParse(statusCode, body);
  if (success != null) attempt.finish(successful: true);
  return success;
}
