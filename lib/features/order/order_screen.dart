import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../controller/order/order_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/orders_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_states.dart';
import '../../core/widget/store_navigation_icons.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  Widget build(BuildContext context) => GetBuilder<OrderController>(
    builder: (controller) {
      final body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (embedded)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'طلباتي',
                      style: StoreTypography.headline.copyWith(fontSize: 20),
                    ),
                  ),
                  Text('اسحب للأسفل للتحديث', style: StoreTypography.caption),
                ],
              ),
            ),
          _OrderFilters(controller: controller),
          const SizedBox(height: 5),
          Expanded(child: _content(controller)),
        ],
      );
      if (embedded) {
        return ColoredBox(color: StorePalette.background, child: body);
      }
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: StorePalette.background,
          appBar: AppBar(
            title: Text('طلباتي', style: StoreTypography.title),
            centerTitle: true,
            elevation: 0,
          ),
          body: body,
        ),
      );
    },
  );

  Widget _content(OrderController controller) => switch (controller
      .listStatus) {
    OrderListStatus.initial ||
    OrderListStatus.loading => const StoreSkeletonList(itemCount: 4),
    OrderListStatus.offline => _refreshable(
      controller,
      StoreMessageState(
        kind: StoreMessageKind.offline,
        message: 'تحقق من الاتصال ثم اسحب للأسفل لإعادة المحاولة.',
      ),
    ),
    OrderListStatus.error => _refreshable(
      controller,
      StoreMessageState(
        kind: StoreMessageKind.error,
        message: controller.message ?? 'تعذر تحميل الطلبات.',
      ),
    ),
    OrderListStatus.empty => _refreshable(
      controller,
      const StoreMessageState(
        kind: StoreMessageKind.empty,
        title: 'لا توجد طلبات',
        message: 'لا توجد طلبات ضمن هذه الحالة. اسحب للأسفل للتحديث.',
      ),
    ),
    OrderListStatus.content => RefreshIndicator(
      onRefresh: controller.refreshOrders,
      color: StorePalette.purple,
      child: ListView.separated(
        key: const PageStorageKey<String>('store-orders-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 20),
        itemCount: controller.orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 9),
        itemBuilder:
            (_, index) => _OrderCard(
              order: controller.orders[index],
              controller: controller,
            ),
      ),
    ),
  };

  Widget _refreshable(OrderController controller, Widget child) =>
      RefreshIndicator(
        onRefresh: controller.refreshOrders,
        color: StorePalette.purple,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [SizedBox(height: 360, child: child)],
        ),
      );
}

class _OrderFilters extends StatelessWidget {
  const _OrderFilters({required this.controller});

  final OrderController controller;

  @override
  Widget build(BuildContext context) => Container(
    color: StorePalette.background,
    padding: const EdgeInsetsDirectional.fromSTEB(14, 2, 14, 5),
    child: Row(
      children: [
        Expanded(child: _chip(OrderListFilter.current, 'الحالية')),
        const SizedBox(width: 6),
        Expanded(child: _chip(OrderListFilter.completed, 'المكتملة')),
        const SizedBox(width: 6),
        Expanded(child: _chip(OrderListFilter.canceled, 'الملغاة')),
      ],
    ),
  );

  Widget _chip(OrderListFilter filter, String label) {
    final selected = controller.selectedFilter == filter;
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      label: Text(label),
      onSelected: (_) => controller.load(filter: filter),
      labelStyle: StoreTypography.caption.copyWith(
        color: selected ? Colors.white : StorePalette.textSecondary,
        fontWeight:
            selected ? StoreTypography.semiBold : StoreTypography.regular,
      ),
      selectedColor: StorePalette.purple,
      backgroundColor: StorePalette.surface,
      side: BorderSide(
        color: selected ? StorePalette.purple : StorePalette.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StoreRadii.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.controller});

  final Order order;
  final OrderController controller;

  @override
  Widget build(BuildContext context) => Material(
    color: StorePalette.surface,
    borderRadius: BorderRadius.circular(StoreRadii.lg),
    child: InkWell(
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      onTap: () {
        controller.selectOrder(order);
        Get.toNamed(RouteHelper.orderDetailsScreen, arguments: order);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: StorePalette.border),
          borderRadius: BorderRadius.circular(StoreRadii.lg),
          boxShadow: const [StoreElevation.lowShadow],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTypography.bodyMedium.copyWith(
                          color: StorePalette.navy,
                        ),
                      ),
                      Text(
                        _displayDate(order.dateAdd),
                        style: StoreTypography.caption,
                      ),
                    ],
                  ),
                ),
                _OrderStatusBadge(order: order),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(child: _OrderThumbnails(order: order)),
                const SizedBox(width: 8),
                Text('${order.itemCount} منتج', style: StoreTypography.caption),
              ],
            ),
            const Divider(height: 14, color: StorePalette.border),
            Row(
              children: [
                Text(
                  '${_price(order.grandTotal)} ₪',
                  style: StoreTypography.label.copyWith(
                    color: StorePalette.navy,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (order.hasTracking) ...[
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 17,
                    color: StorePalette.purple,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      order.shiplyTracking != null
                          ? _shiplyStatusLabel(order.shiplyTracking!)
                          : 'يتوفر تتبع للشحنة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StoreTypography.caption.copyWith(
                        color: StorePalette.purple,
                      ),
                    ),
                  ),
                ] else
                  Icon(
                    storeForwardIcon(context),
                    size: 15,
                    color: StorePalette.textSecondary,
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _OrderThumbnails extends StatelessWidget {
  const _OrderThumbnails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final lines = order.details.take(4).toList(growable: false);
    if (lines.isEmpty) {
      return Text('تفاصيل المنتجات غير متاحة', style: StoreTypography.caption);
    }
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          ...lines.map(
            (line) => Container(
              width: 34,
              height: 34,
              margin: const EdgeInsetsDirectional.only(end: 5),
              decoration: BoxDecoration(
                color: StorePalette.background,
                borderRadius: BorderRadius.circular(StoreRadii.sm),
                border: Border.all(color: StorePalette.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: StoreNetworkMedia(
                url: line.item.primaryImageUrl,
                semanticLabel:
                    line.item.nameAr.isEmpty
                        ? 'منتج ${line.itemId}'
                        : line.item.nameAr,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (order.details.length > lines.length)
            Text(
              '+${order.details.length - lines.length}',
              style: StoreTypography.caption,
            ),
        ],
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final presentation = switch (order.statusKind) {
      StoreOrderStatusKind.current => (
        label: 'قيد التجهيز',
        foreground: StorePalette.purple,
        background: StorePalette.lightPurple,
      ),
      StoreOrderStatusKind.completed => (
        label: 'مكتمل',
        foreground: StorePalette.success,
        background: StorePalette.derivedSuccessSurface,
      ),
      StoreOrderStatusKind.canceled => (
        label: 'ملغى',
        foreground: StorePalette.error,
        background: StorePalette.derivedErrorSurface,
      ),
      StoreOrderStatusKind.unknown => (
        label: order.rawStatus.isEmpty ? 'غير معروف' : order.rawStatus,
        foreground: StorePalette.textSecondary,
        background: StorePalette.background,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: presentation.background,
        borderRadius: BorderRadius.circular(StoreRadii.pill),
      ),
      child: Text(
        presentation.label,
        style: StoreTypography.caption.copyWith(
          color: presentation.foreground,
          fontSize: 10.5,
          fontWeight: StoreTypography.semiBold,
        ),
      ),
    );
  }
}

String _price(num value) => NumberFormat('#,##0.##', 'en_US').format(value);

String _displayDate(String raw) {
  final date = DateTime.tryParse(raw);
  return date == null
      ? raw
      : DateFormat('yyyy-MM-dd  HH:mm').format(date.toLocal());
}

String _shiplyStatusLabel(OrderShiplyTracking tracking) => switch (tracking
    .currentStatusId) {
  1 => 'تم إنشاء الشحنة',
  2 => 'تم إرسالها لشركة الشحن',
  3 => 'في الطريق',
  4 => 'محاولة تسليم',
  5 => 'معلقة',
  6 => 'تم التسليم',
  7 => 'مرتجعة',
  _ =>
    tracking.currentStatusLabel.isEmpty
        ? 'حالة الشحنة'
        : tracking.currentStatusLabel,
};
