import 'package:doctor_bike/controller/home/home_controller.dart';
import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/helper/search_history_store.dart';
import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/model/ads_response.dart';
import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:doctor_bike/core/model/main_categores_model.dart';
import 'package:doctor_bike/core/model/online_store_home_model.dart';
import 'package:doctor_bike/core/theme/light.dart';
import 'package:doctor_bike/core/theme/store_typography.dart';
import 'package:doctor_bike/core/widget/store_bottom_navigation.dart';
import 'package:doctor_bike/features/home_screen/home_page.dart';
import 'package:doctor_bike/features/home_screen/home_screen.dart';
import 'package:doctor_bike/features/search/search_screen.dart';
import 'package:doctor_bike/repository/home/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final cairo = FontLoader(StoreTypography.fontFamily)
      ..addFont(rootBundle.load('assets/font/Cairo-Variable.ttf'));
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await cairo.load();
    await materialIcons.load();
  });

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(Get.reset);

  testWidgets('shell is RTL, switches all tabs, and preserves tab state', (
    tester,
  ) async {
    final controller = await _controller(authenticated: true);
    final pages = <StoreDestination, Widget>{
      for (final destination in StoreDestination.values)
        destination: _RememberingPage(destination: destination),
    };

    await tester.pumpWidget(
      _TestApp(
        child: HomeScreen(
          controller: controller,
          destinationPages: pages,
          loadOnStart: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Directionality.of(tester.element(find.byType(HomeScreen))),
      TextDirection.rtl,
    );
    expect(find.byType(StoreBottomNavigation), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('الأقسام'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('categories-field')),
      'حالة محفوظة',
    );

    await tester.tap(find.bySemanticsLabel('الملف الشخصي'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('الأقسام'));
    await tester.pumpAndSettle();

    expect(find.text('حالة محفوظة'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('فتح البحث'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('search-discovery')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('إغلاق البحث'));
    await tester.pumpAndSettle();
    expect(find.text('حالة محفوظة'), findsOneWidget);
  });

  testWidgets('top bar avatar opens the profile destination', (tester) async {
    final controller = await _controller(authenticated: true);
    controller.categoriesState.value = const StoreContent(<Category>[]);
    await tester.pumpWidget(
      _TestApp(
        child: HomeScreen(
          controller: controller,
          destinationPages: {
            for (final destination in StoreDestination.values)
              destination: Center(child: Text('page-${destination.name}')),
          },
          loadOnStart: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('فتح الملف الشخصي'));
    await tester.pumpAndSettle();

    expect(controller.selectedDestination.value, StoreDestination.profile);
    expect(find.text('page-profile'), findsOneWidget);
  });

  testWidgets('shell remains usable at 320x568 with 1.3 text scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _controller(authenticated: true);

    await tester.pumpWidget(
      _TestApp(
        textScale: 1.3,
        child: HomeScreen(
          controller: controller,
          destinationPages: {
            for (final destination in StoreDestination.values)
              destination: Center(child: Text(destination.name)),
          },
          loadOnStart: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StoreBottomNavigation), findsOneWidget);
    expect(find.bySemanticsLabel('فتح البحث'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('فتح البحث'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('store-search-expanded')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const <Size>[Size(360, 800), Size(390, 844)]) {
    testWidgets(
      'Home/Search stays overflow-free at ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final controller = await _loadedController();

        await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        await tester.tap(find.bySemanticsLabel('فتح البحث'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('search-discovery')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('loaded Home renders the approved repository-backed sections', (
    tester,
  ) async {
    final controller = await _loadedController();
    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump();

    expect(find.byKey(const ValueKey('home-hero')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-quick-categories')), findsOneWidget);
    expect(find.text('الأكثر مبيعًا'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-store-categories')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('home-store-categories')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('وصل حديثًا'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('عروض خاصة'), findsOneWidget);
    expect(find.text('وصل حديثًا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home skeleton is distinct from loaded content', (tester) async {
    final controller = await _controller(authenticated: false);
    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('home-skeleton')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-hero')), findsNothing);
  });

  testWidgets('refresh feedback keeps retained Home content visible', (
    tester,
  ) async {
    final controller = await _loadedController();
    controller.isRefreshingHome.value = true;

    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const ValueKey('home-refresh-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-hero')), findsOneWidget);
    expect(find.text('جاري تحديث البيانات...'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home follows admin section order, titles, and custom sections', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _loadedController();
    final category = controller.mainCategoresModel.first;
    final product = controller.itemList.first;
    final sections = <OnlineStoreHomeSection>[
      const OnlineStoreHomeSection(
        id: 7,
        key: 'maintenance',
        type: 'maintenance',
        titles: {'ar': 'صيانة مرتبة من الأدمن'},
        items: <OnlineStoreHomeItem>[],
        config: {'destination': 'maintenance.request'},
      ),
      OnlineStoreHomeSection(
        id: 2,
        key: 'categories',
        type: 'categories',
        titles: const {'ar': 'تصنيفات يحددها الأدمن'},
        items: <OnlineStoreHomeItem>[
          OnlineStoreHomeItem(
            targetType: 'category',
            targetId: category.id,
            category: category,
          ),
        ],
        config: const {'selector': 'active_categories', 'limit': 10},
      ),
      OnlineStoreHomeSection(
        id: 3,
        key: 'featured',
        type: 'custom',
        titles: const {'ar': 'مختارات الأدمن'},
        items: <OnlineStoreHomeItem>[
          OnlineStoreHomeItem(
            targetType: 'listing',
            targetId: product.listingId,
            product: product,
          ),
        ],
        config: const {'selector': 'featured', 'limit': 10},
      ),
    ];
    controller.homeSections.assignAll(sections);
    controller.homeSectionsState.value = StoreContent(sections);

    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump(const Duration(milliseconds: 100));

    final maintenance = find.byKey(const ValueKey('home-admin-section-7'));
    final categories = find.byKey(const ValueKey('home-admin-section-2'));
    final custom = find.byKey(const ValueKey('home-admin-section-3'));
    expect(maintenance, findsOneWidget);
    expect(categories, findsOneWidget);
    expect(custom, findsOneWidget);
    expect(
      tester.getTopLeft(maintenance).dy,
      lessThan(tester.getTopLeft(categories).dy),
    );
    expect(
      tester.getTopLeft(categories).dy,
      lessThan(tester.getTopLeft(custom).dy),
    );
    expect(find.text('صيانة مرتبة من الأدمن'), findsOneWidget);
    expect(find.text('تصنيفات يحددها الأدمن'), findsOneWidget);
    expect(find.text('مختارات الأدمن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search no-results and offline states stay visually distinct', (
    tester,
  ) async {
    final controller = await _controller(authenticated: false);
    controller.searchState.value = const StoreEmpty<List<Item>>(
      title: 'لا توجد نتائج',
      message: 'لم نجد نتائج مطابقة لـ خوذة.',
    );

    await tester.pumpWidget(
      _TestApp(child: SearchScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.text('لا توجد نتائج'), findsOneWidget);
    expect(find.textContaining('خوذة'), findsOneWidget);
    expect(find.text('لا يوجد اتصال'), findsNothing);

    controller.searchState.value = const StoreOffline<List<Item>>(
      message: 'تحقق من الاتصال وحاول مرة أخرى.',
    );
    await tester.pump();
    expect(find.text('لا يوجد اتصال'), findsOneWidget);
    expect(find.text('لا توجد نتائج'), findsNothing);
  });

  testWidgets('Phase 5 loaded Home golden at the approved viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _loadedController();
    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/p05-home-loaded-ar-390x844.png'),
    );
  });

  testWidgets('Phase 5 Home skeleton golden at the approved viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _controller(authenticated: false);
    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump(const Duration(milliseconds: 100));

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/p05-home-skeleton-ar-390x844.png'),
    );
  });

  testWidgets('Phase 5 expanded search golden at the approved viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _loadedController();
    controller.recentSearches.assignAll(<String>['سكوتر', 'بطاريات', 'خوذة']);
    controller.openSearch();
    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump(const Duration(milliseconds: 100));
    controller.recentSearches.assignAll(<String>['سكوتر', 'بطاريات', 'خوذة']);
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/p05-search-expanded-ar-390x844.png'),
    );
  });

  testWidgets('Phase 5 search results golden at the approved viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _loadedController();
    controller.search.text = 'سكوتر';
    controller.searchState.value = StoreContent<List<Item>>(
      controller.itemList.toList(),
    );
    controller.openSearch();
    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/p05-search-results-ar-390x844.png'),
    );
  });

  testWidgets('Phase 5 no-results golden at the approved viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _controller(authenticated: false);
    controller.search.text = 'منتج غير موجود';
    controller.searchState.value = const StoreEmpty<List<Item>>(
      title: 'لا توجد نتائج',
      message: 'لم نجد نتائج مطابقة لـ منتج غير موجود.',
    );
    controller.openSearch();
    await tester.pumpWidget(_TestApp(child: _goldenShell(controller)));
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/p05-search-no-results-ar-390x844.png'),
    );
  });
}

Widget _goldenShell(HomeControllerImp controller) => HomeScreen(
  controller: controller,
  loadOnStart: false,
  destinationPages: <StoreDestination, Widget>{
    StoreDestination.home: HomePage(controller: controller),
    StoreDestination.categories: const SizedBox.shrink(),
    StoreDestination.orders: const SizedBox.shrink(),
    StoreDestination.favorites: const SizedBox.shrink(),
    StoreDestination.profile: const SizedBox.shrink(),
  },
);

Future<HomeControllerImp> _controller({required bool authenticated}) async {
  final preferences = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(preferences);
  final controller = HomeControllerImp(
    homeRepository: _FakeHomeDataSource(),
    searchHistoryStore: SearchHistoryStore(preferences: preferences),
    connectivityCheck: () async => true,
    tokenLoader: () async => authenticated ? 'token' : null,
    userNameLoader: () async => authenticated ? 'حازم أياد' : null,
  );
  await controller.initializeShell();
  return controller;
}

Future<HomeControllerImp> _loadedController() async {
  final controller = await _controller(authenticated: true);
  final categories = <Category>[
    _category(1, 'سكوترات'),
    _category(2, 'بطاريات'),
    _category(3, 'إطارات'),
    _category(4, 'إكسسوارات'),
    _category(5, 'قطع غيار'),
  ];
  final products = <Item>[
    _item(1, 'سكوتر كهربائي', price: 1350, discount: 10, isNew: true),
    _item(2, 'خوذة حماية', price: 120),
    _item(3, 'إطار 10 بوصة', price: 90, isNew: true),
  ];
  final ads = <Ad>[
    Ad(
      id: 1,
      title: 'سكوترات كهربائية بأفضل الأسعار',
      description: 'أداء قوي وتنقّل أسهل',
      urlAds: '',
      imgUrl: '',
      isShow: true,
      addDate: '',
      userAddId: '',
      updateDate: '',
      userUpdateId: '',
    ),
  ];
  controller.mainCategoresModel.assignAll(categories);
  controller.itemList.assignAll(products);
  controller.adsResponse.assignAll(ads);
  controller.categoriesState.value = StoreContent(categories);
  controller.productsState.value = StoreContent(products);
  controller.heroState.value = StoreContent(ads);
  return controller;
}

Category _category(int id, String name) => Category(
  id: id,
  nameAr: name,
  nameEng: name,
  nameAbree: name,
  imageUrl: '',
  isShow: true,
  userAdd: '',
  dateAdd: '',
  userEdit: '',
  dateEdit: '',
  children: const <Category>[],
);

Item _item(
  int id,
  String name, {
  required double price,
  double discount = 0,
  bool isNew = false,
}) => Item(
  id: id,
  productId: id,
  listingId: id + 100,
  listingStatus: 'published',
  readinessState: 'complete',
  available: true,
  purchasable: true,
  storefrontMedia: [
    StorefrontMedia(
      id: id,
      path: 'fixture.jpg',
      sourceType: 'normal_image',
      isMain: true,
      sortOrder: 0,
    ),
  ],
  nameAr: name,
  nameEng: name,
  nameAbree: name,
  isShow: true,
  descriptionAr: '',
  descriptionEng: '',
  descriptionAbree: '',
  normailPrice: price,
  wholesalePrice: price,
  stock: 4,
  model: 'DB-$id',
  isNewItem: isNew,
  isMoreSales: true,
  rate: 4.5,
  discount: discount,
  supCategory: const <SupCategory>[],
  normalImagesItems: const <NormalImageItem>[],
  images3DItems: const <NormalImageItem>[],
  viewImagesItems: const <NormalImageItem>[],
  itemSizes: const <ItemSize>[],
);

class _RememberingPage extends StatelessWidget {
  const _RememberingPage({required this.destination});

  final StoreDestination destination;

  @override
  Widget build(BuildContext context) => Center(
    child: TextField(
      key: ValueKey('${destination.name}-field'),
      decoration: InputDecoration(labelText: destination.name),
    ),
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScale = 1});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: light(),
    locale: const Locale('ar'),
    translations: MyLocale(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    ),
  );
}

class _FakeHomeDataSource implements HomeDataSource {
  @override
  Future<Response> getAllItemIsMoreSales() async => const Response(
    statusCode: 200,
    body: <String, Object>{'rows': <Object>[]},
  );

  @override
  Future<Response> getMainCategories() async => const Response(
    statusCode: 200,
    body: <String, Object>{'rows': <Object>[]},
  );

  @override
  Future<Response> getNotification() async => const Response(
    statusCode: 200,
    body: <String, Object>{'rows': <Object>[]},
  );

  @override
  Future<Response> getOnlineAds() async => const Response(
    statusCode: 200,
    body: <String, Object>{'rows': <Object>[]},
  );

  @override
  Future<Response> postNotificationIsRead(dynamic id) async =>
      const Response(statusCode: 200, body: true);

  @override
  Future<Response> search(dynamic name, dynamic lang) async => const Response(
    statusCode: 200,
    body: <String, Object>{'rows': <Object>[]},
  );
}
