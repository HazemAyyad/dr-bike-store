import 'dart:async';

import 'package:doctor_bike/controller/order/order_controller.dart';
import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/model/orders_model.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late _OrdersRepository repository;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    repository = _OrdersRepository(
      apiClient: ApiClient(sharedPreferences: preferences),
    );
  });

  test(
    'parses Done order',
    () => expect(_order('Done').statusKind, StoreOrderStatusKind.completed),
  );
  test(
    'parses New order',
    () => expect(_order('New').statusKind, StoreOrderStatusKind.current),
  );
  test(
    'parses Canceled order',
    () => expect(_order('Canceled').statusKind, StoreOrderStatusKind.canceled),
  );
  test('preserves unknown status safely', () {
    final order = _order('Custom');
    expect(order.rawStatus, 'Custom');
    expect(order.statusKind, StoreOrderStatusKind.unknown);
  });
  test(
    'historical line unit price retained',
    () => expect(_order('Done').details.single.itemPrice, 40),
  );
  test(
    'historical line total retained',
    () => expect(_order('Done').details.single.totalPriceWithDiscound, 75),
  );
  test(
    'order subtotal retained',
    () => expect(_order('Done').totalPriceWithOutDiscound, 80),
  );
  test(
    'order discount total retained',
    () => expect(_order('Done').totalPriceWithDiscound, 75),
  );
  test('delivery fee retained', () => expect(_order('Done').priceDelivery, 12));
  test('authoritative grand total includes delivery', () {
    expect(_order('Done').grandTotal, 82);
    expect(_order('Done').discountTotal, 10);
  });
  test(
    'coupon snapshot retained',
    () => expect(_order('Done').totalPriceWithDiscoundCode, 70),
  );
  test(
    'current product price never recalculates history',
    () => expect(_order('Done').details.single.item.normailPrice, 999),
  );
  test(
    'normal product image is preferred for order thumbnails',
    () => expect(
      _order('Done').details.single.item.primaryImageUrl,
      '/media/thumb.jpg',
    ),
  );
  test(
    'missing optional handover tolerated',
    () => expect(_order('Done', handover: false).latestHandover, isNull),
  );
  test(
    'handover parsed',
    () => expect(_order('Done').latestHandover?.trackingNumber, 'TRK'),
  );
  test(
    'status logs parsed',
    () => expect(_order('Done').statusLogs, hasLength(2)),
  );
  test(
    'status logs chronological',
    () => expect(_order('Done').statusLogs.first.toStatus, 'New'),
  );
  test(
    'Shiply tracking parsed',
    () => expect(_order('Done').shiplyTracking?.parcelCode, 'P1'),
  );
  test(
    'Shiply events chronological',
    () => expect(_order('Done').shiplyTracking?.events.first.parcelStatusId, 1),
  );
  test(
    'unknown Shiply status retained neutrally',
    () =>
        expect(_order('Done').shiplyTracking?.events.last.statusKey, 'mystery'),
  );
  test(
    'missing Shiply tracking tolerated',
    () => expect(_order('Done', tracking: false).shiplyTracking, isNull),
  );
  test(
    'invalid order identity rejected',
    () => expect(
      () => Order.fromJson(_json('New')..['id'] = 0),
      throwsFormatException,
    ),
  );

  test('loading state', () async {
    final c = _controller(repository);
    repository.pending = true;
    final future = c.load();
    await Future<void>.delayed(Duration.zero);
    expect(c.listStatus, OrderListStatus.loading);
    repository.complete();
    await future;
  });
  test('empty state', () async {
    repository.body = {'rows': []};
    final c = _controller(repository);
    await c.load();
    expect(c.listStatus, OrderListStatus.empty);
  });
  test('offline state', () async {
    final c = OrderController(
      repository: repository,
      connectivityCheck: () async => false,
    );
    await c.load();
    expect(c.listStatus, OrderListStatus.offline);
  });
  test('error state', () async {
    repository.status = 500;
    final c = _controller(repository);
    await c.load();
    expect(c.listStatus, OrderListStatus.error);
  });
  test('content state', () async {
    final c = _controller(repository);
    await c.load();
    expect(c.listStatus, OrderListStatus.content);
  });
  test('refresh preserves truthful content', () async {
    final c = _controller(repository);
    await c.refreshOrders();
    expect(c.orders.single.id, 1);
  });
  test('filter Done', () async {
    final c = _controller(repository);
    await c.load(filter: OrderListFilter.completed);
    expect(repository.lastStatus, 'Done');
  });
  test('filter New', () async {
    final c = _controller(repository);
    await c.load(filter: OrderListFilter.current);
    expect(repository.lastStatus, 'New');
  });
  test('filter Canceled', () async {
    final c = _controller(repository);
    await c.load(filter: OrderListFilter.canceled);
    expect(repository.lastStatus, 'Canceled');
  });
  test('cancellation requires confirmation boundary', () async {
    final c = _controller(repository);
    final result = await c.requestCancellation(_order('New'), confirmed: false);
    expect(result, isFalse);
    expect(repository.cancelCalls, 0);
  });
  test('cancellation never optimistically mutates', () async {
    final original = _order('New');
    repository.cancelStatus = 500;
    final c =
        _controller(repository)
          ..orders = [original]
          ..selectedOrder = original;
    await c.requestCancellation(original, confirmed: true);
    expect(c.selectedOrder, same(original));
  });
  test('cancellation failure leaves order intact', () async {
    final original = _order('New');
    repository.cancelStatus = 500;
    final c = _controller(repository)..orders = [original];
    await c.requestCancellation(original, confirmed: true);
    expect(c.orders.single.rawStatus, 'New');
  });
  test('successful cancellation replaces from server', () async {
    final original = _order('New');
    repository.cancelBody = {'data': _json('Canceled')};
    final c = _controller(repository)..orders = [original];
    expect(await c.requestCancellation(original, confirmed: true), isTrue);
    expect(c.orders.single.rawStatus, 'Canceled');
  });
  test('ownership remains backend authority', () async {
    final c = _controller(repository);
    await c.load();
    expect(repository.lastStatus, 'New');
  });
  test('tracking requires authoritative tracking data', () {
    final c = _controller(repository);
    expect(c.canTrack(_order('New')), isTrue);
    expect(
      c.canTrack(_order('New', handover: false, tracking: false)),
      isFalse,
    );
  });
  test('reorder unsupported', () {
    expect(_controller(repository).canReorder(_order('Done')), isFalse);
  });
  test('share unsupported without stable contract', () {
    expect(_controller(repository).canShare(_order('Done')), isFalse);
  });
  test('edit address unsupported', () {
    expect(_controller(repository).canEditAddress(_order('New')), isFalse);
  });
  test('add note unsupported', () {
    expect(_controller(repository).canAddNote(_order('New')), isFalse);
  });
}

OrderController _controller(AuthRepository repository) => OrderController(
  repository: repository,
  connectivityCheck: () async => true,
);
Order _order(String status, {bool handover = true, bool tracking = true}) =>
    Order.fromJson(_json(status, handover: handover, tracking: tracking));

Map<String, dynamic> _json(
  String status, {
  bool handover = true,
  bool tracking = true,
}) => {
  'id': 1,
  'serialNumber': 'S1',
  'orderNumber': 'O1',
  'customerId': 'u',
  'customerName': 'Ahmad',
  'phoneNum1': '1',
  'phoneNum2': '',
  'cityId': 2,
  'address': 'A',
  'status': status,
  'isWholesale': false,
  'priceDelivery': 12,
  'totalPriceWithDiscound': 75,
  'totalPriceWithOutDiscound': 80,
  'discoundCodeId': '3',
  'discoundCodePercent': 5,
  'discoundCode': 'SAVE',
  'totalPriceWithDiscoundCode': 70,
  'userAddId': 'u',
  'dateAdd': '2026-01-01',
  'userUpdate': '',
  'dateUpdate': '2026-01-02',
  'latestHandover':
      handover
          ? {
            'id': 2,
            'deliveryCompanyName': 'Shiply',
            'deliveryCompanyCode': 'S',
            'trackingNumber': 'TRK',
            'carrierContactName': '',
            'carrierContactPhone': '',
            'carrierOfficeName': '',
            'carrierVehicleNumber': '',
            'shiplyParcelCode': 'P1',
            'handedOverAt': '',
            'deliveredAt': '',
          }
          : null,
  'statusLogs': [
    {
      'fromStatus': '',
      'toStatus': 'Done',
      'note': '',
      'userName': '',
      'createdAt': '2026-01-03',
    },
    {
      'fromStatus': '',
      'toStatus': 'New',
      'note': '',
      'userName': '',
      'createdAt': '2026-01-01',
    },
  ],
  'shiplyTracking':
      tracking
          ? {
            'parcelCode': 'P1',
            'shiplyMode': 'live',
            'currentStatusId': 2,
            'currentStatusKey': 'mystery',
            'currentStatusLabel': 'Unknown',
            'statusSequence': [1, 2],
            'events': [
              {
                'id': 2,
                'parcelStatusId': 99,
                'statusKey': 'mystery',
                'statusLabel': '',
                'note': '',
                'source': 'api',
                'occurredAt': '2026-01-04',
              },
              {
                'id': 1,
                'parcelStatusId': 1,
                'statusKey': 'draft',
                'statusLabel': 'Draft',
                'note': '',
                'source': 'api',
                'occurredAt': '2026-01-01',
              },
            ],
          }
          : null,
  'details': [
    {
      'id': 10,
      'orderId': 1,
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
        'nameAr': 'منتج',
        'nameEng': 'Item',
        'nameAbree': 'Item',
        'isShow': true,
        'descriptionAr': '',
        'descriptionEng': '',
        'descriptionAbree': '',
        'normailPrice': 999,
        'wholesalePrice': 500,
        'stock': 0,
        'model': '',
        'isNewItem': false,
        'isMoreSales': false,
        'rate': 0,
        'manufactureYear': 0,
        'discount': 0,
        'dateAdd': '',
        'dateUpdate': '',
        'normalImagesItems': [
          {'id': 1, 'imageUrl': '/media/thumb.jpg', 'itemId': 5},
        ],
        'viewImagesItems': [],
        'itemSizes': [],
      },
    },
  ],
};

class _OrdersRepository extends AuthRepository {
  _OrdersRepository({required super.apiClient});
  int status = 200;
  dynamic body = {
    'rows': [_json('New')],
  };
  String? lastStatus;
  int cancelCalls = 0;
  int cancelStatus = 200;
  dynamic cancelBody = {'data': _json('Canceled')};
  bool pending = false;
  Completer<void>? _pending;

  void complete() => _pending?.complete();
  @override
  Future<Response> getAllOrder(statusOrder) async {
    lastStatus = '$statusOrder';
    if (pending) {
      _pending = Completer<void>();
      await _pending!.future;
    }
    return Response(statusCode: status, body: body);
  }

  @override
  Future<Response> cancelOrder({required String orderId}) async {
    cancelCalls++;
    return Response(statusCode: cancelStatus, body: cancelBody);
  }
}
