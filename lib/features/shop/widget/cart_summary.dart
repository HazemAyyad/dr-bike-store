import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    required this.controller,
    this.forCheckout = false,
    super.key,
  });
  final ShopController controller;
  final bool forCheckout;

  @override
  Widget build(BuildContext context) {
    final subtotal =
        forCheckout ? controller.checkoutSubtotal : controller.cartSubtotal;
    final productsTotal =
        forCheckout ? controller.checkoutTotal : controller.cartTotal;
    final couponDiscount =
        forCheckout
            ? controller.checkoutAppliedCouponDiscount
            : controller.appliedCouponDiscount;
    final totalAfterCoupon =
        forCheckout
            ? controller.checkoutTotalAfterCoupon
            : controller.cartTotalAfterCoupon;
    final showsCoupon =
        forCheckout
            ? controller.checkoutHasCoupon
            : controller.activeCode == true && controller.couponModel != null;
    final productDiscount = subtotal - productsTotal;
    final shipping = controller.selectedCityPrice;
    final total =
        totalAfterCoupon +
        (controller.hasAuthoritativeDeliveryQuote ? shipping : 0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StorePalette.surface,
        border: Border.all(color: StorePalette.border),
        borderRadius: BorderRadius.circular(StoreRadii.lg),
      ),
      child: Column(
        children: [
          _valueRow('المجموع الفرعي', subtotal),
          if (productDiscount > 0)
            _valueRow(
              'خصم المنتجات',
              -productDiscount,
              valueColor: StorePalette.error,
            ),
          if (showsCoupon)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text('خصم الكوبون', style: StoreTypography.body),
                  ),
                  Text(
                    '-${_price(couponDiscount)} ₪',
                    style: StoreTypography.label.copyWith(
                      color: StorePalette.success,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(child: Text('الشحن', style: StoreTypography.body)),
                Text(
                  controller.hasAuthoritativeDeliveryQuote
                      ? shipping == 0
                          ? 'مجاني'
                          : '${_price(shipping)} ₪'
                      : 'يحدد لاحقًا',
                  style: StoreTypography.caption.copyWith(
                    color:
                        controller.hasAuthoritativeDeliveryQuote
                            ? StorePalette.textPrimary
                            : StorePalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 22, color: StorePalette.border),
          _valueRow(
            'المجموع',
            total,
            labelStyle: StoreTypography.label.copyWith(fontSize: 15),
            valueStyle: StoreTypography.title.copyWith(
              color: StorePalette.navy,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueRow(
    String label,
    double value, {
    Color? valueColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        Expanded(child: Text(label, style: labelStyle ?? StoreTypography.body)),
        Text(
          '${value < 0 ? '-' : ''}${_price(value.abs())} ₪',
          style: (valueStyle ?? StoreTypography.label).copyWith(
            color: valueColor,
          ),
        ),
      ],
    ),
  );
}

String _price(num value) => NumberFormat('#,##0.##', 'en_US').format(value);
