import 'package:flutter/material.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/model/checkout_flow_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';

class CheckoutAddressStep extends StatelessWidget {
  const CheckoutAddressStep({required this.controller, super.key});
  final ShopController controller;

  @override
  Widget build(BuildContext context) => Form(
    key: controller.formstate,
    child: ListView(
      padding: const EdgeInsets.all(StoreSpacing.md),
      children: [
        Text('بيانات الاستلام', style: StoreTypography.headline),
        const SizedBox(height: StoreSpacing.md),
        _field('الاسم الكامل', controller.nameController),
        _field('رقم الهاتف', controller.phoneNumberController, phone: true),
        _field(
          'رقم هاتف بديل (اختياري)',
          controller.phoneNumber2Controller,
          optional: true,
          phone: true,
        ),
        _field('العنوان', controller.addressController, lines: 3),
        const SizedBox(height: StoreSpacing.md),
        StoreButton(
          label: 'متابعة إلى الشحن',
          onPressed: () {
            if (controller.formstate.currentState?.validate() == true) {
              controller.setCheckoutStage(CheckoutStage.shipping);
            }
          },
        ),
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController value, {
    bool optional = false,
    bool phone = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: StoreSpacing.sm),
    child: TextFormField(
      controller: value,
      maxLines: lines,
      keyboardType: phone ? TextInputType.phone : TextInputType.text,
      validator:
          optional
              ? null
              : (text) =>
                  text == null || text.trim().isEmpty
                      ? 'هذا الحقل مطلوب'
                      : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: StorePalette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StoreRadii.md),
        ),
      ),
    ),
  );
}
