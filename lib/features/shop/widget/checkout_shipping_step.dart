import 'package:flutter/material.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/model/checkout_flow_model.dart';
import '../../../core/model/city_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';

class CheckoutShippingStep extends StatelessWidget {
  const CheckoutShippingStep({required this.controller, super.key});
  final ShopController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(StoreSpacing.md),
    children: [
      Text('الشحن', style: StoreTypography.headline),
      const SizedBox(height: StoreSpacing.md),
      DropdownButtonFormField<Citys>(
        value:
            controller.cities
                .where((c) => c.id.toString() == controller.selectedCityId)
                .firstOrNull,
        items:
            controller.cities
                .map(
                  (city) => DropdownMenuItem(
                    value: city,
                    child: Text(city.cityNameAr),
                  ),
                )
                .toList(),
        onChanged: (city) {
          if (city != null) controller.onCitySelected(city);
        },
        decoration: const InputDecoration(
          labelText: 'المدينة',
          filled: true,
          fillColor: StorePalette.surface,
        ),
      ),
      const SizedBox(height: StoreSpacing.sm),
      if (controller.isVillagesLoading)
        const Center(child: CircularProgressIndicator())
      else
        DropdownButtonFormField<ShiplyVillage>(
          value:
              controller.villages
                  .where((v) => v.id.toString() == controller.selectedVillageId)
                  .firstOrNull,
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
          onChanged: (village) {
            if (village != null) controller.onVillageSelected(village);
          },
          decoration: const InputDecoration(
            labelText: 'القرية / المنطقة',
            filled: true,
            fillColor: StorePalette.surface,
          ),
        ),
      const SizedBox(height: StoreSpacing.md),
      if (controller.isDeliveryLoading)
        const LinearProgressIndicator()
      else if (controller.selectedVillageId != null)
        Text(
          'عرض التوصيل الحالي: ${controller.selectedCityPrice.toStringAsFixed(2)} ₪\nيعيد الخادم التحقق منه عند إنشاء الطلب.',
          style: StoreTypography.body,
        ),
      const SizedBox(height: StoreSpacing.lg),
      StoreButton(
        label: 'متابعة إلى الدفع',
        onPressed:
            controller.selectedVillageId == null
                ? null
                : () => controller.setCheckoutStage(CheckoutStage.payment),
      ),
    ],
  );
}
