import 'package:doctor_bike/core/model/cart_line_model.dart';
import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cart line identity and retained intent', () {
    test(
      'add listing creates a cart line',
      () => expect(CartLine.fromItem(_item()).identity.listingId, 9001),
    );
    test(
      'requires valid listingId',
      () => expect(
        () => CartLine.fromItem(_item(listingId: null)),
        throwsFormatException,
      ),
    );
    test(
      'same listing and option identities are equal',
      () => expect(
        CartLine.fromItem(_item()).identity,
        CartLine.fromItem(_item()).identity,
      ),
    );
    test(
      'different size remains separate',
      () => expect(
        CartLine.fromItem(_item(sizeId: 1)).identity,
        isNot(CartLine.fromItem(_item(sizeId: 2)).identity),
      ),
    );
    test(
      'different size color remains separate',
      () => expect(
        CartLine.fromItem(_item(sizeId: 1, colorId: 2)).identity,
        isNot(CartLine.fromItem(_item(sizeId: 1, colorId: 3)).identity),
      ),
    );
    test(
      'different listings remain separate',
      () => expect(
        CartLine.fromItem(_item()).identity,
        isNot(CartLine.fromItem(_item(listingId: 9002)).identity),
      ),
    );
    test(
      'productId alone never identifies a line',
      () => expect(
        () => CartLine.fromItem(_item(listingId: null, productId: 101)),
        throwsFormatException,
      ),
    );
    test('quantity increment is representable', () {
      final line = CartLine.fromItem(_item());
      line.quantity++;
      expect(line.quantity, 2);
    });
    test('quantity decrement is representable above one', () {
      final line = CartLine.fromItem(_item(count: 2));
      line.quantity--;
      expect(line.quantity, 1);
    });
    test('quantity below one is structurally invalid', () {
      final line = CartLine.fromItem(_item());
      line.quantity = 0;
      expect(line.structurallyValid, isFalse);
    });
    test(
      'known availability is retained as a ceiling hint',
      () =>
          expect(CartLine.fromItem(_item(stock: 3)).knownAvailableQuantity, 3),
    );
    test('exact identity supports exact removal', () {
      final lines = [
        CartLine.fromItem(_item(sizeId: 1)),
        CartLine.fromItem(_item(sizeId: 2)),
      ];
      final identity = lines.first.identity;
      lines.removeWhere((line) => line.identity == identity);
      expect(lines.single.identity.sizeId, 2);
    });
    test('clear cart removes all retained lines', () {
      final lines = [CartLine.fromItem(_item())];
      lines.clear();
      expect(lines, isEmpty);
    });
    test(
      'persistence roundtrip retains line',
      () => expect(
        CartLine.fromJson(
          CartLine.fromItem(_item()).toJson(),
        ).identity.listingId,
        9001,
      ),
    );
    test(
      'malformed persisted item is rejected safely',
      () =>
          expect(() => CartLine.fromJson({'schema': 2}), throwsFormatException),
    );
    test('persisted line without listingId is rejected', () {
      final json = CartLine.fromItem(_item()).toJson()..remove('listing_id');
      expect(() => CartLine.fromJson(json), throwsFormatException);
    });
    test(
      'retail price is retained',
      () => expect(
        CartLine.fromItem(_item(retail: 125, wholesale: 4)).retailPrice,
        125,
      ),
    );
    test(
      'wholesale price never drives cart display',
      () => expect(
        CartLine.fromItem(
          _item(retail: 125, wholesale: 4),
        ).unitPriceAfterDiscount,
        112.5,
      ),
    );
    test(
      'main storefront media snapshot is retained',
      () => expect(CartLine.fromItem(_item()).mediaPath, '/media/main.jpg'),
    );
    test(
      'coupon intent is separate from cart line totals',
      () => expect(CartLine.fromItem(_item()).total, 112.5),
    );
    test(
      'coupon intent does not become authoritative discount',
      () => expect(CartLine.fromItem(_item(discount: 0)).total, 125),
    );
    test(
      'non-purchasable line is retained as unavailable',
      () => expect(
        CartLine.fromItem(_item(purchasable: false)).status,
        CartLineStatus.unavailable,
      ),
    );
    test(
      'unavailable line survives persistence as needs validation',
      () => expect(
        CartLine.fromJson(
          CartLine.fromItem(_item(purchasable: false)).toJson(),
        ).status,
        CartLineStatus.needsValidation,
      ),
    );
    test(
      'stale snapshot is explicitly marked for revalidation',
      () => expect(
        CartLine.fromJson(
          CartLine.fromItem(_item()).toJson(),
        ).requiresRevalidation,
        isTrue,
      ),
    );
    test('cart count sums quantities', () {
      final lines = [
        CartLine.fromItem(_item(count: 2)),
        CartLine.fromItem(_item(listingId: 9002, count: 3)),
      ];
      expect(lines.fold<int>(0, (sum, line) => sum + line.quantity), 5);
    });
    test(
      'color without size is invalid',
      () => expect(
        () => CartLine.fromItem(_item(colorId: 7)),
        throwsFormatException,
      ),
    );
    test('totals are pure across repeated reads', () {
      final line = CartLine.fromItem(_item(count: 2));
      expect(line.total, line.total);
    });
  });
}

Item _item({
  int? listingId = 9001,
  int productId = 101,
  int count = 1,
  int? sizeId,
  int? colorId,
  int stock = 5,
  double retail = 125,
  double wholesale = 80,
  double discount = 10,
  bool purchasable = true,
}) {
  final item = Item.fromJson2({
    'id': productId,
    'productId': productId,
    'listingId': listingId,
    'nameAr': 'دراجة',
    'nameEng': 'Bike',
    'nameAbree': 'Bike',
    'isShow': true,
    'descriptionAr': '',
    'descriptionEng': '',
    'descriptionAbree': '',
    'videoUrl': null,
    'normailPrice': retail,
    'wholesalePrice': wholesale,
    'stock': stock,
    'available': stock > 0,
    'purchasable': purchasable,
    'model': '',
    'isNewItem': false,
    'isMoreSales': false,
    'rate': 0,
    'manufactureYear': null,
    'discount': discount,
    'userIdAdd': null,
    'dateAdd': '2026-10-06',
    'userIdUpdate': null,
    'dateUpdate': '2026-10-06',
    'supCategory': <dynamic>[],
    'normalImagesItems': <dynamic>[],
    '_3DImagesItems': <dynamic>[],
    'viewImagesItems': <dynamic>[],
    'itemSizes': <dynamic>[],
    'storefrontMedia': [
      {
        'id': 1,
        'source_type': 'normal_image',
        'source_id': 1,
        'path': '/media/main.jpg',
        'media_metadata': null,
        'is_main': true,
        'is_visible': true,
        'sort_order': 0,
      },
    ],
    'count': count,
    'isSize': sizeId != null,
    'itemSizeId': sizeId,
    'itemSizeColorsStock': sizeId == null ? null : stock,
    'itemSizediscount': sizeId == null ? null : discount,
    'itemSizeColorsprice': sizeId == null ? null : retail,
    'itemSizeColorId': colorId,
    'itemSizeColorSelect': colorId == null ? null : 'Black',
    'itemSizeSelect': sizeId == null ? null : 'M',
  });
  return item;
}
