import 'package:doctor_bike/controller/product/product_controller.dart';
import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:doctor_bike/core/model/product_media_model.dart';
import 'package:doctor_bike/repository/categories/categories_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeCategoriesRepository repository;

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    repository = _FakeCategoriesRepository(
      apiClient: ApiClient(sharedPreferences: preferences),
    );
  });

  tearDown(Get.reset);

  group('product detail parsing', () {
    test('valid published product detail', () {
      final item = Item.fromJson(_detail());
      expect(item.listingStatus, 'published');
      expect(item.readinessState, 'complete');
    });

    test('listingId and productId remain distinct', () {
      final item = Item.fromJson(_detail());
      expect(item.productId, 101);
      expect(item.listingId, 9001);
      expect(item.id, item.productId);
    });

    test('malformed listingId', () {
      expect(
        () => Item.fromJson(_detail()..['listingId'] = '9001'),
        throwsFormatException,
      );
    });

    test('malformed productId', () {
      expect(
        () => Item.fromJson(_detail()..['productId'] = '101'),
        throwsFormatException,
      );
    });

    test('unpublished or ineligible detail is not presented', () {
      for (final mutation in <void Function(Map<String, dynamic>)>[
        (json) => json['listingStatus'] = 'draft',
        (json) => json['readinessState'] = 'incomplete',
      ]) {
        final json = _detail();
        mutation(json);
        expect(() => Item.fromJson(json), throwsFormatException);
      }
    });

    test('retail price parsing never selects wholesale price', () {
      final item = Item.fromJson(
        _detail()
          ..['normailPrice'] = 149.5
          ..['wholesalePrice'] = 72,
      );
      expect(item.normailPrice, 149.5);
      expect(item.wholesalePrice, 72);
    });

    test('availability parsing', () {
      final item = Item.fromJson(
        _detail()
          ..['available'] = true
          ..['purchasable'] = false,
      );
      expect(item.available, isTrue);
      expect(item.purchasable, isFalse);
    });

    test('out-of-stock remains visible but non-purchasable', () {
      final item = Item.fromJson(
        _detail()
          ..['stock'] = 0
          ..['available'] = true
          ..['purchasable'] = false,
      );
      expect(item.isShow, isTrue);
      expect(item.available, isTrue);
      expect(item.purchasable, isFalse);
    });
  });

  group('typed storefront media', () {
    test('single image', () {
      final item = Item.fromJson(_detail());
      expect(item.storefrontMedia, hasLength(1));
      expect(item.storefrontMedia.single.type, ProductMediaType.image);
    });

    test('multiple images', () {
      final item = Item.fromJson(
        _detail()
          ..['storefrontMedia'] = [
            _media(id: 1, main: true, order: 0),
            _media(id: 2, main: false, order: 1),
          ],
      );
      expect(item.storefrontMedia, hasLength(2));
    });

    test('main media selection is explicit', () {
      final item = Item.fromJson(
        _detail()
          ..['storefrontMedia'] = [
            _media(id: 2, main: false, order: 0),
            _media(id: 1, main: true, order: 1),
          ],
      );
      expect(item.storefrontMedia.singleWhere((media) => media.isMain).id, 1);
    });

    test('media sort_order is deterministic', () {
      final item = Item.fromJson(
        _detail()
          ..['storefrontMedia'] = [
            _media(id: 2, main: false, order: 8),
            _media(id: 1, main: true, order: 2),
          ],
      );
      expect(item.storefrontMedia.map((media) => media.id), [1, 2]);
    });

    test('hidden media does not appear and malformed media is rejected', () {
      final detail =
          _detail()
            ..['storefrontMedia'] = [
              _media(id: 1, main: true, order: 0),
              _media(id: 2, main: false, order: 1)..['is_visible'] = false,
            ];
      expect(Item.fromJson(detail).storefrontMedia, hasLength(1));
      expect(
        () => ProductMedia.fromJson(
          _media(id: 3, main: false, order: 2)..['path'] = '',
        ),
        throwsFormatException,
      );
    });

    test('valid video capability', () {
      final media = ProductMedia.fromJson(
        _media(
          id: 1,
          main: true,
          order: 0,
          metadata: {'media_type': 'video', 'mime_type': 'video/mp4'},
        ),
      );
      expect(media.type, ProductMediaType.video);
    });

    test('invalid video metadata is unsupported', () {
      final media = ProductMedia.fromJson(
        _media(
          id: 1,
          main: true,
          order: 0,
          sourceType: 'store_specific',
          metadata: {'media_type': 'movie'},
        ),
      );
      expect(media.type, ProductMediaType.unsupported);
    });

    test('explicit interactive 360 capability', () {
      final media = ProductMedia.fromJson(
        _media(
          id: 1,
          main: true,
          order: 0,
          metadata: {'media_type': 'interactive_360', 'is_360': true},
        ),
      );
      expect(media.type, ProductMediaType.interactive360);
    });

    test('normal static image is not treated as 360', () {
      final media = ProductMedia.fromJson(
        _media(id: 1, main: true, order: 0, sourceType: 'image3d'),
      );
      expect(media.type, ProductMediaType.image);
      expect(media.isInteractive360, isFalse);
    });

    test('legacy static image sources remain images without metadata', () {
      for (final sourceType in ['normal_image', 'view_image', 'variant']) {
        final media = ProductMedia.fromJson(
          _media(id: 1, main: true, order: 0, sourceType: sourceType),
        );
        expect(media.type, ProductMediaType.image, reason: sourceType);
      }
    });

    test('image3d without metadata is a static image, never implicit 360', () {
      final media = ProductMedia.fromJson(
        _media(id: 1, main: true, order: 0, sourceType: 'image3d'),
      );
      expect(media.type, ProductMediaType.image);
      expect(media.isInteractive360, isFalse);
    });

    test('image3d with explicit is_360 is interactive', () {
      final media = ProductMedia.fromJson(
        _media(
          id: 1,
          main: true,
          order: 0,
          sourceType: 'image3d',
          metadata: {'is_360': true},
        ),
      );
      expect(media.type, ProductMediaType.interactive360);
    });

    test('store_specific without metadata remains unsupported', () {
      final media = ProductMedia.fromJson(
        _media(id: 1, main: true, order: 0, sourceType: 'store_specific'),
      );
      expect(media.type, ProductMediaType.unsupported);
    });

    test('store_specific honors explicit video metadata', () {
      final media = ProductMedia.fromJson(
        _media(
          id: 1,
          main: true,
          order: 0,
          sourceType: 'store_specific',
          metadata: {'media_type': 'video'},
        ),
      );
      expect(media.type, ProductMediaType.video);
    });

    test('unsupported media type', () {
      final media = ProductMedia.fromJson(
        _media(
          id: 1,
          main: true,
          order: 0,
          sourceType: 'unknown',
          metadata: {'media_type': 'model'},
        ),
      );
      expect(media.type, ProductMediaType.unsupported);
    });

    test('missing media is rejected for eligible detail', () {
      expect(
        () => Item.fromJson(_detail()..['storefrontMedia'] = <dynamic>[]),
        throwsFormatException,
      );
    });

    test('malformed media metadata is rejected', () {
      expect(
        () => ProductMedia.fromJson(
          _media(id: 1, main: true, order: 0)..['media_metadata'] = 'bad',
        ),
        throwsFormatException,
      );
    });
  });

  group('product controller states and purchase rules', () {
    test('product detail loading reaches content', () async {
      final controller = _controller(
        repository,
        Response(body: _detail(), statusCode: 200),
      );
      final future = controller.loadProductDetail(productId: 101);
      expect(controller.productState, isA<StoreLoading<Item>>());
      await future;
      expect(controller.productState, isA<StoreContent<Item>>());
    });

    test('product detail error remains an error', () async {
      final controller = _controller(
        repository,
        const Response(body: {'bad': true}, statusCode: 200),
      );
      await controller.loadProductDetail(productId: 101);
      expect(controller.productState, isA<StoreError<Item>>());
      expect(controller.productState, isNot(isA<StoreEmpty<Item>>()));
    });

    test('product not found becomes unavailable', () async {
      final controller = _controller(
        repository,
        const Response(statusCode: 404),
      );
      await controller.loadProductDetail(productId: 101);
      expect(controller.productState, isA<StoreEmpty<Item>>());
      expect(controller.itemView, isNull);
    });

    test('offline remains offline', () async {
      final controller = ProductControllerImp(
        categoriesRepository: repository,
        connectivityCheck: () async => false,
      );
      await controller.loadProductDetail(productId: 101);
      expect(controller.productState, isA<StoreOffline<Item>>());
    });

    test('quantity boundaries follow authoritative stock', () async {
      final controller = _controller(
        repository,
        Response(body: _detail(), statusCode: 200),
      );
      await controller.loadProductDetail(productId: 101);
      controller.setQuantity(99);
      expect(controller.quantity.value, 3);
      controller.setQuantity(-1);
      expect(controller.quantity.value, 1);
    });

    test('option state exists only when backend provides options', () async {
      final detail =
          _detail()
            ..['itemSizes'] = [
              {
                'id': 7,
                'itemId': 101,
                'size': 'M',
                'discount': 0,
                'description': '',
                'itemSizeColor': [
                  {
                    'id': 8,
                    'sizeId': 7,
                    'colorAr': 'أسود',
                    'colorEn': 'Black',
                    'colorAbbr': 'Black',
                    'normailPrice': 125,
                    'wholesalePrice': 80,
                    'discount': 0,
                    'stock': 2,
                  },
                ],
              },
            ];
      final controller = _controller(
        repository,
        Response(body: detail, statusCode: 200),
      );
      await controller.loadProductDetail(productId: 101);
      expect(controller.hasOptions, isTrue);
      expect(controller.canPurchase, isFalse);
      controller.selectSize(0);
      controller.selectColor(0);
      expect(controller.canPurchase, isTrue);
    });

    test('add-to-cart requires listingId', () {
      final controller = ProductControllerImp(
        categoriesRepository: repository,
        connectivityCheck: () async => true,
      );
      controller.itemView = Item.fromJson2(
        _persistedItem()..['listingId'] = null,
      );
      expect(controller.addToCart(), isFalse);
    });

    test('buy-now requires listingId', () {
      final controller = ProductControllerImp(
        categoriesRepository: repository,
        connectivityCheck: () async => true,
      );
      controller.itemView = Item.fromJson2(
        _persistedItem()..['listingId'] = null,
      );
      expect(controller.buyNow(), isFalse);
    });
  });
}

ProductControllerImp _controller(
  CategoriesRepository repository,
  Response response,
) => ProductControllerImp(
  categoriesRepository: repository,
  connectivityCheck: () async => true,
  detailLoader: (_) async {
    await Future<void>.delayed(Duration.zero);
    return response;
  },
);

class _FakeCategoriesRepository extends CategoriesRepository {
  _FakeCategoriesRepository({required super.apiClient});

  @override
  Future<Response> getCommintByCategoryId({required categoryId}) async =>
      const Response(body: {'rows': <dynamic>[]}, statusCode: 200);
}

Map<String, dynamic> _detail() => {
  'id': 101,
  'productId': 101,
  'listingId': 9001,
  'listingStatus': 'published',
  'readinessState': 'complete',
  'nameAr': 'دراجة',
  'nameEng': 'Bike',
  'nameAbree': 'Bike',
  'isShow': true,
  'descriptionAr': 'وصف',
  'descriptionEng': 'Description',
  'descriptionAbree': 'Description',
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
  'discount': 10,
  'userIdAdd': null,
  'dateAdd': '2026-10-06T00:00:00Z',
  'userIdUpdate': null,
  'dateUpdate': '2026-10-06T00:00:00Z',
  'supCategory': <dynamic>[],
  'normalImagesItems': <dynamic>[],
  '_3DImagesItems': <dynamic>[],
  'viewImagesItems': <dynamic>[],
  'itemSizes': <dynamic>[],
  'storefrontMedia': [_media(id: 1, main: true, order: 0)],
};

Map<String, dynamic> _media({
  required int id,
  required bool main,
  required int order,
  String sourceType = 'normal_image',
  Map<String, dynamic>? metadata,
}) => {
  'id': id,
  'source_type': sourceType,
  'source_id': id + 100,
  'path': '/media/$id',
  'media_metadata': metadata,
  'is_main': main,
  'is_visible': true,
  'sort_order': order,
};

Map<String, dynamic> _persistedItem() => {
  ..._detail(),
  'count': 1,
  'isSize': false,
  'itemSizeId': null,
  'itemSizeColorsStock': null,
  'itemSizediscount': null,
  'itemSizeColorsprice': null,
  'itemSizeColorId': null,
  'itemSizeColorSelect': null,
  'itemSizeSelect': null,
};
