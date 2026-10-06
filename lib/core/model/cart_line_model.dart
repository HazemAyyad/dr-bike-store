import 'get_all_item_model.dart';

enum CartLineStatus { retained, needsValidation, unavailable, invalidIdentity }

class CartLineIdentity {
  const CartLineIdentity({
    required this.listingId,
    this.sizeId,
    this.sizeColorId,
  });

  final int listingId;
  final int? sizeId;
  final int? sizeColorId;

  factory CartLineIdentity.fromItem(Item item) {
    final listingId = item.listingId;
    if (listingId == null || listingId <= 0) {
      throw const FormatException('cart listingId must be a positive integer');
    }
    if (item.itemSizeColorId != null && item.itemSizeId == null) {
      throw const FormatException('cart size color requires a size identity');
    }
    return CartLineIdentity(
      listingId: listingId,
      sizeId: item.itemSizeId,
      sizeColorId: item.itemSizeColorId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CartLineIdentity &&
      listingId == other.listingId &&
      sizeId == other.sizeId &&
      sizeColorId == other.sizeColorId;

  @override
  int get hashCode => Object.hash(listingId, sizeId, sizeColorId);
}

class CartLine {
  CartLine({
    required this.identity,
    required this.productId,
    required this.nameAr,
    required this.nameEng,
    required this.nameHe,
    required this.retailPrice,
    required this.discountPercent,
    required this.quantity,
    required this.itemSnapshot,
    this.sizeLabel,
    this.colorLabel,
    this.mediaPath,
    this.knownAvailableQuantity,
    this.status = CartLineStatus.retained,
  });

  static const schemaVersion = 2;

  final CartLineIdentity identity;
  final int productId;
  final String nameAr;
  final String nameEng;
  final String nameHe;
  final double retailPrice;
  final double discountPercent;
  int quantity;
  final String? sizeLabel;
  final String? colorLabel;
  final String? mediaPath;
  final int? knownAvailableQuantity;
  CartLineStatus status;
  final Item itemSnapshot;

  bool get structurallyValid =>
      identity.listingId > 0 &&
      productId > 0 &&
      quantity >= 1 &&
      !(identity.sizeColorId != null && identity.sizeId == null);
  bool get requiresRevalidation => status != CartLineStatus.retained;
  double get unitPriceAfterDiscount =>
      retailPrice * (1 - discountPercent.clamp(0, 100) / 100);
  double get subtotal => quantity * retailPrice;
  double get total => quantity * unitPriceAfterDiscount;

  factory CartLine.fromItem(Item item) {
    final identity = CartLineIdentity.fromItem(item);
    final selectedPrice =
        item.itemSizeId == null
            ? item.normailPrice
            : (item.itemSizeColorsprice ?? item.normailPrice);
    final selectedDiscount =
        item.itemSizeId == null
            ? item.discount
            : (item.itemSizediscount ?? item.discount);
    final mainMedia =
        item.storefrontMedia.isEmpty
            ? null
            : item.storefrontMedia
                .firstWhere(
                  (media) => media.isMain,
                  orElse: () => item.storefrontMedia.first,
                )
                .path;
    final maximum =
        item.itemSizeId == null ? item.stock : item.itemSizeColorsStock;
    if (item.count < 1) {
      throw const FormatException('cart quantity must be positive');
    }
    return CartLine(
      identity: identity,
      productId: item.productId,
      nameAr: item.nameAr,
      nameEng: item.nameEng,
      nameHe: item.nameAbree,
      retailPrice: selectedPrice,
      discountPercent: selectedDiscount,
      quantity: item.count,
      sizeLabel: item.itemSizeSelect,
      colorLabel: item.itemSizeColorSelect,
      mediaPath: mainMedia,
      knownAvailableQuantity: maximum,
      status:
          item.purchasable
              ? CartLineStatus.retained
              : CartLineStatus.unavailable,
      itemSnapshot: item,
    );
  }

  factory CartLine.fromJson(Map<String, dynamic> json) {
    if (json['schema'] != schemaVersion) {
      throw const FormatException('unsupported cart schema');
    }
    final listingId = json['listing_id'];
    final productId = json['product_id'];
    final quantity = json['quantity'];
    final retailPrice = json['retail_price'];
    final discount = json['discount_percent'];
    final snapshot = json['item_snapshot'];
    if (listingId is! int || listingId <= 0) {
      throw const FormatException('persisted cart listingId is invalid');
    }
    if (productId is! int ||
        productId <= 0 ||
        quantity is! int ||
        quantity < 1) {
      throw const FormatException(
        'persisted cart product or quantity is invalid',
      );
    }
    if (retailPrice is! num || discount is! num || snapshot is! Map) {
      throw const FormatException('persisted cart snapshot is malformed');
    }
    final item = Item.fromJson2(Map<String, dynamic>.from(snapshot));
    if (item.listingId != listingId || item.productId != productId) {
      throw const FormatException('persisted cart identity mismatch');
    }
    final sizeId = json['size_id'];
    final colorId = json['size_color_id'];
    if ((sizeId != null && sizeId is! int) ||
        (colorId != null && colorId is! int)) {
      throw const FormatException('persisted option identity is malformed');
    }
    if (colorId != null && sizeId == null) {
      throw const FormatException('persisted color requires size identity');
    }
    item.count = quantity;
    item.itemSizeId = sizeId as int?;
    item.itemSizeColorId = colorId as int?;
    return CartLine(
      identity: CartLineIdentity(
        listingId: listingId,
        sizeId: sizeId,
        sizeColorId: colorId,
      ),
      productId: productId,
      nameAr: json['name_ar']?.toString() ?? '',
      nameEng: json['name_en']?.toString() ?? '',
      nameHe: json['name_he']?.toString() ?? '',
      retailPrice: retailPrice.toDouble(),
      discountPercent: discount.toDouble(),
      quantity: quantity,
      sizeLabel: json['size_label']?.toString(),
      colorLabel: json['color_label']?.toString(),
      mediaPath: json['media_path']?.toString(),
      knownAvailableQuantity: json['known_available_quantity'] as int?,
      status: CartLineStatus.needsValidation,
      itemSnapshot: item,
    );
  }

  Map<String, dynamic> toJson() => {
    'schema': schemaVersion,
    'listing_id': identity.listingId,
    'product_id': productId,
    'size_id': identity.sizeId,
    'size_color_id': identity.sizeColorId,
    'quantity': quantity,
    'name_ar': nameAr,
    'name_en': nameEng,
    'name_he': nameHe,
    'size_label': sizeLabel,
    'color_label': colorLabel,
    'media_path': mediaPath,
    'retail_price': retailPrice,
    'discount_percent': discountPercent,
    'known_available_quantity': knownAvailableQuantity,
    'status': status.name,
    'item_snapshot': itemSnapshot.toJson()..['count'] = quantity,
  };
}
