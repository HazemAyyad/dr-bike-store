import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home/home_controller.dart';
import '../../controller/order/order_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';
import '../../core/widget/store_bottom_navigation.dart';

enum CheckoutSuccessAction { orders, home }

StoreDestination checkoutSuccessDestination(CheckoutSuccessAction action) =>
    switch (action) {
      CheckoutSuccessAction.orders => StoreDestination.orders,
      CheckoutSuccessAction.home => StoreDestination.home,
    };

Future<void> openCheckoutSuccessDestination(
  CheckoutSuccessAction action,
) async {
  final destination = checkoutSuccessDestination(action);
  if (action == CheckoutSuccessAction.orders &&
      Get.isRegistered<OrderController>()) {
    await Get.find<OrderController>().load(filter: OrderListFilter.current);
  }
  if (Get.isRegistered<HomeControllerImp>()) {
    await Get.find<HomeControllerImp>().selectDestination(destination);
  }
  await Get.offAllNamed(RouteHelper.homePage);
}

class CheckOutDone extends StatefulWidget {
  const CheckOutDone({super.key});

  @override
  State<CheckOutDone> createState() => _CheckOutDoneState();
}

class _CheckOutDoneState extends State<CheckOutDone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 680),
  )..forward();
  late final Animation<double> _scale = CurvedAnimation(
    parent: _animation,
    curve: Curves.elasticOut,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _animation,
    curve: const Interval(0, .72, curve: Curves.easeOut),
  );

  @override
  Widget build(BuildContext context) => GetBuilder<ShopController>(
    builder: (controller) {
      final orderId = controller.checkoutState.orderId ?? controller.OrderId;
      final orderNumber =
          controller.checkoutState.orderNumber?.trim().isNotEmpty == true
              ? controller.checkoutState.orderNumber!.trim()
              : orderId;
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: FadeTransition(
                    opacity: _fade,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                      decoration: BoxDecoration(
                        color: StorePalette.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: StorePalette.border),
                        boxShadow: const [StoreElevation.mediumShadow],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _scale,
                            child: Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                color: StorePalette.derivedSuccessSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: StorePalette.success,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: StorePalette.success,
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'تم إنشاء طلبك',
                            style: StoreTypography.headline.copyWith(
                              color: StorePalette.navy,
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'وصل الطلب بنجاح، وسنظهر لك كل تحديث في شاشة طلباتي.',
                            style: StoreTypography.body.copyWith(
                              color: StorePalette.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: StorePalette.background,
                              borderRadius: BorderRadius.circular(
                                StoreRadii.lg,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  color: StorePalette.purple,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'رقم الطلب',
                                        style: StoreTypography.caption,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '#$orderNumber',
                                        key: const Key(
                                          'checkout-success-order-number',
                                        ),
                                        textDirection: TextDirection.ltr,
                                        style: StoreTypography.title.copyWith(
                                          color: StorePalette.navy,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: StorePalette.success,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          StoreButton(
                            label: 'متابعة الطلب',
                            icon: Icons.local_shipping_outlined,
                            onPressed:
                                () => openCheckoutSuccessDestination(
                                  CheckoutSuccessAction.orders,
                                ),
                          ),
                          const SizedBox(height: 8),
                          StoreButton(
                            label: 'العودة إلى المتجر',
                            icon: Icons.storefront_outlined,
                            variant: StoreButtonVariant.secondary,
                            onPressed:
                                () => openCheckoutSuccessDestination(
                                  CheckoutSuccessAction.home,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }
}
