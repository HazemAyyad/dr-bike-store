import 'dart:io';

import 'package:doctor_bike/controller/categores/categores_controller.dart';
import 'package:doctor_bike/controller/shop/shop_controller.dart';
import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/model/cart_line_model.dart';
import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:doctor_bike/core/theme/light.dart';
import 'package:doctor_bike/features/category/category_screen.dart';
import 'package:doctor_bike/features/category/filter_screen.dart';
import 'package:doctor_bike/features/shop/shop_car_screen.dart';
import 'package:doctor_bike/repository/categories/categories_repository.dart';
import 'package:doctor_bike/repository/shop/shop_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late SharedPreferences preferences;
  late ApiClient apiClient;
  late Directory storageDirectory;

  setUpAll(() async {
    storageDirectory = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'doctor-bike-catalog-cart-reference-test',
    );
    await storageDirectory.create(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (_) async => storageDirectory.path,
        );
    await GetStorage.init('catalog-cart-reference-test');
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(preferences);
    apiClient = ApiClient(sharedPreferences: preferences);
    Get.put<ApiClient>(apiClient);
    await GetStorage('catalog-cart-reference-test').erase();
  });

  tearDown(Get.reset);

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
  ]) {
    testWidgets('working filter sheet fits $size', (tester) async {
      Get.put<CategoresControllerImp>(
        CategoresControllerImp(
          categoriesRepository: CategoriesRepository(apiClient: apiClient),
        ),
      );
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const _TestApp(child: FilterPage()));
      await tester.pumpAndSettle();

      expect(find.text('تصفية المنتجات'), findsOneWidget);
      expect(find.text('تطبيق الفلاتر'), findsOneWidget);
      expect(find.text('المنتجات المتاحة للشراء فقط'), findsOneWidget);
      expect(find.text('العروض والخصومات فقط'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('product listing remains compact and fits $size', (
      tester,
    ) async {
      final controller = CategoresControllerImp(
        categoriesRepository: CategoriesRepository(apiClient: apiClient),
        titleMain: 'سكوترات كهربائية',
      );
      controller.catalogState.value = StoreContent<List<Item>>([
        _item(),
        _item(productId: 102, listingId: 9002, discount: 0),
      ]);
      controller.itemList = ItemsResponse(
        rows: (controller.catalogState.value as StoreContent<List<Item>>).data,
      );
      Get.put<CategoresControllerImp>(controller);
      Get.put<ShopController>(
        ShopController(
          shopRepository: ShopRepository(apiClient: apiClient),
          storage: GetStorage('catalog-cart-reference-test'),
        ),
      );

      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const _TestApp(child: CategoryScreen()));
      await tester.pump();

      expect(find.text('قائمة المنتجات'), findsOneWidget);
      expect(find.text('تصفية (0)'), findsOneWidget);
      expect(find.byIcon(Icons.add_shopping_cart_rounded), findsWidgets);
      expect(find.text('-10.0%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cart preserves identity controls and fits $size', (
      tester,
    ) async {
      final controller = Get.put(
        ShopController(
          shopRepository: ShopRepository(apiClient: apiClient),
          storage: GetStorage('catalog-cart-reference-test'),
        ),
      );
      final item = _item()..count = 2;
      controller.cartLines.assignAll([CartLine.fromItem(item)]);
      controller.items.assignAll([item]);
      controller.cal();

      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const _TestApp(child: ShopCarScreen()));
      await tester.pump();

      expect(
        controller.addItem(
          _item(productId: 102, listingId: 9002, discount: 0),
          closeAfterAdd: false,
        ),
        isTrue,
      );
      await tester.pump();

      expect(find.textContaining('سلة المشتريات'), findsOneWidget);
      expect(controller.cartLines, hasLength(2));
      expect(find.text('إتمام الطلب'), findsOneWidget);
      expect(find.bySemanticsLabel('زيادة الكمية'), findsNWidgets(2));
      expect(find.text('خصم المنتجات'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: light(),
    locale: const Locale('ar'),
    translations: MyLocale(),
    home: child,
  );
}

Item _item({int productId = 101, int listingId = 9001, double discount = 10}) =>
    Item.fromJson2({
      'id': productId,
      'productId': productId,
      'listingId': listingId,
      'listingStatus': 'published',
      'readinessState': 'complete',
      'nameAr': 'سكوتر كهربائي قابل للطي',
      'nameEng': 'Electric scooter',
      'nameAbree': 'Electric scooter',
      'isShow': true,
      'descriptionAr': '',
      'descriptionEng': '',
      'descriptionAbree': '',
      'videoUrl': null,
      'normailPrice': 1500.0,
      'wholesalePrice': 1000.0,
      'stock': 4,
      'available': true,
      'purchasable': true,
      'model': 'DB-01',
      'isNewItem': false,
      'isMoreSales': false,
      'rate': 4.6,
      'manufactureYear': null,
      'discount': discount,
      'userIdAdd': null,
      'dateAdd': '2026-10-07T00:00:00Z',
      'userIdUpdate': null,
      'dateUpdate': '2026-10-07T00:00:00Z',
      'supCategory': <dynamic>[],
      'normalImagesItems': <dynamic>[],
      '_3DImagesItems': <dynamic>[],
      'viewImagesItems': <dynamic>[],
      'itemSizes': <dynamic>[],
      'storefrontMedia': <dynamic>[],
      'count': 1,
      'isSize': false,
      'itemSizeId': null,
      'itemSizeColorsStock': null,
      'itemSizediscount': null,
      'itemSizeColorsprice': null,
      'itemSizeColorId': null,
      'itemSizeColorSelect': null,
      'itemSizeSelect': null,
    });
