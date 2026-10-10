import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/shop/shop_controller.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';
import '../../core/widget/store_navigation_icons.dart';
import '../search/store_search_action.dart';
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
              leading: IconButton(
                tooltip: 'الرجوع',
                onPressed: Get.back,
                icon: Icon(storeBackIcon(context), size: 19),
              ),
              title: Text('سلة المشتريات (${controller.cartQuantity})'),
              titleTextStyle: StoreTypography.title.copyWith(fontSize: 17),
              actions: [
                const StoreSearchAction(),
                if (controller.cartLines.isNotEmpty)
                  PopupMenuButton<String>(
                    tooltip: 'خيارات السلة',
                    onSelected: (_) => _confirmClear(context, controller),
                    itemBuilder:
                        (_) => const [
                          PopupMenuItem(
                            value: 'clear',
                            child: Text('مسح السلة'),
                          ),
                        ],
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: controller.refreshCart,
              color: StorePalette.purple,
              child:
                  controller.cartLines.isEmpty
                      ? const CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyCar(),
                          ),
                        ],
                      )
                      : SafeArea(
                        top: false,
                        child: ListView(
                          key: const PageStorageKey<String>(
                            'store-cart-scroll',
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            12,
                            10,
                            12,
                            18,
                          ),
                          children: [
                            ...controller.cartLines.map(
                              (line) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ItemShopCar(line: line),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _CouponSection(controller: controller),
                            const SizedBox(height: 12),
                            CartSummary(controller: controller),
                          ],
                        ),
                      ),
            ),
            bottomNavigationBar:
                controller.cartLines.isEmpty
                    ? null
                    : SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          12,
                          10,
                          12,
                          12,
                        ),
                        decoration: const BoxDecoration(
                          color: StorePalette.surface,
                          boxShadow: [StoreElevation.lowShadow],
                        ),
                        child: StoreButton(
                          label: 'إتمام الطلب',
                          height: 46,
                          isLoading: controller.isLoading,
                          onPressed:
                              controller.canCheckout
                                  ? controller.getUserById
                                  : null,
                        ),
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

class _CouponSection extends StatelessWidget {
  const _CouponSection({required this.controller});
  final ShopController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      border: Border.all(color: StorePalette.border),
      borderRadius: BorderRadius.circular(StoreRadii.lg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('كوبون خصم', style: StoreTypography.label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: controller.discountCodeController,
                  onChanged: controller.retainCouponIntent,
                  textInputAction: TextInputAction.done,
                  onSubmitted: controller.retainCouponIntent,
                  style: StoreTypography.body,
                  decoration: InputDecoration(
                    hintText: 'أدخل رمز الخصم',
                    hintStyle: StoreTypography.caption,
                    filled: true,
                    fillColor: StorePalette.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(StoreRadii.sm),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 42,
              child: FilledButton(
                onPressed: controller.isLoading ? null : controller.checkCode,
                style: FilledButton.styleFrom(
                  backgroundColor: StorePalette.lightPurple,
                  foregroundColor: StorePalette.purple,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(StoreRadii.sm),
                  ),
                  textStyle: StoreTypography.label,
                ),
                child: Text(controller.activeCode == true ? 'مفعّل' : 'تطبيق'),
              ),
            ),
          ],
        ),
        if (controller.activeCode == true &&
            controller.couponModel != null) ...[
          const SizedBox(height: 6),
          Text(
            'تم تطبيق خصم ${controller.couponModel!.discountAmount.toStringAsFixed(2)} ₪، وسيعيد الخادم التحقق عند إنشاء الطلب.',
            style: StoreTypography.caption.copyWith(
              color: StorePalette.success,
            ),
          ),
        ],
      ],
    ),
  );
}
