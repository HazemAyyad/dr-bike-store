import 'dart:async';

import 'package:doctor_bike/controller/home/home_controller.dart';
import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/helper/search_history_store.dart';
import 'package:doctor_bike/core/constants/app_constants.dart';
import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:doctor_bike/core/widget/store_bottom_navigation.dart';
import 'package:doctor_bike/repository/home/home_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(preferences);
  });

  tearDown(Get.reset);

  test('shell exposes exactly the five approved destinations', () {
    expect(StoreDestination.values, const <StoreDestination>[
      StoreDestination.home,
      StoreDestination.categories,
      StoreDestination.orders,
      StoreDestination.favorites,
      StoreDestination.profile,
    ]);
  });

  test('guest gates orders and favorites without losing current tab', () async {
    final controller = _controller(preferences, authenticated: false);
    await controller.initializeShell();
    await controller.selectDestination(StoreDestination.categories);

    expect(
      await controller.selectDestination(StoreDestination.orders),
      ShellNavigationOutcome.loginRequired,
    );
    expect(controller.selectedDestination.value, StoreDestination.categories);

    expect(
      await controller.selectDestination(StoreDestination.favorites),
      ShellNavigationOutcome.loginRequired,
    );
    expect(controller.selectedDestination.value, StoreDestination.categories);

    expect(
      await controller.selectDestination(StoreDestination.profile),
      ShellNavigationOutcome.selected,
    );
  });

  test(
    'authenticated users can open the server-backed favorites tab',
    () async {
      final controller = _controller(preferences, authenticated: true);
      await controller.initializeShell();

      expect(
        await controller.selectDestination(StoreDestination.favorites),
        ShellNavigationOutcome.selected,
      );
      expect(controller.selectedDestination.value, StoreDestination.favorites);
    },
  );

  test(
    'back closes search then returns to home before leaving shell',
    () async {
      final controller = _controller(preferences, authenticated: true);
      await controller.initializeShell();
      await controller.selectDestination(StoreDestination.categories);
      controller.openSearch();

      expect(await controller.handleShellBack(), isTrue);
      expect(controller.isSearchExpanded.value, isFalse);
      expect(controller.selectedDestination.value, StoreDestination.categories);

      expect(await controller.handleShellBack(), isTrue);
      expect(controller.selectedDestination.value, StoreDestination.home);
      expect(await controller.handleShellBack(), isFalse);
    },
  );

  test(
    'selected destination survives search but a cold start returns home',
    () async {
      var controller = _controller(preferences, authenticated: true);
      await controller.initializeShell();
      await controller.selectDestination(StoreDestination.categories);
      controller.openSearch();
      controller.closeSearch();

      expect(controller.selectedDestination.value, StoreDestination.categories);

      await preferences.setString(
        HomeControllerImp.shellDestinationPreferenceKey,
        StoreDestination.categories.name,
      );
      controller = _controller(preferences, authenticated: true);
      await controller.initializeShell();
      expect(controller.selectedDestination.value, StoreDestination.home);
      expect(
        preferences.containsKey(
          HomeControllerImp.shellDestinationPreferenceKey,
        ),
        isFalse,
      );
    },
  );

  test('recent queries trim, deduplicate, cap, persist, and clear', () async {
    final store = SearchHistoryStore(preferences: preferences, maxEntries: 3);

    await store.add('  بطاريات  ');
    await store.add('سكوتر');
    await store.add('بطاريات');
    await store.add('إطارات');
    await store.add('   ');

    expect(await store.load(), <String>['إطارات', 'بطاريات', 'سكوتر']);

    final restored = SearchHistoryStore(
      preferences: preferences,
      maxEntries: 3,
    );
    expect(await restored.load(), <String>['إطارات', 'بطاريات', 'سكوتر']);

    await restored.clear();
    expect(await store.load(), isEmpty);
  });

  test(
    'public Home and Search cards never infer wholesale display pricing from typeUser',
    () async {
      final controller = _controller(preferences, authenticated: true);
      final item = _item(retailPrice: 125, wholesalePrice: 80);

      for (final legacyType in <String>['User', 'Normail', 'admin', '']) {
        await preferences.setString(AppConstants.typeUser, legacyType);
        await controller.initializeShell();
        expect(controller.displayPriceFor(item), 125);
      }
    },
  );

  test(
    'search keeps no-results, server failure, and offline distinct',
    () async {
      final dataSource = _FakeHomeDataSource(
        searchResponses: <Response>[
          const Response(
            statusCode: 200,
            body: <String, Object>{'rows': <Object>[]},
          ),
          const Response(statusCode: 500, body: <String, Object>{}),
        ],
      );
      var online = true;
      final controller = HomeControllerImp(
        homeRepository: dataSource,
        searchHistoryStore: SearchHistoryStore(preferences: preferences),
        connectivityCheck: () async => online,
        tokenLoader: () async => null,
      );
      await controller.initializeShell();

      await controller.submitSearch('خوذة');
      expect(controller.searchState.value, isA<StoreEmpty<List<dynamic>>>());

      await controller.submitSearch('فرامل');
      expect(controller.searchState.value, isA<StoreError<List<dynamic>>>());

      online = false;
      await controller.submitSearch('إطار');
      expect(controller.searchState.value, isA<StoreOffline<List<dynamic>>>());
    },
  );

  test(
    'typing one character triggers debounced suggestions without saving history',
    () async {
      final dataSource = _FakeHomeDataSource(
        searchResponses: <Response>[
          const Response(
            statusCode: 200,
            body: <String, Object>{'rows': <Object>[]},
          ),
        ],
      );
      final controller = HomeControllerImp(
        homeRepository: dataSource,
        searchHistoryStore: SearchHistoryStore(preferences: preferences),
        connectivityCheck: () async => true,
        tokenLoader: () async => null,
      );

      controller.searchAsYouType('ب');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(dataSource.searchQueries, <String>['ب']);
      expect(controller.searchState.value, isA<StoreEmpty<List<Item>>>());
      expect(await controller.searchHistoryStore.load(), isEmpty);
    },
  );

  test('closing search cancels a pending debounced query', () async {
    final dataSource = _FakeHomeDataSource();
    final controller = HomeControllerImp(
      homeRepository: dataSource,
      searchHistoryStore: SearchHistoryStore(preferences: preferences),
      connectivityCheck: () async => true,
      tokenLoader: () async => null,
    );

    controller.openSearch();
    controller.searchAsYouType('بطارية');
    controller.closeSearch();
    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(dataSource.searchQueries, isEmpty);
    expect(controller.search.text, isEmpty);
    expect(controller.itemListSearch, isEmpty);
    expect(controller.searchState.value, isA<StoreInitial<List<Item>>>());
    expect(controller.isLoadingSearch.value, isFalse);
  });

  test('closing search ignores a response already in flight', () async {
    final response = Completer<Response>();
    final requestStarted = Completer<void>();
    final dataSource = _FakeHomeDataSource(
      searchHandler: (query) {
        if (!requestStarted.isCompleted) requestStarted.complete();
        return response.future;
      },
    );
    final controller = HomeControllerImp(
      homeRepository: dataSource,
      searchHistoryStore: SearchHistoryStore(preferences: preferences),
      connectivityCheck: () async => true,
      tokenLoader: () async => null,
    );

    controller.openSearch();
    final search = controller.submitSearch('سكوتر');
    await requestStarted.future;
    expect(controller.searchState.value, isA<StoreLoading<List<Item>>>());

    controller.closeSearch();
    response.complete(
      const Response(
        statusCode: 200,
        body: <String, Object>{'rows': <Object>[]},
      ),
    );
    await search;

    expect(controller.isSearchExpanded.value, isFalse);
    expect(controller.search.text, isEmpty);
    expect(controller.itemListSearch, isEmpty);
    expect(controller.searchState.value, isA<StoreInitial<List<Item>>>());
    expect(controller.isLoadingSearch.value, isFalse);
  });

  test(
    'pull refresh exposes progress and preserves retained Home content on failure',
    () async {
      final connectivity = Completer<bool>();
      final controller = HomeControllerImp(
        homeRepository: _FakeHomeDataSource(),
        searchHistoryStore: SearchHistoryStore(preferences: preferences),
        connectivityCheck: () => connectivity.future,
        tokenLoader: () async => null,
      );
      final retained = _item(retailPrice: 125, wholesalePrice: 80);
      controller.itemList.assignAll(<Item>[retained]);
      controller.productsState.value = StoreContent<List<Item>>([retained]);

      final refresh = controller.loadHome(refresh: true);
      await Future<void>.delayed(Duration.zero);
      expect(controller.isRefreshingHome.value, isTrue);
      expect(controller.itemList, contains(retained));

      connectivity.complete(false);
      await refresh;

      expect(controller.isRefreshingHome.value, isFalse);
      expect(controller.itemList, contains(retained));
      final state = controller.productsState.value;
      expect(state, isA<StoreOffline<List<Item>>>());
      expect(
        (state as StoreOffline<List<Item>>).previousData,
        contains(retained),
      );
    },
  );
}

HomeControllerImp _controller(
  SharedPreferences preferences, {
  required bool authenticated,
}) => HomeControllerImp(
  homeRepository: _FakeHomeDataSource(),
  searchHistoryStore: SearchHistoryStore(preferences: preferences),
  connectivityCheck: () async => true,
  tokenLoader: () async => authenticated ? 'token' : null,
);

Item _item({required double retailPrice, required double wholesalePrice}) =>
    Item(
      id: 1,
      productId: 1,
      listingId: 101,
      listingStatus: 'published',
      readinessState: 'complete',
      available: true,
      purchasable: true,
      storefrontMedia: const [
        StorefrontMedia(
          id: 1,
          path: 'fixture.jpg',
          sourceType: 'normal_image',
          isMain: true,
          sortOrder: 0,
        ),
      ],
      nameAr: 'منتج',
      nameEng: 'Product',
      nameAbree: 'Product',
      isShow: true,
      descriptionAr: '',
      descriptionEng: '',
      descriptionAbree: '',
      normailPrice: retailPrice,
      wholesalePrice: wholesalePrice,
      stock: 1,
      model: 'DB-1',
      isNewItem: false,
      isMoreSales: true,
      rate: 4,
      discount: 0,
      supCategory: const <SupCategory>[],
      normalImagesItems: const <NormalImageItem>[],
      images3DItems: const <NormalImageItem>[],
      viewImagesItems: const <NormalImageItem>[],
      itemSizes: const <ItemSize>[],
    );

class _FakeHomeDataSource implements HomeDataSource {
  _FakeHomeDataSource({List<Response>? searchResponses, this.searchHandler})
    : _searchResponses = searchResponses ?? <Response>[];

  final List<Response> _searchResponses;
  final Future<Response> Function(String query)? searchHandler;
  final List<String> searchQueries = <String>[];

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
  Future<Response> getOnlineAds() async => const Response(
    statusCode: 200,
    body: <String, Object>{'rows': <Object>[]},
  );

  @override
  Future<Response> getNotification() async => const Response(
    statusCode: 200,
    body: <String, Object>{'rows': <Object>[]},
  );

  @override
  Future<Response> postNotificationIsRead(dynamic id) async =>
      const Response(statusCode: 200, body: true);

  @override
  Future<Response> search(dynamic name, dynamic lang) async {
    final query = name.toString();
    searchQueries.add(query);
    if (searchHandler != null) return searchHandler!(query);
    return _searchResponses.removeAt(0);
  }
}
