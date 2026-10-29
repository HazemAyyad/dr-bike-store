import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../controller/order/order_controller.dart';
import '../../../core/model/orders_model.dart';
import '../../../core/widget/store_buttons.dart';

class OrderActions extends StatelessWidget {
  const OrderActions({
    required this.order,
    required this.controller,
    this.onTrack,
    super.key,
  });
  final Order order;
  final OrderController controller;
  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    final canCancel = controller.canRequestCancellation(order);
    final canTrack = controller.canTrack(order) && onTrack != null;
    if (!canCancel && !canTrack) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canTrack)
          StoreButton(
            label: 'تتبع الشحنة'.tr,
            icon: Icons.local_shipping_outlined,
            variant: StoreButtonVariant.secondary,
            onPressed: onTrack,
          ),
        if (canTrack && canCancel) const SizedBox(height: 9),
        if (canCancel)
          StoreButton(
            label: 'طلب إلغاء الطلب'.tr,
            icon: Icons.cancel_outlined,
            variant: StoreButtonVariant.destructive,
            isLoading:
                controller.mutationStatus == OrderMutationStatus.submitting,
            onPressed: () => _confirmCancellation(context),
          ),
      ],
    );
  }

  Future<void> _confirmCancellation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('طلب إلغاء الطلب؟'.tr),
            content: Text(
              'يمكن طلب الإلغاء حسب حالة الطلب. سيبقى طلبك دون تغيير حتى تأكيد الإلغاء.'
                  .tr,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('تراجع'.tr),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('إرسال الطلب'.tr),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await controller.requestCancellation(order, confirmed: true);
    }
  }
}
