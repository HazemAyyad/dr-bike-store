import 'dart:convert';

import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cart serialization retains listing, option, and quantity identity', () {
    final item =
        Item.fromJson(_itemJson(productId: 91, listingId: 407))
          ..count = 3
          ..isSize = true
          ..itemSizeId = 7
          ..itemSizeColorId = 8
          ..itemSizeSelect = 'Large'
          ..itemSizeColorSelect = 'Black'
          ..itemSizeColorsStock = 4
          ..itemSizeColorsprice = 1350
          ..itemSizediscount = 10;

    final persisted = jsonDecode(jsonEncode(item.toJson()));
    final restored = Item.fromJson2(
      Map<String, dynamic>.from(persisted as Map),
    );

    expect(restored.id, 91);
    expect(restored.listingId, 407);
    expect(restored.count, 3);
    expect(restored.isSize, isTrue);
    expect(restored.itemSizeId, 7);
    expect(restored.itemSizeColorId, 8);
    expect(restored.itemSizeSelect, 'Large');
    expect(restored.itemSizeColorSelect, 'Black');
    expect(restored.itemSizeColorsStock, 4);
    expect(restored.itemSizeColorsprice, 1350);
    expect(restored.itemSizediscount, 10);
  });

  test('product id never fills a missing listing id after restoration', () {
    final item = Item.fromJson(_itemJson(productId: 91));
    final restored = Item.fromJson2(item.toJson());

    expect(restored.id, 91);
    expect(restored.listingId, isNull);
  });
}

Map<String, dynamic> _itemJson({required int productId, int? listingId}) => {
  'id': productId,
  'listingId': listingId,
  'nameAr': 'منتج',
  'nameEng': 'Product',
  'nameAbree': 'Product',
  'isShow': true,
  'descriptionAr': '',
  'descriptionEng': '',
  'descriptionAbree': '',
  'normailPrice': 10,
  'wholesalePrice': 8,
  'stock': 5,
  'model': '',
  'isNewItem': false,
  'isMoreSales': false,
  'rate': 0,
  'discount': 0,
  'dateAdd': '2026-10-04T00:00:00Z',
  'dateUpdate': '2026-10-04T00:00:00Z',
  'supCategory': <Object>[],
  'normalImagesItems': <Object>[],
  '_3DImagesItems': <Object>[],
  'viewImagesItems': <Object>[],
  'itemSizes': <Object>[],
};
