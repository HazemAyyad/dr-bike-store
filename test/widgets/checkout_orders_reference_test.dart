import 'dart:io';
import 'dart:async';

import 'package:doctor_bike/controller/order/order_controller.dart';
import 'package:doctor_bike/controller/shop/shop_controller.dart';
import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/model/checkout_flow_model.dart';
import 'package:doctor_bike/core/model/city_model.dart';
import 'package:doctor_bike/core/model/orders_model.dart';
import 'package:doctor_bike/core/theme/light.dart';
import 'package:doctor_bike/features/order/order_details_screen.dart';
import 'package:doctor_bike/features/order/order_screen.dart';
import 'package:doctor_bike/features/shop/check_out_done.dart';
import 'package:doctor_bike/features/shop/check_out_screen.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:doctor_bike/repository/shop/shop_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:doctor_bike/core/theme/store_typography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory storageDirectory;
  late SharedPreferences preferences;
  late ApiClient apiClient;

  setUpAll(() async {
    await (FontLoader(StoreTypography.fontFamily)
      ..addFont(rootBundle.load('assets/font/Cairo-Variable.ttf'))).load();
    await (FontLoader('NotoSansHebrew')..addFont(
      rootBundle.load('assets/font/NotoSansHebrew-Variable.ttf'),
    )).load();
    storageDirectory = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'doctor-bike-checkout-orders-reference-test',
    );
    await storageDirectory.create(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (_) async => storageDirectory.path,
        );
    await GetStorage.init('checkout-orders-reference-test');
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
    await GetStorage('checkout-orders-reference-test').erase();
  });

  tearDown(Get.reset);

  for (final status
      in {
        'confirmed': 'تم تأكيد الطلب',
        'with_delivery': 'مع شركة التوصيل',
      }.entries) {
    testWidgets(
      'current order shows actual ${status.key} status in list and details',
      (tester) async {
        final order = _order(salesOrderStatus: status.key);
        Get.put(
          OrderController(
              repository: _OrdersRepository(apiClient: apiClient),
              connectivityCheck: () async => true,
            )
            ..orders = [order]
            ..selectedOrder = order
            ..listStatus = OrderListStatus.content,
        );

        await _pumpAt(tester, const Size(390, 844), const OrderScreen());
        expect(find.text('#DB-2026-00123'), findsOneWidget);
        expect(find.text(status.value), findsOneWidget);
        expect(find.text('قيد التجهيز'), findsNothing);

        await _pumpAt(tester, const Size(390, 844), const OrderDetailsScreen());
        expect(find.text(status.value), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final language in ['ar', 'en', 'he']) {
    for (final night in [false, true]) {
      for (final stage in [
        CheckoutStage.address,
        CheckoutStage.shipping,
        CheckoutStage.payment,
        CheckoutStage.success,
      ]) {
        testWidgets(
          'checkout $stage in $language dark=$night fits 320px at 1.6 text scale',
          (tester) async {
            final controller = _shopController(apiClient);
            controller.checkoutState = CheckoutFlowState(
              stage: stage,
              selectedRole: 'customer',
              availableRoles: const ['customer'],
              orderId: '123',
              orderNumber: 'DB-123',
            );
            controller.nameController.text = 'Customer';
            controller.addressController.text = 'Delivery address';
            controller.selectedCity = 'City';
            controller.selectedCityId = '10';
            controller.selectedVillage = 'Village';
            controller.selectedVillageId = '20';
            controller.hasAuthoritativeDeliveryQuote = true;
            controller.selectedCityPrice = 20;
            await tester.binding.setSurfaceSize(const Size(320, 640));
            addTearDown(() => tester.binding.setSurfaceSize(null));
            await tester.pumpWidget(
              _TestApp(
                language: language,
                night: night,
                textScale: 1.6,
                child:
                    stage == CheckoutStage.success
                        ? const CheckOutDone()
                        : const CheckOutScreen(),
              ),
            );
            await tester.pumpAndSettle();
            final screen =
                stage == CheckoutStage.success
                    ? find.byType(CheckOutDone)
                    : find.byType(CheckOutScreen);
            final renderedContext = tester.element(
              find
                  .descendant(of: screen, matching: find.byType(Scaffold))
                  .first,
            );
            expect(
              Directionality.of(renderedContext),
              language == 'en' ? TextDirection.ltr : TextDirection.rtl,
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('new shipping retry wins even for the same village and price', (
    tester,
  ) async {
    final repository = _QuoteRepository(apiClient: apiClient);
    final controller = Get.put(
      ShopController(
        shopRepository: repository,
        storage: GetStorage('checkout-orders-reference-test'),
      ),
    );
    controller.selectedVillageId = '20';
    final first = controller.calculateDeliveryFeeForSelectedVillage();
    final latest = controller.calculateDeliveryFeeForSelectedVillage();
    repository.requests[1].complete(
      const Response(statusCode: 200, body: {'deliveryCost': 25}),
    );
    await latest;
    repository.requests[0].complete(
      const Response(statusCode: 200, body: {'deliveryCost': 0}),
    );
    await first;
    expect(controller.selectedCityPrice, 25);
    expect(controller.hasAuthoritativeDeliveryQuote, isTrue);
    expect(controller.isDeliveryLoading, isFalse);
  });

  testWidgets('an old failed quote cannot stop a newer quote loading', (
    tester,
  ) async {
    final repository = _QuoteRepository(apiClient: apiClient);
    final controller = Get.put(
      ShopController(
        shopRepository: repository,
        storage: GetStorage('checkout-orders-reference-test'),
      ),
    );
    controller.selectedVillageId = '20';
    final first = controller.calculateDeliveryFeeForSelectedVillage();
    final latest = controller.calculateDeliveryFeeForSelectedVillage();
    repository.requests[0].completeError(StateError('offline'));
    await first;
    expect(controller.isDeliveryLoading, isTrue);
    expect(controller.deliveryQuoteMessage, isNull);
    repository.requests[1].complete(
      const Response(statusCode: 200, body: {'deliveryCost': 0}),
    );
    await latest;
    expect(controller.selectedCityPrice, 0);
    expect(controller.hasAuthoritativeDeliveryQuote, isTrue);
  });

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
  ]) {
    testWidgets('checkout address is RTL, truthful, and fits $size', (
      tester,
    ) async {
      final controller = _shopController(apiClient);
      controller.checkoutState = const CheckoutFlowState(
        stage: CheckoutStage.address,
        selectedRole: 'customer',
        availableRoles: ['customer'],
      );
      controller.nameController.text = 'حازم إياد';
      controller.phoneNumberController.text = '+970591234567';
      controller.addressController.text = 'رام الله، شارع الإرسال';

      await _pumpAt(tester, size, const CheckOutScreen());

      expect(find.text('العنوان'), findsOneWidget);
      expect(find.text('عنوان الحساب'), findsOneWidget);
      await tester.fling(
        find.byKey(const PageStorageKey<String>('checkout-address-scroll')),
        const Offset(0, -700),
        1200,
      );
      await tester.pumpAndSettle();
      expect(find.text('متابعة الشحن'), findsOneWidget);
      final addressArrow = find.byIcon(Icons.arrow_forward_rounded);
      expect(addressArrow, findsOneWidget);
      expect(
        tester.getCenter(addressArrow).dx,
        lessThan(tester.getCenter(find.text('متابعة الشحن')).dx),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('checkout shipping exposes only Shiply and fits $size', (
      tester,
    ) async {
      final controller = _shopController(apiClient);
      controller.checkoutState = const CheckoutFlowState(
        stage: CheckoutStage.shipping,
        selectedRole: 'customer',
        availableRoles: ['customer'],
      );
      controller.cities = [_city()];
      controller.villages = [_village()];
      controller.selectedCityId = '10';
      controller.selectedCity = 'رام الله';
      controller.selectedVillageId = '20';
      controller.selectedVillage = 'الماصيون';
      controller.selectedCityPrice = 20;
      controller.hasAuthoritativeDeliveryQuote = true;

      await _pumpAt(tester, size, const CheckOutScreen());

      expect(find.text('التوصيل عبر Shiply'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('متابعة الدفع'),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('متابعة الدفع'), findsOneWidget);
      final shippingArrow = find.byIcon(Icons.arrow_forward_rounded);
      expect(shippingArrow, findsOneWidget);
      expect(
        tester.getCenter(shippingArrow).dx,
        lessThan(tester.getCenter(find.text('متابعة الدفع')).dx),
      );
      expect(find.textContaining('استلام من الفرع'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('checkout payment is COD-only and fits $size', (tester) async {
      final controller = _shopController(apiClient);
      controller.checkoutState = const CheckoutFlowState(
        stage: CheckoutStage.payment,
        selectedRole: 'customer',
        availableRoles: ['customer'],
      );
      controller.selectedCity = 'رام الله';
      controller.selectedVillage = 'الماصيون';
      controller.addressController.text = 'شارع الإرسال';

      await _pumpAt(tester, size, const CheckOutScreen());

      expect(find.text('الدفع عند الاستلام'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('تأكيد وإنشاء الطلب'),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('تأكيد وإنشاء الطلب'), findsOneWidget);
      expect(find.textContaining('Visa'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('orders list is compact and fits $size', (tester) async {
      final controller = Get.put(
        OrderController(
            repository: _OrdersRepository(apiClient: apiClient),
            connectivityCheck: () async => true,
          )
          ..orders = [_order()]
          ..listStatus = OrderListStatus.content,
      );

      await _pumpAt(tester, size, const OrderScreen());

      expect(find.text('طلباتي'), findsWidgets);
      expect(find.text('#DB-2026-00123'), findsOneWidget);
      expect(find.text('قيد التجهيز'), findsWidgets);
      expect(controller.orders.single.grandTotal, 90);
      expect(tester.takeException(), isNull);
    });

    testWidgets('order details and tracking fit $size', (tester) async {
      final order = _order();
      Get.put(
        OrderController(
          repository: _OrdersRepository(apiClient: apiClient),
          connectivityCheck: () async => true,
        )..selectedOrder = order,
      );

      await _pumpAt(tester, size, const OrderDetailsScreen());

      expect(find.text('تفاصيل الطلب'), findsOneWidget);
      await tester.drag(
        find.byKey(const PageStorageKey<String>('order-details-scroll')),
        const Offset(0, -500),
      );
      await tester.pump();
      expect(find.text('ملخص الدفع'), findsOneWidget);
      await tester.fling(
        find.byKey(const PageStorageKey<String>('order-details-scroll')),
        const Offset(0, -1200),
        1400,
      );
      await tester.pumpAndSettle();
      expect(find.text('تتبع الشحنة'), findsWidgets);
      expect(find.text('في الطريق'), findsOneWidget);
      expect(find.text('طلب إلغاء الطلب'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('authoritative success screen fits $size', (tester) async {
      final controller = _shopController(apiClient);
      controller.checkoutState = const CheckoutFlowState(
        stage: CheckoutStage.success,
        orderId: '123',
        orderNumber: 'DB-2026-00123',
      );

      await _pumpAt(tester, size, const CheckOutDone());

      expect(find.text('تم إنشاء طلبك'), findsOneWidget);
      expect(find.text('#DB-2026-00123'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

ShopController _shopController(ApiClient apiClient) => Get.put(
  ShopController(
    shopRepository: ShopRepository(apiClient: apiClient),
    storage: GetStorage('checkout-orders-reference-test'),
  ),
);

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_TestApp(child: child));
  await tester.pump();
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.language = 'ar',
    this.night = false,
    this.textScale = 1,
  });

  final Widget child;
  final String language;
  final bool night;
  final double textScale;

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: night ? dark() : light(),
    locale: Locale(language),
    supportedLocales: const [Locale('ar'), Locale('en'), Locale('he')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder:
        (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
    translations: MyLocale(),
    home: child,
  );
}

Citys _city() => Citys(
  id: 10,
  cityNameAr: 'رام الله',
  cityNameEng: 'Ramallah',
  cityNameAbree: 'Ramallah',
  deliver: 20,
  isShow: true,
  dateAdd: '',
  dateUpdate: '',
);

ShiplyVillage _village() =>
    ShiplyVillage(id: 20, name: 'الماصيون', isClosed: false);

Order _order({String? salesOrderStatus}) => Order.fromJson({
  'id': 123,
  'serialNumber': 'DB-2026-00123',
  'orderNumber': 'DB-2026-00123',
  'customerId': '7',
  'customerName': 'حازم إياد',
  'phoneNum1': '+970591234567',
  'phoneNum2': '',
  'cityId': 10,
  'address': 'رام الله، شارع الإرسال',
  'status': 'New',
  'salesOrderStatus': salesOrderStatus,
  'isWholesale': false,
  'priceDelivery': 20,
  'totalPriceWithDiscound': 75,
  'totalPriceWithOutDiscound': 80,
  'discoundCodeId': '3',
  'discoundCodePercent': 5,
  'discoundCode': 'SAVE',
  'totalPriceWithDiscoundCode': 70,
  'userAddId': '7',
  'dateAdd': '2026-09-30T14:25:00Z',
  'userUpdate': '',
  'dateUpdate': '2026-09-30T14:25:00Z',
  'latestHandover': {
    'id': 2,
    'deliveryCompanyName': 'Shiply',
    'deliveryCompanyCode': 'shiply',
    'trackingNumber': 'TRK-1',
    'carrierContactName': '',
    'carrierContactPhone': '',
    'carrierOfficeName': '',
    'carrierVehicleNumber': '',
    'shiplyParcelCode': 'P-1',
    'handedOverAt': '2026-09-30T15:00:00Z',
    'deliveredAt': '',
  },
  'statusLogs': [
    {
      'fromStatus': '',
      'toStatus': 'New',
      'note': '',
      'userName': '',
      'createdAt': '2026-09-30T14:25:00Z',
    },
  ],
  'shiplyTracking': {
    'parcelCode': 'P-1',
    'shiplyMode': 'live',
    'currentStatusId': 3,
    'currentStatusKey': 'on_the_way',
    'currentStatusLabel': 'في الطريق',
    'statusSequence': [1, 2, 3, 6],
    'events': [
      {
        'id': 1,
        'parcelStatusId': 1,
        'statusKey': 'draft',
        'statusLabel': 'تم إنشاء الشحنة',
        'note': '',
        'source': 'api',
        'occurredAt': '2026-09-30T14:30:00Z',
      },
      {
        'id': 2,
        'parcelStatusId': 3,
        'statusKey': 'on_the_way',
        'statusLabel': 'في الطريق',
        'note': '',
        'source': 'webhook',
        'occurredAt': '2026-10-01T08:00:00Z',
      },
    ],
  },
  'details': [
    {
      'id': 10,
      'orderId': 123,
      'itemId': 5,
      'isOrderSize': false,
      'itemSizeColorId': null,
      'itemSizeId': null,
      'quantity': 2,
      'itemPrice': 40,
      'totalPriceWithDiscound': 75,
      'totalPriceWithOutDiscound': 80,
      'item': {
        'id': 5,
        'nameAr': 'سكوتر كهربائي قابل للطي',
        'nameEng': 'Scooter',
        'nameAbree': 'Scooter',
        'isShow': true,
        'descriptionAr': '',
        'descriptionEng': '',
        'descriptionAbree': '',
        'normailPrice': 999,
        'wholesalePrice': 500,
        'stock': 0,
        'model': 'DB-01',
        'isNewItem': false,
        'isMoreSales': false,
        'rate': 0,
        'manufactureYear': 0,
        'discount': 0,
        'dateAdd': '',
        'dateUpdate': '',
        'viewImagesItems': <dynamic>[],
        'itemSizes': <dynamic>[],
      },
    },
  ],
});

class _OrdersRepository extends AuthRepository {
  _OrdersRepository({required super.apiClient});
}

class _QuoteRepository extends ShopRepository {
  _QuoteRepository({required super.apiClient});
  final requests = <Completer<Response>>[];
  @override
  Future<Response> calculateDeliveryFee({
    required String villageId,
    required double price,
  }) {
    final pending = Completer<Response>();
    requests.add(pending);
    return pending.future;
  }
}
