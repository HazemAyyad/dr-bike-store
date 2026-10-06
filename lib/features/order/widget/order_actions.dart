import 'package:flutter/material.dart';

import '../../../controller/order/order_controller.dart';
import '../../../core/model/orders_model.dart';
import '../../../core/widget/store_buttons.dart';

class OrderActions extends StatelessWidget {
  const OrderActions({
    required this.order,
    required this.controller,
    super.key,
  });
  final Order order;
  final OrderController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.canRequestCancellation(order)) {
      return const SizedBox.shrink();
    }
    return StoreButton(
      label: 'طلب إلغاء الطلب',
      variant: StoreButtonVariant.destructive,
      isLoading: controller.mutationStatus == OrderMutationStatus.submitting,
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('طلب إلغاء الطلب؟'),
                content: const Text(
                  'سيتحقق الخادم من إمكانية الإلغاء حسب حالة الطلب الحالية.',
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
      },
    );
  }
}
