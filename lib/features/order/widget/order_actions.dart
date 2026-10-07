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
            label: 'تتبع الشحنة',
            icon: Icons.local_shipping_outlined,
            variant: StoreButtonVariant.secondary,
            onPressed: onTrack,
          ),
        if (canTrack && canCancel) const SizedBox(height: 9),
        if (canCancel)
          StoreButton(
            label: 'طلب إلغاء الطلب',
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
            title: const Text('طلب إلغاء الطلب؟'),
            content: const Text(
              'سيتحقق الخادم من إمكانية الإلغاء حسب حالة الطلب الحالية. لن تتغير الحالة محليًا قبل موافقة الخادم.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('تراجع'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('إرسال الطلب'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await controller.requestCancellation(order, confirmed: true);
    }
  }
}
