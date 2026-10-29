import 'package:doctor_bike/core/theme/store_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        color: StoreColors.resolve(context, StorePalette.surface),
        border: Border.all(
          color: StoreColors.resolve(context, StorePalette.border),
        ),
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
                    child: Text(
                      'خصم الكوبون'.tr,
                      style: StoreColors.text(context, StoreTypography.body),
                    ),
                  ),
                  Text(
                    '-${_price(couponDiscount)} ₪',
                    style: StoreColors.text(
                      context,
                      StoreTypography.label,
                    ).copyWith(color: StorePalette.success),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'الشحن'.tr,
                    style: StoreColors.text(context, StoreTypography.body),
                  ),
                ),
                Text(
                  controller.hasAuthoritativeDeliveryQuote
                      ? shipping == 0
                          ? 'مجاني'.tr
                          : '${_price(shipping)} ₪'
                      : 'يحدد لاحقًا'.tr,
                  style: StoreColors.text(
                    context,
                    StoreTypography.caption,
                  ).copyWith(
                    color:
                        controller.hasAuthoritativeDeliveryQuote
                            ? StoreColors.resolve(
                              context,
                              StorePalette.textPrimary,
                            )
                            : StoreColors.resolve(
                              context,
                              StorePalette.textSecondary,
                            ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 22,
            color: StoreColors.resolve(context, StorePalette.border),
          ),
          _valueRow(
            'المجموع',
            total,
            labelStyle: StoreColors.text(
              context,
              StoreTypography.label,
            ).copyWith(fontSize: 15),
            valueStyle: StoreColors.text(
              context,
              StoreTypography.title,
            ).copyWith(
              color: StoreColors.resolve(context, StorePalette.navy),
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
  }) => Builder(
    builder:
        (context) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.tr,
                  style:
                      labelStyle ??
                      StoreColors.text(context, StoreTypography.body),
                ),
              ),
              Text(
                '${value < 0 ? '-' : ''}${_price(value.abs())} ₪',
                style: (valueStyle ??
                        StoreColors.text(context, StoreTypography.label))
                    .copyWith(color: valueColor),
              ),
            ],
          ),
        ),
  );
}

String _price(num value) => NumberFormat('#,##0.##', 'en_US').format(value);
