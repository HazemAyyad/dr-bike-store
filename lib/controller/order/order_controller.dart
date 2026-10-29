import 'package:get/get.dart';

import '../../core/functions/checkInternet.dart';
import '../../core/functions/store_session_boundary.dart';
import '../../core/model/orders_model.dart';
import '../../repository/auth/auth_repository.dart';

enum OrderListFilter { current, completed, canceled }

enum OrderListStatus { initial, loading, content, empty, offline, error }

enum OrderMutationStatus { idle, submitting, success, failure }

extension OrderListFilterApi on OrderListFilter {
  String get apiStatus => switch (this) {
    OrderListFilter.current => 'New',
    OrderListFilter.completed => 'Done',
    OrderListFilter.canceled => 'Canceled',
  };
}

class OrderController extends GetxController with StoreSessionAware {
  OrderController({
    required this.repository,
    Future<bool> Function()? connectivityCheck,
  }) : connectivityCheck =
           connectivityCheck ??
           (() async => await CheckInternet.checkInternet() == true);

  final AuthRepository repository;
  final Future<bool> Function() connectivityCheck;
  OrderListFilter selectedFilter = OrderListFilter.current;
  OrderListStatus listStatus = OrderListStatus.initial;
  OrderMutationStatus mutationStatus = OrderMutationStatus.idle;
  List<Order> orders = const [];
  Order? selectedOrder;
  String? message;
  int _loadRequest = 0;

  @override
  void clearSessionData() {
    _loadRequest++;
    orders = const [];
    selectedOrder = null;
    listStatus = OrderListStatus.initial;
    mutationStatus = OrderMutationStatus.idle;
    message = null;
    update();
  }

  Future<void> load({OrderListFilter? filter}) async {
    final generation = sessionGeneration;
    final request = ++_loadRequest;
    if (filter != null) selectedFilter = filter;
    listStatus = OrderListStatus.loading;
    update();
    final online = await connectivityCheck();
    if (!sessionIsCurrent(generation) || request != _loadRequest) return;
    if (!online) {
      listStatus = OrderListStatus.offline;
      update();
      return;
    }
    try {
      final response = await repository.getAllOrder(selectedFilter.apiStatus);
      if (!sessionIsCurrent(generation) || request != _loadRequest) return;
      if (response.statusCode != 200 || response.body is! Map) {
        listStatus = OrderListStatus.error;
        message = 'تعذر تحميل الطلبات.'.tr;
      } else {
        orders =
            OrderResponse.fromJson(
              Map<String, dynamic>.from(response.body as Map),
            ).rows;
        listStatus =
            orders.isEmpty ? OrderListStatus.empty : OrderListStatus.content;
      }
    } catch (_) {
      if (!sessionIsCurrent(generation) || request != _loadRequest) return;
      listStatus = OrderListStatus.error;
      message = 'تعذر قراءة سجل الطلبات.'.tr;
    }
    update();
  }

  Future<void> refreshOrders() => load();

  void selectOrder(Order order) {
    selectedOrder = order;
    update();
  }

  bool canRequestCancellation(Order order) =>
      order.statusKind == StoreOrderStatusKind.current;

  bool canTrack(Order order) => order.hasTracking;

  bool canEditAddress(Order order) => false;

  bool canAddNote(Order order) => false;

  bool canReorder(Order order) => false;

  bool canShare(Order order) => false;

  Future<bool> requestCancellation(
    Order order, {
    required bool confirmed,
  }) async {
    if (!confirmed || !canRequestCancellation(order)) return false;
    final generation = sessionGeneration;
    mutationStatus = OrderMutationStatus.submitting;
    update();
    final original = order;
    try {
      final response = await repository.cancelOrder(orderId: '${order.id}');
      if (!sessionIsCurrent(generation)) return false;
      if (response.statusCode == 200 && response.body is Map) {
        final body = Map<String, dynamic>.from(response.body as Map);
        final raw = body['data'] is Map ? body['data'] : body;
        final authoritative = Order.fromJson(
          Map<String, dynamic>.from(raw as Map),
        );
        final index = orders.indexWhere(
          (candidate) => candidate.id == order.id,
        );
        if (index >= 0) orders = [...orders]..[index] = authoritative;
        selectedOrder = authoritative;
        mutationStatus = OrderMutationStatus.success;
        update();
        return true;
      }
      selectedOrder = original;
      mutationStatus = OrderMutationStatus.failure;
      message = 'رفض الخادم طلب الإلغاء. بقي الطلب دون تغيير.'.tr;
    } catch (_) {
      if (!sessionIsCurrent(generation)) return false;
      selectedOrder = original;
      mutationStatus = OrderMutationStatus.failure;
      message = 'تعذر إرسال طلب الإلغاء. بقي الطلب دون تغيير.'.tr;
    }
    update();
    return false;
  }
}
