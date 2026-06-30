import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/LocalizationController.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/helper/route_helper.dart';
import '../../../core/model/orders_model.dart';

class OrderCompleted extends StatefulWidget {
  const OrderCompleted({
    super.key,
    required this.date,
    required this.text,
    required this.order,
  });
  final String text;
  final String date;
  final Order order;
  @override
  State<OrderCompleted> createState() => _OrderCompletedState();
}

class _OrderCompletedState extends State<OrderCompleted> {
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );
  int maxLine = 4;
  @override
  Widget build(BuildContext context) {
    bool isAr = localizationController.locale.languageCode == 'ar';
    bool isEng = localizationController.locale.languageCode == 'en';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(RouteHelper.orderDetailsScreen, arguments: widget.order);
      },
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          vertical: 5.h,
          horizontal: 10.w,
        ),
        decoration: BoxDecoration(
          color: Color(0xffeeeeee),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "#${widget.order.orderNumber}",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.text,
                    maxLines: maxLine,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xff7f7f7f),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        Get.defaultDialog(
                          title:
                              "${"Order Details".tr} #${widget.order.orderNumber}",

                          content: SingleChildScrollView(
                            child: Column(
                              children:
                                  widget.order.details.map((detail) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 150.w),
                                        Text(
                                          "${"item".tr} #${detail.id}",
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: const Color(0xff7f7f7f),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.symmetric(
                                                horizontal: 10,
                                              ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${"name".tr}: ${isAr
                                                    ? detail.item.nameAr
                                                    : isEng
                                                    ? detail.item.nameEng
                                                    : detail.item.nameAbree}",
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: const Color(
                                                    0xff7f7f7f,
                                                  ),
                                                ),
                                              ),
                                              detail.isOrderSize
                                                  ? Text(
                                                    "${"Color".tr}: ${isAr
                                                        ? detail.itemSizeColor!.colorAr
                                                        : isEng
                                                        ? detail.itemSizeColor!.colorEn
                                                        : detail.itemSizeColor!.colorAbbr}",
                                                    style: robotoMedium.copyWith(
                                                      fontSize:
                                                          Dimensions
                                                              .fontSizeSmall,
                                                      color: const Color(
                                                        0xff7f7f7f,
                                                      ),
                                                    ),
                                                  )
                                                  : SizedBox(),
                                              detail.isOrderSize
                                                  ? Text(
                                                    "${"Size".tr}: ${detail.itemSize!.size}",
                                                    style: robotoMedium.copyWith(
                                                      fontSize:
                                                          Dimensions
                                                              .fontSizeSmall,
                                                      color: const Color(
                                                        0xff7f7f7f,
                                                      ),
                                                    ),
                                                  )
                                                  : SizedBox(),
                                              Text(
                                                "${"Quantity".tr}:${detail.quantity}",
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: const Color(
                                                    0xff7f7f7f,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "${"price".tr}:${detail.itemPrice}",
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: const Color(
                                                    0xff7f7f7f,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        );
                      });
                    },
                    child: Text(
                      "More".tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xff7f7f7f),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              flex: 2,
              child: Text(
                widget.date,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xff7f7f7f),
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              flex: 2,
              child: Container(
                width: 70.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: const Color(0xff5aed47),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Center(
                  child: Text(
                    "Complete".tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xff0a4f01),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
