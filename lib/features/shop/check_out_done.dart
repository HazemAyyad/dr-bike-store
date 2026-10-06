import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/shop/shop_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';

class CheckOutDone extends StatelessWidget {
  const CheckOutDone({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<ShopController>(
    builder: (controller) {
      final orderId = controller.checkoutState.orderId ?? controller.OrderId;
      if (orderId == null || orderId.trim().isEmpty) {
        return const Scaffold(
          body: Center(child: Text('تعذر عرض تأكيد دون رقم طلب معتمد.')),
        );
      }
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: StorePalette.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(StoreSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 88,
                    color: StorePalette.success,
                  ),
                  const SizedBox(height: StoreSpacing.lg),
                  Text(
                    'تم استلام طلبك بنجاح',
                    style: StoreTypography.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: StoreSpacing.sm),
                  Text(
                    'رقم الطلب المعتمد: #$orderId',
                    style: StoreTypography.title,
                  ),
                  const SizedBox(height: StoreSpacing.xl),
                  StoreButton(
                    label: 'عرض طلباتي',
                    onPressed: () => Get.offAllNamed(RouteHelper.homePage),
                  ),
                  const SizedBox(height: StoreSpacing.sm),
                  StoreButton(
                    label: 'العودة للرئيسية',
                    variant: StoreButtonVariant.secondary,
                    onPressed: () => Get.offAllNamed(RouteHelper.homePage),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
