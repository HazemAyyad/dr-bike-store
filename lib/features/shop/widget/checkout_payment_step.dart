import 'package:flutter/material.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/model/checkout_flow_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';

class CheckoutPaymentStep extends StatelessWidget {
  const CheckoutPaymentStep({required this.controller, super.key});
  final ShopController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(StoreSpacing.md),
    children: [
      Text('الدفع ونوع الحساب', style: StoreTypography.headline),
      const SizedBox(height: StoreSpacing.md),
      const ListTile(
        tileColor: StorePalette.surface,
        leading: Icon(Icons.payments_outlined, color: StorePalette.purple),
        title: Text('الدفع نقدًا عند الاستلام'),
        subtitle: Text('الطريقة المتاحة حاليًا في تطبيق المتجر'),
        trailing: Icon(Icons.check_circle, color: StorePalette.success),
      ),
      if (controller.checkoutState.availableRoles.length > 1) ...[
        const SizedBox(height: StoreSpacing.md),
        Text('تنفيذ الطلب كـ', style: StoreTypography.label),
        RadioListTile<String>(
          value: 'customer',
          groupValue: controller.checkoutState.selectedRole,
          onChanged: (v) => controller.selectCheckoutRole(v!),
          title: const Text('عميل تجزئة'),
        ),
        RadioListTile<String>(
          value: 'seller',
          groupValue: controller.checkoutState.selectedRole,
          onChanged: (v) => controller.selectCheckoutRole(v!),
          title: const Text('حساب بائع'),
        ),
      ],
      const SizedBox(height: StoreSpacing.lg),
      StoreButton(
        label: 'مراجعة الطلب',
        onPressed:
            controller.checkoutState.selectedRole == null
                ? null
                : () => controller.setCheckoutStage(CheckoutStage.review),
      ),
    ],
  );
}
