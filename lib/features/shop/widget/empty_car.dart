import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/images.dart';
import '../../../core/constants/styles.dart';

class EmptyCar extends StatelessWidget {
  const EmptyCar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Images.shopCar,
            width: 250.w,
            height: 250.h,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            "Your shopping cart is empty".tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge2,
              color: Theme.of(context).hoverColor,
            ),
          ),
        ],
      ),
    );
  }
}
