import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/state_manager.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/functions/theme_services.dart';

class BillDetails extends StatelessWidget {
  const BillDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Invoice details".tr,
                  style: robotoBold.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8, width: double.infinity),
              buildDetailRow("order number:".tr, "#", context),
              buildDetailRow(
                "Full Name:".tr,
                controller.nameController.text,
                context,
              ),
              buildDetailRow(
                "Mobile number:".tr,
                controller.phoneNumberController.text,
                context,
              ),
              buildDetailRow(
                "Alternative mobile number:".tr,
                controller.phoneNumber2Controller.text,
                context,
              ),
              buildDetailRow(
                "City:".tr,
                controller.selectedCity.toString(),
                context,
              ),
              buildDetailRow(
                "Detailed address:".tr,
                controller.addressController.text,
                context,
              ),
              Divider(color: Colors.grey[500]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "number of pieces".tr,
                    style: robotoRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  Text(
                    "${controller.quantity} ${"Pieces".tr}",
                    style: robotoBold.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: Dimensions.fontSizeLarge,
                      color:
                          ThemeServices().loadThemeFromBox()
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 7.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delivery price:".tr,
                      style: robotoBold.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    Text(
                      "${controller.selectedCityPrice}₪",
                      style: robotoBold.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: Dimensions.fontSizeLarge,
                        color:
                            ThemeServices().loadThemeFromBox()
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Total Price".tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color:
                              ThemeServices().loadThemeFromBox()
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      Text(
                        "(Including delivery)".tr,
                        style: robotoRegular.copyWith(
                          color: Colors.grey,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${controller.selectedCityPrice + controller.totalPrice}₪",
                    style: robotoBold.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: Dimensions.fontSizeLarge,
                      color:
                          ThemeServices().loadThemeFromBox()
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget buildDetailRow(
  String title,
  String value,
  BuildContext context, {
  bool isBold = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: robotoBold.copyWith(
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        SizedBox(width: 5.w),
        SizedBox(
          width: 120.w,
          child: Text(
            value,
            style: robotoRegular.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
