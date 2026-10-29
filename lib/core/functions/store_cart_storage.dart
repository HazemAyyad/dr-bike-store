import 'package:get_storage/get_storage.dart';

import '../model/cart_line_model.dart';
import '../model/get_all_item_model.dart';

class StoreCartSnapshot {
  const StoreCartSnapshot(this.lines, this.couponIntent);
  final List<CartLine> lines;
  final String couponIntent;
}

class StoreCartStorage {
  StoreCartStorage(this.storage);
  static const cartKey = 'store_cart_v2';
  static const couponKey = 'store_cart_coupon_intent';
  final GetStorage storage;

  void save(Iterable<CartLine> lines, String couponIntent) {
    storage.write(
      cartKey,
      lines.map((line) => line.toJson()).toList(growable: false),
    );
    storage.write(couponKey, couponIntent);
  }

  StoreCartSnapshot load() {
    final retained = storage.read<dynamic>(cartKey);
    final legacy = retained == null;
    final raw = legacy ? storage.read<dynamic>('cart') : retained;
    final lines = <CartLine>[];
    for (final row in raw is List ? raw : const []) {
      try {
        if (row is! Map) continue;
        final json = Map<String, dynamic>.from(row);
        lines.add(
          legacy
              ? (CartLine.fromItem(Item.fromJson2(json))
                ..status = CartLineStatus.needsValidation)
              : CartLine.fromJson(json),
        );
      } catch (_) {
        // Malformed rows cannot fabricate a listing identity or crash startup.
      }
    }
    final coupon = storage.read<dynamic>(couponKey);
    final snapshot = StoreCartSnapshot(lines, coupon is String ? coupon : '');
    if (legacy) {
      save(snapshot.lines, snapshot.couponIntent);
      storage.remove('cart');
    }
    return snapshot;
  }
}
