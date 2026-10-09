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
                ? 'لا يوجد اتصال بالإنترنت'
                : state.stage == CheckoutStage.uncertain
                ? 'نتيجة الطلب غير مؤكدة'
                : 'راجع بيانات الطلب',
        message: state.message ?? 'تعذر إتمام الطلب.',
        actionLabel: 'إعادة المحاولة',
        onAction: controller.submitCheckout,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(StoreSpacing.md),
      children: [
        Text('مراجعة الطلب', style: StoreTypography.headline),
        const SizedBox(height: StoreSpacing.md),
        ...controller.checkoutLines.map(
          (line) => ListTile(
            title: Text(line.nameAr),
            subtitle: Text('الكمية: ${line.quantity}'),
            trailing: Text('${line.total.toStringAsFixed(2)} ₪'),
          ),
        ),
        const Divider(),
        Text(
          'العنوان: ${controller.addressController.text}',
          style: StoreTypography.body,
        ),
        Text(
          'الوجهة: ${controller.selectedCity ?? ''} — ${controller.selectedVillage ?? ''}',
          style: StoreTypography.body,
        ),
        Text(
          'عرض التوصيل الحالي: ${controller.selectedCityPrice.toStringAsFixed(2)} ₪',
          style: StoreTypography.body,
        ),
        Text('الدفع: نقدًا عند الاستلام', style: StoreTypography.body),
        Text(
          'نوع الحساب: ${state.selectedRole ?? ''}',
          style: StoreTypography.body,
        ),
        const SizedBox(height: StoreSpacing.sm),
        Text(
          'الأسعار والتوفر ورسوم التوصيل النهائية يعتمدها الخادم عند الإرسال.',
          style: StoreTypography.caption,
        ),
        const SizedBox(height: StoreSpacing.lg),
        StoreButton(
          label: 'تأكيد الطلب',
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
