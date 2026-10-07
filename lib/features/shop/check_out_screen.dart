import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/shop/shop_controller.dart';
import '../../core/model/checkout_flow_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import 'widget/checkout_address_step.dart';
import 'widget/checkout_payment_step.dart';
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
          _ => 2,
        };
        return Scaffold(
          backgroundColor: StorePalette.background,
          appBar: AppBar(
            backgroundColor: StorePalette.surface,
            foregroundColor: StorePalette.textPrimary,
            title: Text('إتمام الطلب', style: StoreTypography.title),
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            child: Column(
              children: [
                _CheckoutProgress(activeIndex: index),
                Expanded(
                  child: switch (index) {
                    0 => CheckoutAddressStep(controller: controller),
                    1 => CheckoutShippingStep(controller: controller),
                    _ => CheckoutPaymentStep(controller: controller),
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

class _CheckoutProgress extends StatelessWidget {
  const _CheckoutProgress({required this.activeIndex});

  final int activeIndex;

  static const _labels = ['العنوان', 'الشحن', 'الدفع'];

  @override
  Widget build(BuildContext context) => Container(
    color: StorePalette.surface,
    padding: const EdgeInsetsDirectional.fromSTEB(22, 10, 22, 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length * 2 - 1, (slot) {
        if (slot.isOdd) {
          final completed = slot ~/ 2 < activeIndex;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(top: 15),
              color: completed ? StorePalette.purple : StorePalette.border,
            ),
          );
        }
        final step = slot ~/ 2;
        final active = step == activeIndex;
        final completed = step < activeIndex;
        return SizedBox(
          width: 64,
          child: Column(
            children: [
              AnimatedContainer(
                duration: StoreMotion.fast,
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      active || completed
                          ? StorePalette.purple
                          : StorePalette.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        active || completed
                            ? StorePalette.purple
                            : StorePalette.border,
                  ),
                ),
                child:
                    completed
                        ? const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: Colors.white,
                        )
                        : Text(
                          '${step + 1}',
                          style: StoreTypography.label.copyWith(
                            color:
                                active
                                    ? Colors.white
                                    : StorePalette.textSecondary,
                          ),
                        ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[step],
                style: StoreTypography.caption.copyWith(
                  color:
                      active ? StorePalette.purple : StorePalette.textSecondary,
                  fontWeight:
                      active
                          ? StoreTypography.semiBold
                          : StoreTypography.regular,
                ),
              ),
            ],
          ),
        );
      }),
    ),
  );
}
