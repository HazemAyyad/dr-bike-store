import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/shop/shop_controller.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';
import 'widget/cart_summary.dart';
import 'widget/empty_car.dart';
import 'widget/item_shop_car.dart';

class ShopCarScreen extends StatelessWidget {
  const ShopCarScreen({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: GetBuilder<ShopController>(
      builder:
          (controller) => Scaffold(
            backgroundColor: StorePalette.background,
            appBar: AppBar(
              backgroundColor: StorePalette.surface,
              foregroundColor: StorePalette.textPrimary,
              elevation: 0,
              centerTitle: true,
              title: Text('shopping cart'.tr, style: StoreTypography.title),
              actions: [
                if (controller.cartLines.isNotEmpty)
                  StoreIconButton(
                    icon: Icons.delete_sweep_outlined,
                    semanticLabel: 'مسح السلة',
                    foregroundColor: StorePalette.error,
                    onPressed: () => _confirmClear(context, controller),
                  ),
              ],
            ),
            body:
                controller.cartLines.isEmpty
                    ? const EmptyCar()
                    : SafeArea(
                      top: false,
                      child: ListView(
                        padding: const EdgeInsets.all(StoreSpacing.md),
                        children: [
                          ...controller.cartLines.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: StoreSpacing.sm,
                              ),
                              child: ItemShopCar(line: line),
                            ),
                          ),
                          const SizedBox(height: StoreSpacing.xs),
                          Text('كود الخصم', style: StoreTypography.label),
                          const SizedBox(height: StoreSpacing.xs),
                          TextField(
                            controller: controller.discountCodeController,
                            onChanged: controller.retainCouponIntent,
                            decoration: InputDecoration(
                              hintText: 'أدخل كود الخصم',
                              filled: true,
                              fillColor: StorePalette.surface,
                              suffixIcon: TextButton(
                                onPressed:
                                    controller.isLoading
                                        ? null
                                        : controller.checkCode,
                                child: const Text('تحقق'),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  StoreRadii.md,
                                ),
                                borderSide: const BorderSide(
                                  color: StorePalette.border,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: StoreSpacing.md),
                          CartSummary(controller: controller),
                          const SizedBox(height: StoreSpacing.md),
                          StoreButton(
                            label: 'Checkout'.tr,
                            onPressed:
                                controller.canCheckout
                                    ? controller.getUserById
                                    : null,
                          ),
                        ],
                      ),
                    ),
          ),
    ),
  );

  Future<void> _confirmClear(
    BuildContext context,
    ShopController controller,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('مسح السلة؟'),
            content: const Text('سيتم حذف جميع المنتجات المحتفظ بها من السلة.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('مسح'),
              ),
            ],
          ),
    );
    if (accepted == true) controller.clearCart();
  }
}
