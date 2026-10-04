import '../model/get_all_item_model.dart';
import 'checkout_attempt.dart';

class MissingListingIdException implements Exception {}

class UnsupportedStoreAccountRoleException implements Exception {}

String storeAccountRole(String? userType) {
  switch (userType?.trim().toLowerCase()) {
    case 'normail':
    case 'normal':
    case 'user':
    case 'retail':
    case 'customer':
      return 'customer';
    case 'wholesale':
    case 'seller':
      return 'seller';
    default:
      throw UnsupportedStoreAccountRoleException();
  }
}

Map<String, dynamic> buildNativeCheckoutPayload({
  required List<Item> items,
  required String? userType,
  required String customerAddress,
  required int shiplyCityId,
  required int shiplyVillageId,
  String? couponCode,
}) {
  if (items.any((item) => item.listingId == null)) {
    throw MissingListingIdException();
  }

  return {
    'account_role': storeAccountRole(userType),
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
  const NativeCheckoutSuccess({required this.orderId, required this.replayed});

  final String orderId;
  final bool replayed;

  static NativeCheckoutSuccess? tryParse(int? statusCode, dynamic body) {
    if (statusCode != 200 && statusCode != 201) return null;
    if (body is! Map || body['data'] is! Map) return null;
    final id = (body['data'] as Map)['id'];
    if (id == null || id.toString().isEmpty) return null;
    return NativeCheckoutSuccess(
      orderId: id.toString(),
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
