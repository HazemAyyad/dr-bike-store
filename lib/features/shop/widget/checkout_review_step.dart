import 'package:doctor_bike/core/theme/store_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/model/checkout_flow_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';
import '../../../core/widget/store_states.dart';

class CheckoutReviewStep extends StatelessWidget {
  const CheckoutReviewStep({required this.controller, super.key});
  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.checkoutState;
    if (state.stage == CheckoutStage.offline ||
        state.stage == CheckoutStage.uncertain ||
        state.stage == CheckoutStage.validationError ||
        state.stage == CheckoutStage.error) {
      return StoreMessageState(
        kind:
            state.stage == CheckoutStage.offline ||
                    state.stage == CheckoutStage.uncertain
                ? StoreMessageKind.offline
                : StoreMessageKind.error,
        title:
            state.stage == CheckoutStage.offline
                ? 'لا يوجد اتصال بالإنترنت'.tr
                : state.stage == CheckoutStage.uncertain
                ? 'نتيجة الطلب غير مؤكدة'.tr
                : 'راجع بيانات الطلب'.tr,
        message: state.message ?? 'تعذر إتمام الطلب.'.tr,
        actionLabel: 'إعادة المحاولة'.tr,
        onAction: controller.submitCheckout,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(StoreSpacing.md),
      children: [
        Text(
          'مراجعة الطلب'.tr,
          style: StoreColors.text(context, StoreTypography.headline),
        ),
        const SizedBox(height: StoreSpacing.md),
        ...controller.checkoutLines.map(
          (line) => ListTile(
            title: Text(line.nameAr),
            subtitle: Text(
              'storeQuantityLine'.trParams({'quantity': '${line.quantity}'}),
            ),
            trailing: Text('${line.total.toStringAsFixed(2)} ₪'),
          ),
        ),
        const Divider(),
        Text(
          'storeAddressLine'.trParams({
            'address': controller.addressController.text,
          }),
          style: StoreColors.text(context, StoreTypography.body),
        ),
        Text(
          'storeDestinationLine'.trParams({
            'city': controller.selectedCity ?? '',
            'village': controller.selectedVillage ?? '',
          }),
          style: StoreColors.text(context, StoreTypography.body),
        ),
        Text(
          'storeQuoteLine'.trParams({
            'amount': controller.selectedCityPrice.toStringAsFixed(2),
          }),
          style: StoreColors.text(context, StoreTypography.body),
        ),
        Text(
          'الدفع: نقدًا عند الاستلام'.tr,
          style: StoreColors.text(context, StoreTypography.body),
        ),
        Text(
          'storeRoleLine'.trParams({
            'role':
                (state.selectedRole == 'seller' ? 'حساب بائع' : 'عميل تجزئة')
                    .tr,
          }),
          style: StoreColors.text(context, StoreTypography.body),
        ),
        const SizedBox(height: StoreSpacing.sm),
        Text(
          'الأسعار والتوفر ورسوم التوصيل النهائية يعتمدها الخادم عند الإرسال.'
              .tr,
          style: StoreColors.text(context, StoreTypography.caption),
        ),
        const SizedBox(height: StoreSpacing.lg),
        StoreButton(
          label: 'تأكيد الطلب'.tr,
          isLoading: state.stage == CheckoutStage.submitting,
          onPressed:
              state.stage == CheckoutStage.submitting
                  ? null
                  : controller.submitCheckout,
        ),
      ],
    );
  }
}
