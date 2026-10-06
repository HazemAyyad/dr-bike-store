// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'package:doctor_bike/features/shop/widget/build_three_item.dart';
import 'package:doctor_bike/features/shop/widget/build_two_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/functions/app_usage_service.dart';
import '../../../core/functions/theme_services.dart';
import '../../../core/widget/button.dart';
import '../../../core/widget/dialog_login_and_register.dart';
import 'item_shop_car.dart';

class ListItemCar extends StatefulWidget {
  ListItemCar({super.key, required this.isThree});
  bool isThree;

  @override
  State<ListItemCar> createState() => _ListItemCarState();
}

class _ListItemCarState extends State<ListItemCar> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(
      builder: (controller) {
        controller.cal();
        controller.saveCart();
        return Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 15.w,
                vertical: 2.h,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                width:
                    controller.changeList == true
                        ? double.infinity
                        : MediaQuery.of(context).size.width * 0.8,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        controller.changeList == false
                            ? 1
                            : controller.isThree.value
                            ? 3
                            : 2,
                    mainAxisExtent:
                        controller.changeList == false ? 102.h : 180.h,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: controller.changeList == false ? 10 : 5,
                    mainAxisSpacing: controller.changeList == false ? 10 : 5,
                  ),
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    return controller.changeList == false
                        ? ItemShopCar(line: controller.cartLines[index])
                        : controller.isThree.value
                        ? BuildThreeItem(item: controller.items[index])
                        : BuildTwoItem(item: controller.items[index]);
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 20.w,
                vertical: 3.h,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.18,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).disabledColor,
                    offset: const Offset(0, -8),
                    blurRadius: 5.r,
                  ),
                ],
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "number of pieces".tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: const Color(0xff7f7f7f),
                        ),
                      ),
                      Text(
                        "${controller.quantity} ${"Pieces".tr}",
                        style: robotoRegular.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).hoverColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Price".tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).hoverColor,
                        ),
                      ),
                      Text(
                        "${controller.priceItems}"
                        "₪",
                        style: robotoRegular.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).hoverColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "*Price does not include delivery".tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xff7f7f7f),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  DefaultButtom(
                    color:
                        !ThemeServices().loadThemeFromBox()
                            ? Theme.of(context).hoverColor
                            : Theme.of(context).primaryColor,
                    PaddingVerticalText: 0,
                    colorShadow: Theme.of(context).scaffoldBackgroundColor,
                    Child: Text(
                      "Transfer to payment".tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    Width: double.infinity,
                    PaddingHorizontal: 0,
                    colorBorder: Colors.transparent,

                    PaddingVertical: 0,
                    radius: 7.r,
                    OnTap: () async {
                      if (await AppUsageService.getToken() != null) {
                        controller.getUserById();
                      } else {
                        Get.defaultDialog(
                          titlePadding: EdgeInsets.only(top: 15, bottom: 5),
                          title: "You must register/log in.".tr,
                          titleStyle: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Theme.of(context).primaryColor,
                          ),
                          content: DialogLoginAndRegister(),
                        );
                      }
                    },
                    Height: 35.h,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
