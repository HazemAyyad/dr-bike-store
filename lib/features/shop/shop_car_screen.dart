import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controller/shop/shop_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';
import 'widget/empty_car.dart';
import 'widget/list_item_car.dart';

class ShopCarScreen extends StatelessWidget {
  const ShopCarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(
      builder: (controller) {
        controller.cal();
        controller.saveCart();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              "shopping cart".tr,
              style: robotoRegular.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Theme.of(context).hoverColor,
              ),
            ),
            leading: const SizedBox(),
            actions: [
              GestureDetector(
                onTap: () {
                  controller.isThree.value = !controller.isThree.value;
                  controller.update();
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 10),
                  child: Center(
                    child:
                        controller.changeList
                            ? !controller.isThree.value
                                ? SizedBox(
                                  height: 30,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                              border: Border.all(
                                                width: 1.5,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                              border: Border.all(
                                                width: 1.5,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 30,
                                        height: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                )
                                : SizedBox(
                                  height: 30,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                              border: Border.all(
                                                width: 1.5,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Container(
                                            width: 8,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                              border: Border.all(
                                                width: 1.5,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Container(
                                            width: 8,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                              border: Border.all(
                                                width: 1.5,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 30,
                                        height: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                )
                            : SizedBox(),
                  ),
                ),
              ),

              SizedBox(width: 15.w),
              InkWell(
                onTap: () {
                  controller.changeList = !controller.changeList;
                  controller.update();
                },
                child: SvgPicture.asset(
                  controller.changeList == true
                      ? Images.iconList2
                      : Images.iconList3,
                ),
              ),
              SizedBox(width: 15.w),
            ],
          ),
          body:
              controller.items.isEmpty
                  ? EmptyCar()
                  : ListItemCar(isThree: controller.isThree.value),
        );
      },
    );
  }
}
