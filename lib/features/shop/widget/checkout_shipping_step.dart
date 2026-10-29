import 'package:doctor_bike/core/theme/store_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/model/checkout_flow_model.dart';
import '../../../core/model/city_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';
import '../../../core/widget/store_city_picker.dart';
import '../../../core/widget/store_skeletons.dart';
import 'cart_summary.dart';

class CheckoutShippingStep extends StatelessWidget {
  const CheckoutShippingStep({required this.controller, super.key});

  final ShopController controller;

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey<String>('checkout-shipping-scroll'),
    padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 22),
    children: [
      Text(
        'طريقة الشحن'.tr,
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
                    'التوصيل عبر Shiply'.tr,
                    style: StoreColors.text(
                      context,
                      StoreTypography.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'تُحسب التكلفة من المنطقة المختارة'.tr,
                    style: StoreColors.text(context, StoreTypography.caption),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.local_shipping_outlined,
              color: StorePalette.purple,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'منطقة التوصيل'.tr,
        style: StoreColors.text(context, StoreTypography.title),
      ),
      const SizedBox(height: 10),
      StoreCityPicker(
        cities: controller.cities,
        value:
            controller.cities
                .where((c) => c.id.toString() == controller.selectedCityId)
                .firstOrNull,
        onChanged: controller.onCitySelected,
        decoration: _decoration('المدينة'.tr, Icons.location_city_outlined),
      ),
      const SizedBox(height: 9),
      if (controller.isVillagesLoading)
        StoreInlineFieldSkeleton(label: 'جارٍ تحميل مناطق التوصيل'.tr)
      else
        DropdownButtonFormField<ShiplyVillage>(
          value:
              controller.villages
                  .where((v) => v.id.toString() == controller.selectedVillageId)
                  .firstOrNull,
          isExpanded: true,
          items:
              controller.villages
                  .where((v) => !v.isClosed)
                  .map(
                    (village) => DropdownMenuItem(
                      value: village,
                      child: Text(village.name),
                    ),
                  )
                  .toList(),
          onChanged:
              controller.selectedCityId == null
                  ? null
                  : (village) {
                    if (village != null) controller.onVillageSelected(village);
                  },
          decoration: _decoration('القرية / المنطقة'.tr, Icons.place_outlined),
        ),
      const SizedBox(height: 10),
      if (controller.isDeliveryLoading)
        StoreInlineFieldSkeleton(
          height: 48,
          label: 'جارٍ احتساب تكلفة الشحن'.tr,
        )
      else if (controller.selectedVillageId != null &&
          controller.hasAuthoritativeDeliveryQuote)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: StoreColors.resolve(context, StorePalette.lightPurple),
            borderRadius: BorderRadius.circular(StoreRadii.md),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 19,
                color: StorePalette.purple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تكلفة الشحن الحالية'.tr,
                  style: StoreColors.text(context, StoreTypography.body),
                ),
              ),
              Text(
                '${_price(controller.selectedCityPrice)} ₪',
                style: StoreColors.text(
                  context,
                  StoreTypography.label,
                ).copyWith(color: StorePalette.purple),
              ),
            ],
          ),
        ),
      if (!controller.isDeliveryLoading &&
          controller.selectedVillageId != null &&
          !controller.hasAuthoritativeDeliveryQuote)
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: StoreColors.resolve(
              context,
              StorePalette.derivedWarningSurface,
            ),
            borderRadius: BorderRadius.circular(StoreRadii.md),
          ),
          child: Text(
            controller.deliveryQuoteMessage ??
                'storeDeliveryQuoteUnavailable'.tr,
            style: StoreColors.text(context, StoreTypography.caption).copyWith(
              color: StoreColors.resolve(context, StorePalette.textPrimary),
            ),
          ),
        ),
      if (!controller.isDeliveryLoading &&
          controller.selectedVillageId != null &&
          !controller.hasAuthoritativeDeliveryQuote)
        TextButton(
          onPressed: controller.calculateDeliveryFeeForSelectedVillage,
          child: Text('storeRetry'.tr),
        ),
      const SizedBox(height: 18),
      Text(
        'ملخص الطلب'.tr,
        style: StoreColors.text(context, StoreTypography.title),
      ),
      const SizedBox(height: 10),
      CartSummary(controller: controller, forCheckout: true),
      const SizedBox(height: 18),
      StoreButton(
        label: 'متابعة الدفع'.tr,
        icon: Icons.arrow_forward_rounded,
        iconAtEnd: true,
        onPressed:
            controller.selectedVillageId == null ||
                    controller.isDeliveryLoading ||
                    !controller.hasAuthoritativeDeliveryQuote
                ? null
                : () => controller.setCheckoutStage(CheckoutStage.payment),
      ),
    ],
  );

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: StorePalette.textSecondary),
    filled: true,
    fillColor: StorePalette.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(StoreRadii.md),
      borderSide: const BorderSide(color: StorePalette.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(StoreRadii.md),
      borderSide: const BorderSide(color: StorePalette.border),
    ),
  );
}

String _price(num value) => NumberFormat('#,##0.##', 'en_US').format(value);
