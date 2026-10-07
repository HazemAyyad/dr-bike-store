import 'package:doctor_bike/controller/product/product_controller.dart';
import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/model/commint_model.dart';
import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:doctor_bike/core/model/product_media_model.dart';
import 'package:doctor_bike/core/theme/light.dart';
import 'package:doctor_bike/features/product/product_details_screen.dart';
import 'package:doctor_bike/features/product/widget/image_view.dart';
import 'package:doctor_bike/features/product/widget/product_360_view.dart';
import 'package:doctor_bike/features/product/widget/view_image_and_video.dart';
import 'package:doctor_bike/repository/categories/categories_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;

  setUpAll(() async {
    final cairo = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/font/Cairo-Variable.ttf'));
    await cairo.load();
  });

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
  });

  tearDown(Get.reset);

  testWidgets('one image shows 1/1 without misleading navigation', (
    tester,
  ) async {
    final controller = _controller(preferences, [_image(id: 1, main: true)]);

    await tester.pumpWidget(
      _app(ViewImageAndVideo(controllerScreen: controller)),
    );
    await tester.pump();

    expect(find.text('1/1'), findsOneWidget);
    expect(find.byKey(const Key('product-media-thumbnails')), findsNothing);
    expect(find.byKey(const Key('product-media-previous')), findsNothing);
    expect(find.byKey(const Key('product-media-next')), findsNothing);
  });

  testWidgets('mixed thumbnails change the selected main media', (
    tester,
  ) async {
    final media = <ProductMedia>[
      _image(id: 1, main: true),
      _image(id: 2),
      _interactive360(id: 3),
      _video(id: 4),
    ];
    final controller = _controller(preferences, media);

    await tester.pumpWidget(
      _app(ViewImageAndVideo(controllerScreen: controller)),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('product-media-thumbnail-1')));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(controller.selectedMediaIndex, 1);
    expect(controller.selectedMedia?.id, 2);
    await tester.pumpWidget(
      _app(ViewImageAndVideo(controllerScreen: controller)),
    );
    await tester.pump();
    expect(find.text('2/4'), findsOneWidget);
  });

  testWidgets('full viewer keeps all media and highlights selection', (
    tester,
  ) async {
    final media = <ProductMedia>[
      _image(id: 1, main: true),
      _image(id: 2),
      _interactive360(id: 3),
    ];

    await tester.pumpWidget(
      _app(ProductMediaViewer(media: media, initialIndex: 1)),
    );
    await tester.pump();

    expect(find.text('2/3'), findsOneWidget);
    expect(
      find.byKey(const Key('fullscreen-media-thumbnails')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('fullscreen-media-thumbnail-1')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('fullscreen-media-thumbnail-2')),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('3/3'), findsOneWidget);
  });

  testWidgets('360 media never pretends a real interactive viewer exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(Product360View(media: _interactive360(id: 3))),
    );
    await tester.pump();

    expect(find.byKey(const Key('product-360-unavailable')), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);
  });

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
  ]) {
    testWidgets(
      'product details has no layout exception at ${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final controller = _controller(preferences, [
          _image(id: 1, main: true),
          _image(id: 2),
        ]);
        Get.put<ProductControllerImp>(controller);

        await tester.pumpWidget(_app(const ProductDetailsScreen()));
        await tester.pump();

        expect(find.byKey(const Key('product-media-counter')), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byKey(const Key('product-quick-specifications')),
          120,
          scrollable:
              find
                  .descendant(
                    of: find.byKey(const Key('product-details-scroll')),
                    matching: find.byType(Scrollable),
                  )
                  .first,
        );
        expect(
          find.byKey(const Key('product-quick-specifications')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Widget _app(Widget child) => GetMaterialApp(
  translations: MyLocale(),
  locale: const Locale('ar'),
  fallbackLocale: const Locale('ar'),
  theme: light(),
  home: Scaffold(body: child),
);

ProductControllerImp _controller(
  SharedPreferences preferences,
  List<ProductMedia> media,
) {
  final item = Item.fromJson(_detail(media));
  final controller = ProductControllerImp(
    categoriesRepository: _FakeCategoriesRepository(
      apiClient: ApiClient(sharedPreferences: preferences),
    ),
    connectivityCheck: () async => true,
  );
  controller
    ..itemView = item
    ..identity = ProductIdentityState(
      productId: item.productId,
      listingId: item.listingId,
    )
    ..quantity = ProductQuantityState(maximum: item.stock)
    ..selectedMediaIndex = 0
    ..selectedImageIndex = 0
    ..selectedMedia = media.first
    ..productState = StoreContent<Item>(item)
    ..mediaState = StoreContent<List<ProductMedia>>(media)
    ..reviewsState = const StoreEmpty<List<Review>>(message: 'storeNoReviews')
    ..similarItemsState = const StoreEmpty<List<Item>>(
      message: 'storeNoSimilarProducts',
    );
  return controller;
}

class _FakeCategoriesRepository extends CategoriesRepository {
  _FakeCategoriesRepository({required super.apiClient});
}

ProductMedia _image({required int id, bool main = false}) => ProductMedia(
  id: id,
  path: 'https://example.com/image-$id.jpg',
  sourceType: 'normal_image',
  sourceId: id,
  type: ProductMediaType.image,
  isMain: main,
  isVisible: true,
  sortOrder: id - 1,
  metadata: const <String, dynamic>{'mime_type': 'image/jpeg'},
  mimeType: 'image/jpeg',
);

ProductMedia _video({required int id}) => ProductMedia(
  id: id,
  path: 'https://example.com/video-$id.mp4',
  sourceType: 'store_specific',
  sourceId: null,
  type: ProductMediaType.video,
  isMain: false,
  isVisible: true,
  sortOrder: id - 1,
  metadata: const <String, dynamic>{
    'media_type': 'video',
    'mime_type': 'video/mp4',
  },
  mimeType: 'video/mp4',
);

ProductMedia _interactive360({required int id}) => ProductMedia(
  id: id,
  path: 'https://example.com/spin-$id.jpg',
  sourceType: 'image3d',
  sourceId: id,
  type: ProductMediaType.interactive360,
  isMain: false,
  isVisible: true,
  sortOrder: id - 1,
  metadata: const <String, dynamic>{
    'media_type': 'interactive_360',
    'mime_type': 'image/jpeg',
    'is_360': true,
  },
  mimeType: 'image/jpeg',
);

Map<String, dynamic> _detail(List<ProductMedia> media) => <String, dynamic>{
  'id': 101,
  'productId': 101,
  'listingId': 9001,
  'listingStatus': 'published',
  'readinessState': 'complete',
  'nameAr': 'سكوتر كهربائي قابل للطي',
  'nameEng': 'Foldable electric scooter',
  'nameAbree': 'Foldable electric scooter',
  'isShow': true,
  'descriptionAr': 'وصف منتج معتمد من المتجر.',
  'descriptionEng': 'Authoritative product description.',
  'descriptionAbree': 'Authoritative product description.',
  'videoUrl': null,
  'normailPrice': 1350,
  'wholesalePrice': 0,
  'stock': 3,
  'available': true,
  'purchasable': true,
  'model': 'DB-01',
  'isNewItem': false,
  'isMoreSales': false,
  'rate': 4.6,
  'manufactureYear': 2026,
  'discount': 10,
  'userIdAdd': null,
  'dateAdd': '2026-10-07T00:00:00Z',
  'userIdUpdate': null,
  'dateUpdate': '2026-10-07T00:00:00Z',
  'supCategory': <dynamic>[],
  'normalImagesItems': <dynamic>[],
  '_3DImagesItems': <dynamic>[],
  'viewImagesItems': <dynamic>[],
  'itemSizes': <dynamic>[],
  'storefrontMedia': media.map((item) => item.toJson()).toList(),
};
