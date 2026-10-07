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
      key: const PageStorageKey<String>('checkout-address-scroll'),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 22),
      children: [
        Text('عنوان التوصيل', style: StoreTypography.title),
        const SizedBox(height: 10),
        _AccountAddressCard(controller: controller),
        const SizedBox(height: 18),
        Text('بيانات التواصل', style: StoreTypography.title),
        const SizedBox(height: 10),
        _field(
          label: 'الاسم الكامل',
          value: controller.nameController,
          icon: Icons.person_outline_rounded,
          optional: true,
          readOnly: true,
        ),
        _field(
          label: 'رقم الهاتف',
          value: controller.phoneNumberController,
          icon: Icons.phone_outlined,
          optional: true,
          phone: true,
          readOnly: true,
        ),
        if (controller.phoneNumber2Controller.text.trim().isNotEmpty)
          _field(
            label: 'رقم هاتف بديل',
            value: controller.phoneNumber2Controller,
            icon: Icons.phone_in_talk_outlined,
            optional: true,
            phone: true,
            readOnly: true,
          ),
        Text(
          'بيانات الاتصال محفوظة في حسابك. يمكن تعديلها من الملف الشخصي.',
          style: StoreTypography.caption,
        ),
        const SizedBox(height: 20),
        StoreButton(
          label: 'متابعة الشحن',
          icon: Icons.arrow_back_rounded,
          onPressed: () {
            if (controller.formstate.currentState?.validate() == true) {
              controller.setCheckoutStage(CheckoutStage.shipping);
            }
          },
        ),
      ],
    ),
  );

  Widget _field({
    required String label,
    required TextEditingController value,
    required IconData icon,
    bool optional = false,
    bool phone = false,
    bool readOnly = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextFormField(
      controller: value,
      readOnly: readOnly,
      maxLines: lines,
      keyboardType: phone ? TextInputType.phone : TextInputType.text,
      validator:
          optional
              ? null
              : (text) =>
                  text == null || text.trim().isEmpty
                      ? 'هذا الحقل مطلوب'
                      : null,
      style: StoreTypography.body,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: StorePalette.textSecondary),
        filled: true,
        fillColor: readOnly ? StorePalette.background : StorePalette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StoreRadii.md),
          borderSide: const BorderSide(color: StorePalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StoreRadii.md),
          borderSide: const BorderSide(color: StorePalette.border),
        ),
      ),
    ),
  );
}

class _AccountAddressCard extends StatelessWidget {
  const _AccountAddressCard({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      border: Border.all(color: StorePalette.purple, width: 1.3),
      boxShadow: const [StoreElevation.lowShadow],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: StorePalette.purple,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('عنوان الحساب', style: StoreTypography.bodyMedium),
            ),
            const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: StorePalette.purple,
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller.addressController,
          minLines: 2,
          maxLines: 3,
          validator:
              (text) =>
                  text == null || text.trim().isEmpty
                      ? 'اكتب عنوان التوصيل'
                      : null,
          style: StoreTypography.body,
          decoration: InputDecoration(
            hintText: 'اكتب تفاصيل عنوان التوصيل',
            hintStyle: StoreTypography.caption,
            filled: true,
            fillColor: StorePalette.background,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(StoreRadii.md),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    ),
  );
}
