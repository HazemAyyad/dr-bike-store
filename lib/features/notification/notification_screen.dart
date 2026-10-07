import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/notification/notification_controller.dart';
import '../../controller/order/order_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/functions/notification_api.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/notification_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_chips.dart';
import '../../core/widget/store_states.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController controller = Get.find();

  @override
  void initState() {
    super.initState();
    if (controller.inboxState is StoreInitial) controller.load();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: ui.TextDirection.rtl,
    child: Scaffold(
      backgroundColor: StorePalette.background,
      appBar: AppBar(title: Text('الإشعارات', style: StoreTypography.title)),
      body: GetBuilder<NotificationController>(
        builder:
            (controller) => Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    StoreSpacing.md,
                    StoreSpacing.sm,
                    StoreSpacing.md,
                    StoreSpacing.xs,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(StoreSpacing.md),
                    decoration: BoxDecoration(
                      color: StorePalette.navy,
                      borderRadius: BorderRadius.circular(StoreRadii.lg),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: StoreSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'كل جديد في مكان واحد',
                                style: StoreTypography.title.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                controller.unreadCount == 0
                                    ? 'لا توجد إشعارات غير مقروءة'
                                    : '${controller.unreadCount} إشعار غير مقروء',
                                style: StoreTypography.caption.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StoreFilterChip(
                          label: 'الكل',
                          selected: true,
                          compact: true,
                          onSelected: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: StoreStateView<List<NotificationItem>>(
                    state: controller.inboxState,
                    onRetry: controller.load,
                    loading: const StoreSkeletonList(),
                    contentBuilder:
                        (_, rows) => RefreshIndicator(
                          onRefresh: () => controller.load(refresh: true),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(StoreSpacing.md),
                            itemCount: rows.length,
                            separatorBuilder:
                                (_, _) =>
                                    const SizedBox(height: StoreSpacing.sm),
                            itemBuilder:
                                (_, index) => _NotificationCard(
                                  item: rows[index],
                                  marking: controller.markingReadIds.contains(
                                    rows[index].id,
                                  ),
                                  onTap: () => _open(rows[index]),
                                ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
      ),
    ),
  );

  Future<void> _open(NotificationItem item) async {
    if (!item.isRead) await controller.markRead(item);
    final destination = item.destination;
    if (destination == null) return;
    final target = NotificationRouteResolver.resolve({
      'destination_type': destination.type.name,
      'destination_id': destination.id,
    });
    if (target is NotificationOrderTarget &&
        Get.isRegistered<OrderController>()) {
      final orders = Get.find<OrderController>();
      await orders.load();
      final order = orders.orders.firstWhereOrNull(
        (row) => row.id == target.orderId,
      );
      if (order != null) {
        orders.selectOrder(order);
        Get.toNamed(RouteHelper.orderDetailsScreen, arguments: order);
      } else {
        Get.toNamed(RouteHelper.ordersScreen);
      }
    } else if (target is NotificationProductTarget &&
        Get.isRegistered<ProductControllerImp>()) {
      await Get.find<ProductControllerImp>().loadProductDetail(
        productId: target.productId,
        navigate: true,
      );
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.marking,
    required this.onTap,
  });
  final NotificationItem item;
  final bool marking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: StorePalette.surface,
    borderRadius: BorderRadius.circular(StoreRadii.lg),
    child: InkWell(
      onTap: marking ? null : onTap,
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(StoreSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(StoreRadii.lg),
          border: Border.all(
            color:
                item.isRead
                    ? StorePalette.border
                    : StorePalette.purple.withValues(alpha: .45),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _categoryColor.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(_categoryIcon, color: _categoryColor, size: 22),
            ),
            const SizedBox(width: StoreSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: StoreTypography.bodyMedium.copyWith(
                            fontWeight:
                                item.isRead
                                    ? StoreTypography.medium
                                    : StoreTypography.bold,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: StorePalette.purple,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: StoreSpacing.xs),
                  Text(item.content, style: StoreTypography.body),
                  if (item.createdAt case final date?)
                    Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(date),
                      style: StoreTypography.caption.copyWith(
                        color: StorePalette.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (marking)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (item.destination != null)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: StorePalette.textSecondary,
                ),
              ),
          ],
        ),
      ),
    ),
  );

  IconData get _categoryIcon => switch (item.category) {
    NotificationCategory.order => Icons.receipt_long_outlined,
    NotificationCategory.promotion => Icons.local_offer_outlined,
    NotificationCategory.unknown => Icons.notifications_none_rounded,
  };

  Color get _categoryColor => switch (item.category) {
    NotificationCategory.order => StorePalette.purple,
    NotificationCategory.promotion => StorePalette.success,
    NotificationCategory.unknown => StorePalette.navy,
  };
}
