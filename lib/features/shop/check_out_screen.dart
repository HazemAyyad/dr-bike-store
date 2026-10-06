import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/shop/shop_controller.dart';
import '../../core/model/checkout_flow_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import 'widget/checkout_address_step.dart';
import 'widget/checkout_payment_step.dart';
import 'widget/checkout_review_step.dart';
import 'widget/checkout_shipping_step.dart';

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: GetBuilder<ShopController>(
      builder: (controller) {
        final stage = controller.checkoutState.stage;
        final index = switch (stage) {
          CheckoutStage.address => 0,
          CheckoutStage.shipping => 1,
          CheckoutStage.payment => 2,
          _ => 3,
        };
        return Scaffold(
          backgroundColor: StorePalette.background,
          appBar: AppBar(
            backgroundColor: StorePalette.surface,
            foregroundColor: StorePalette.textPrimary,
            title: Text('إتمام الطلب', style: StoreTypography.title),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(StoreSpacing.md),
                  child: Row(
                    children: List.generate(
                      4,
                      (step) => Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color:
                                step <= index
                                    ? StorePalette.purple
                                    : StorePalette.border,
                            borderRadius: BorderRadius.circular(
                              StoreRadii.pill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: switch (index) {
                    0 => CheckoutAddressStep(controller: controller),
                    1 => CheckoutShippingStep(controller: controller),
                    2 => CheckoutPaymentStep(controller: controller),
                    _ => CheckoutReviewStep(controller: controller),
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
