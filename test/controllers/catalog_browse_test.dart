import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:doctor_bike/core/model/main_categores_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Online Store category contract', () {
    test('parses hierarchy without inventory section identity', () {
      final response = OnlineStoreCategoriesResponse.fromJson({
        'rows': [
          {
            'id': 10,
            'categoryId': 10,
            'parentId': null,
            'nameAr': 'دراجات',
            'nameEng': 'Bikes',
            'nameAbree': 'Bikes',
            'imageUrl': 'category.jpg',
            'isShow': true,
            'children': [
              {
                'id': 11,
                'categoryId': 11,
                'parentId': 10,
                'nameAr': 'كهربائية',
                'nameEng': 'Electric',
                'nameAbree': 'Electric',
                'imageUrl': 'child.jpg',
                'isShow': true,
                'children': <dynamic>[],
              },
            ],
          },
        ],
        'paginationInfo': {'totalRowsCount': 1, 'totalPagesCount': 1},
      });
      expect(response.rows.single.id, 10);
      expect(response.rows.single.children.single.id, 11);
    });

    test('rejects store_section_id and malformed category ids', () {
      expect(
        () => OnlineStoreCategory.fromJson({
          'id': 1,
          'categoryId': 1,
          'store_section_id': 99,
          'nameAr': 'Wrong',
          'isShow': true,
        }),
        throwsFormatException,
      );
      expect(
        () => OnlineStoreCategory.fromJson({'id': '1', 'isShow': true}),
        throwsFormatException,
      );
    });
  });

  group('Storefront listing contract', () {
    test(
      'keeps product and listing identities distinct and honors main media',
      () {
        final item = Item.fromJson(_listing());
        expect(item.productId, 101);
        expect(item.id, 101);
        expect(item.listingId, 9001);
        expect(
          item.storefrontMedia.firstWhere((media) => media.isMain).path,
          'main.jpg',
        );
        expect(item.normailPrice, 125);
        expect(item.available, isTrue);
      },
    );

    test(
      'rejects malformed identity, eligibility, price, availability, and media',
      () {
        for (final mutation
            in <Map<String, dynamic> Function(Map<String, dynamic>)>[
              (json) => json..['listingId'] = '9001',
              (json) => json..['productId'] = 102,
              (json) => json..['listingStatus'] = 'draft',
              (json) => json..['readinessState'] = 'incomplete',
              (json) => json..['normailPrice'] = '125',
              (json) => json..['available'] = 1,
              (json) => json..['storefrontMedia'] = <dynamic>[],
            ]) {
          expect(
            () => Item.fromJson(mutation(_listing())),
            throwsFormatException,
          );
        }
      },
    );

    test('rejects malformed response instead of converting it to empty', () {
      expect(
        () => ItemsResponse.fromJson({'rows': null}),
        throwsFormatException,
      );
      expect(
        () => ItemsResponse.fromJson({
          'rows': ['bad'],
        }),
        throwsFormatException,
      );
    });
  });
}

Map<String, dynamic> _listing() => {
  'id': 101,
  'productId': 101,
  'listingId': 9001,
  'listingStatus': 'published',
  'readinessState': 'complete',
  'nameAr': 'دراجة',
  'nameEng': 'Bike',
  'nameAbree': 'Bike',
  'isShow': true,
  'descriptionAr': '',
  'descriptionEng': '',
  'descriptionAbree': '',
  'videoUrl': null,
  'normailPrice': 125,
  'wholesalePrice': 80,
  'stock': 3,
  'available': true,
  'purchasable': true,
  'model': '',
  'isNewItem': true,
  'isMoreSales': false,
  'rate': 4.5,
  'manufactureYear': null,
  'discount': 0,
  'userIdAdd': null,
  'dateAdd': '2026-10-06T00:00:00',
  'userIdUpdate': null,
  'dateUpdate': '2026-10-06T00:00:00',
  'supCategory': <dynamic>[],
  'normalImagesItems': <dynamic>[],
  '_3DImagesItems': <dynamic>[],
  'viewImagesItems': <dynamic>[],
  'itemSizes': <dynamic>[],
  'storefrontMedia': [
    {
      'id': 2,
      'path': 'second.jpg',
      'source_type': 'normal_image',
      'is_main': false,
      'sort_order': 2,
      'media_metadata': null,
    },
    {
      'id': 1,
      'path': 'main.jpg',
      'source_type': 'normal_image',
      'is_main': true,
      'sort_order': 0,
      'media_metadata': null,
    },
  ],
};
