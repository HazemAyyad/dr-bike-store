import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/helper/route_helper.dart';
import '../../../core/model/checkout_flow_model.dart';
import '../../../core/model/store_address_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';
import '../../../core/widget/store_states.dart';

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
        _SavedAddressesSection(controller: controller),
        if (controller.checkoutAddresses.isEmpty) ...[
          const SizedBox(height: 10),
          _AccountAddressCard(controller: controller),
        ],
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
          onChanged: controller.onCheckoutAddressTextChanged,
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

class _SavedAddressesSection extends StatelessWidget {
  const _SavedAddressesSection({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.checkoutAddressesLoading &&
        controller.checkoutAddresses.isEmpty) {
      return const StoreSkeletonBox(height: 92, borderRadius: StoreRadii.lg);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                controller.checkoutAddresses.isEmpty
                    ? 'لا توجد عناوين محفوظة'
                    : 'اختر عنوانًا محفوظًا',
                style: StoreTypography.bodyMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await Get.toNamed(RouteHelper.addresses);
                await controller.loadCheckoutAddresses();
              },
              icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
              label: Text(
                controller.checkoutAddresses.isEmpty ? 'إضافة عنوان' : 'إدارة',
              ),
            ),
          ],
        ),
        if (controller.checkoutAddressesMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              controller.checkoutAddressesMessage!,
              style: StoreTypography.caption.copyWith(
                color: StorePalette.warning,
              ),
            ),
          ),
        ...controller.checkoutAddresses.map(
          (address) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _CheckoutAddressCard(
              address: address,
              selected: controller.selectedStoreAddress?.id == address.id,
              onTap:
                  address.isDeliveryReady
                      ? () => controller.selectCheckoutAddress(address)
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutAddressCard extends StatelessWidget {
  const _CheckoutAddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final StoreAddress address;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: StorePalette.surface,
    borderRadius: BorderRadius.circular(StoreRadii.md),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(StoreRadii.md),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(StoreRadii.md),
          border: Border.all(
            color: selected ? StorePalette.purple : StorePalette.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color:
                  onTap == null
                      ? StorePalette.textDisabled
                      : StorePalette.purple,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.label,
                          style: StoreTypography.label,
                        ),
                      ),
                      if (address.isDefault)
                        Text('افتراضي', style: StoreTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.streetAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: StoreTypography.body,
                  ),
                  Text(
                    address.isDeliveryReady
                        ? address.locationLabel
                        : 'غير مكتمل للشحن — عدّله قبل الاستخدام',
                    style: StoreTypography.caption.copyWith(
                      color:
                          address.isDeliveryReady
                              ? StorePalette.textSecondary
                              : StorePalette.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
