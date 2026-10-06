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
      appBar: AppBar(
        title: Text('الإشعارات', style: StoreTypography.title),
        actions: [
          IconButton(
            onPressed: () => controller.load(refresh: true),
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: GetBuilder<NotificationController>(
        builder:
            (controller) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(StoreSpacing.md),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: StoreFilterChip(
                      label: 'الكل',
                      selected: true,
                      onSelected: (_) {},
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
    color: item.isRead ? StorePalette.surface : StorePalette.lightPurple,
    borderRadius: BorderRadius.circular(StoreRadii.lg),
    child: InkWell(
      onTap: marking ? null : onTap,
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(StoreSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: StoreSpacing.sm),
                decoration: const BoxDecoration(
                  color: StorePalette.purple,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: StoreTypography.bodyMedium),
                  const SizedBox(height: StoreSpacing.xs),
                  Text(item.content, style: StoreTypography.body),
                  if (item.createdAt case final date?)
                    Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(date),
                      style: StoreTypography.caption,
                    ),
                ],
              ),
            ),
            if (marking)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    ),
  );
}
