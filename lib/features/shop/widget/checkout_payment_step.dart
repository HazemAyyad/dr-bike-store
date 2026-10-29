import 'package:doctor_bike/core/theme/store_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/model/checkout_flow_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';
import 'cart_summary.dart';

class CheckoutPaymentStep extends StatelessWidget {
  const CheckoutPaymentStep({required this.controller, super.key});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.checkoutState;
    final submitting = state.stage == CheckoutStage.submitting;
    return ListView(
      key: const PageStorageKey<String>('checkout-payment-scroll'),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 22),
      children: [
        Text(
          'طريقة الدفع'.tr,
          style: StoreColors.text(context, StoreTypography.title),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: StoreColors.resolve(context, StorePalette.surface),
            borderRadius: BorderRadius.circular(StoreRadii.lg),
            border: Border.all(color: StorePalette.purple, width: 1.3),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: StorePalette.purple,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الدفع عند الاستلام'.tr,
                      style: StoreColors.text(
                        context,
                        StoreTypography.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'طريقة الدفع المتاحة في تطبيق المتجر'.tr,
                      style: StoreColors.text(context, StoreTypography.caption),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.payments_outlined, color: StorePalette.purple),
            ],
          ),
        ),
        if (state.availableRoles.length > 1) ...[
          const SizedBox(height: 18),
          Text(
            'نوع الحساب'.tr,
            style: StoreColors.text(context, StoreTypography.title),
          ),
          const SizedBox(height: 8),
          _RoleChoice(
            label: 'عميل تجزئة'.tr,
            value: 'customer',
            groupValue: state.selectedRole,
            onChanged: controller.selectCheckoutRole,
          ),
          const SizedBox(height: 8),
          _RoleChoice(
            label: 'حساب بائع'.tr,
            value: 'seller',
            groupValue: state.selectedRole,
            onChanged: controller.selectCheckoutRole,
          ),
        ],
        const SizedBox(height: 18),
        Text(
          'ملخص الدفع'.tr,
          style: StoreColors.text(context, StoreTypography.title),
        ),
        const SizedBox(height: 10),
        CartSummary(controller: controller, forCheckout: true),
        const SizedBox(height: 10),
        _DeliveryCard(controller: controller),
        if (_showsFailure(state.stage)) ...[
          const SizedBox(height: 10),
          _CheckoutMessage(state: state),
        ],
        const SizedBox(height: 18),
        StoreButton(
          label: 'تأكيد وإنشاء الطلب'.tr,
          icon: Icons.lock_outline_rounded,
          isLoading: submitting,
          onPressed:
              submitting ||
                      state.selectedRole == null ||
                      !controller.hasAuthoritativeDeliveryQuote ||
                      controller.isDeliveryLoading
                  ? null
                  : controller.submitCheckout,
        ),
        const SizedBox(height: 8),
        Text(
          'storeCheckoutReassurance'.tr,
          textAlign: TextAlign.center,
          style: StoreColors.text(context, StoreTypography.caption),
        ),
        const SizedBox(height: 4),
        Text(
          controller.hasAuthoritativeDeliveryQuote
              ? 'storeExpectedAmount'.trParams({
                'amount': _price(
                  controller.checkoutTotalAfterCoupon +
                      controller.selectedCityPrice,
                ),
              })
              : 'storeBeforeShipping'.trParams({
                'amount': _price(controller.checkoutTotalAfterCoupon),
              }),
          textAlign: TextAlign.center,
          style: StoreColors.text(
            context,
            StoreTypography.label,
          ).copyWith(color: StoreColors.resolve(context, StorePalette.navy)),
        ),
      ],
    );
  }

  bool _showsFailure(CheckoutStage stage) =>
      stage == CheckoutStage.offline ||
      stage == CheckoutStage.uncertain ||
      stage == CheckoutStage.validationError ||
      stage == CheckoutStage.error;
}

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(StoreRadii.md),
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: StoreColors.resolve(context, StorePalette.surface),
          borderRadius: BorderRadius.circular(StoreRadii.md),
          border: Border.all(
            color:
                selected
                    ? StorePalette.purple
                    : StoreColors.resolve(context, StorePalette.border),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color:
                  selected
                      ? StorePalette.purple
                      : StoreColors.resolve(context, StorePalette.textDisabled),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: StoreColors.text(context, StoreTypography.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: StoreColors.resolve(context, StorePalette.surface),
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      border: Border.all(
        color: StoreColors.resolve(context, StorePalette.border),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: StorePalette.purple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'عنوان التوصيل'.tr,
              style: StoreColors.text(context, StoreTypography.bodyMedium),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          [
            controller.selectedCity,
            controller.selectedVillage,
            controller.addressController.text.trim(),
          ].whereType<String>().where((v) => v.trim().isNotEmpty).join('، '.tr),
          style: StoreColors.text(context, StoreTypography.body),
        ),
        const SizedBox(height: 5),
        Text(
          'الدفع: نقدًا عند الاستلام'.tr,
          style: StoreColors.text(context, StoreTypography.caption),
        ),
      ],
    ),
  );
}

class _CheckoutMessage extends StatelessWidget {
  const _CheckoutMessage({required this.state});

  final CheckoutFlowState state;

  @override
  Widget build(BuildContext context) {
    final uncertain = state.stage == CheckoutStage.uncertain;
    final offline = state.stage == CheckoutStage.offline;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            uncertain || offline
                ? StoreColors.resolve(
                  context,
                  StorePalette.derivedWarningSurface,
                )
                : StoreColors.resolve(
                  context,
                  StorePalette.derivedErrorSurface,
                ),
        borderRadius: BorderRadius.circular(StoreRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            uncertain || offline
                ? Icons.info_outline_rounded
                : Icons.error_outline_rounded,
            color:
                uncertain || offline
                    ? StorePalette.warning
                    : StorePalette.error,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              state.message ??
                  'تعذر إتمام الطلب. راجع البيانات وحاول مجددًا.'.tr,
              style: StoreColors.text(
                context,
                StoreTypography.caption,
              ).copyWith(
                color: StoreColors.resolve(context, StorePalette.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _price(num value) => NumberFormat('#,##0.##', 'en_US').format(value);
