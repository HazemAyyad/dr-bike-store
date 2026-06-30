import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controller/shop/shop_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';
import '../../core/helper/route_helper.dart';

class CheckOutDone extends StatefulWidget {
  const CheckOutDone({super.key});

  @override
  State<CheckOutDone> createState() => _CheckOutDoneState();
}

class _CheckOutDoneState extends State<CheckOutDone> {
  @override
  void initState() {
    _navigatetohome();
    super.initState();
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(seconds: 3), () {
      Get.toNamed(RouteHelper.homePage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(
      builder: (controller) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity),
                SvgPicture.asset(
                  Images.done,
                  width: 160.w,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: 270.w,
                  child: Text(
                    "Your order has been completed".tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: Dimensions.paddingSizeExtremeLarge,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: 270.w,
                  child: Text(
                    "Your order is being followed up with number #${controller.OrderId} and you will receive a notification of the order status"
                        .tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge2,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
