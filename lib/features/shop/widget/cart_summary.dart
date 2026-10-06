import 'package:flutter/material.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({required this.controller, super.key});
  final ShopController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(StoreSpacing.md),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      border: Border.all(color: StorePalette.border),
      borderRadius: BorderRadius.circular(StoreRadii.lg),
    ),
    child: Column(
      children: [
        _row('المجموع الفرعي', controller.cartSubtotal),
        if (controller.cartSubtotal != controller.cartTotal)
          _row('بعد الخصم المتحقق من بيانات المنتج', controller.cartTotal),
        const Divider(color: StorePalette.border),
        Text(
          'الشحن غير محسوب حتى اختيار العنوان وطريقة التوصيل.',
          style: StoreTypography.caption,
        ),
        if (controller.couponIntent.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: StoreSpacing.xs),
            child: Text(
              'كود محتفظ به: ${controller.couponIntent} — يحتاج إلى تحقق',
              style: StoreTypography.caption,
            ),
          ),
      ],
    ),
  );

  Widget _row(String label, double value) => Row(
    children: [
      Expanded(child: Text(label, style: StoreTypography.body)),
      Text('${value.toStringAsFixed(2)} ₪', style: StoreTypography.label),
    ],
  );
}
