import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/order/order_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/orders_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_states.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({this.embedded = false, super.key});
  final bool embedded;

  @override
  Widget build(BuildContext context) => GetBuilder<OrderController>(
    builder: (controller) {
      final body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(StoreSpacing.md),
            child: SegmentedButton<OrderListFilter>(
              segments: const [
                ButtonSegment(
                  value: OrderListFilter.current,
                  label: Text('الحالية'),
                ),
                ButtonSegment(
                  value: OrderListFilter.completed,
                  label: Text('المكتملة'),
                ),
                ButtonSegment(
                  value: OrderListFilter.canceled,
                  label: Text('الملغاة'),
                ),
              ],
              selected: {controller.selectedFilter},
              onSelectionChanged:
                  (value) => controller.load(filter: value.single),
            ),
          ),
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
          appBar: AppBar(title: Text('طلباتي', style: StoreTypography.title)),
          body: body,
        ),
      );
    },
  );

  Widget _content(OrderController controller) => switch (controller
      .listStatus) {
    OrderListStatus.initial ||
    OrderListStatus.loading => const StoreSkeletonList(itemCount: 4),
    OrderListStatus.offline => StoreMessageState(
      kind: StoreMessageKind.offline,
      message: 'تحقق من الاتصال ثم أعد المحاولة.',
      actionLabel: 'إعادة المحاولة',
      onAction: controller.refreshOrders,
    ),
    OrderListStatus.error => StoreMessageState(
      kind: StoreMessageKind.error,
      message: controller.message ?? 'تعذر تحميل الطلبات.',
      actionLabel: 'إعادة المحاولة',
      onAction: controller.refreshOrders,
    ),
    OrderListStatus.empty => StoreMessageState(
      kind: StoreMessageKind.empty,
      title: 'لا توجد طلبات',
      message: 'لا توجد طلبات ضمن هذا التصنيف حاليًا.',
    ),
    OrderListStatus.content => RefreshIndicator(
      onRefresh: controller.refreshOrders,
      color: StorePalette.purple,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(StoreSpacing.md),
        itemCount: controller.orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: StoreSpacing.sm),
        itemBuilder:
            (_, index) => _OrderCard(
              order: controller.orders[index],
              controller: controller,
            ),
      ),
    ),
  };
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
        padding: const EdgeInsets.all(StoreSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: StorePalette.border),
          borderRadius: BorderRadius.circular(StoreRadii.lg),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'طلب #${order.orderNumber}',
                    style: StoreTypography.title,
                  ),
                ),
                _status(order),
              ],
            ),
            const SizedBox(height: StoreSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(order.dateAdd, style: StoreTypography.caption),
                ),
                Text(
                  '${order.details.fold<int>(0, (sum, line) => sum + line.quantity)} منتج',
                  style: StoreTypography.caption,
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(child: Text('الإجمالي التاريخي')),
                Text(
                  '${(order.totalPriceWithDiscoundCode ?? order.totalPriceWithDiscound).toStringAsFixed(2)} ₪',
                  style: StoreTypography.label,
                ),
              ],
            ),
            if (order.shiplyTracking != null || order.latestHandover != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  order.shiplyTracking?.currentStatusLabel ??
                      order.latestHandover!.deliveryCompanyName,
                  style: StoreTypography.caption.copyWith(
                    color: StorePalette.purple,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _status(Order order) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: StoreSpacing.sm,
      vertical: StoreSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: StorePalette.background,
      borderRadius: BorderRadius.circular(StoreRadii.pill),
    ),
    child: Text(
      order.rawStatus.isEmpty ? 'غير معروف' : order.rawStatus,
      style: StoreTypography.caption,
    ),
  );
}
