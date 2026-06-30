// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/account/account_controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/helper/route_helper.dart';
import '../../../core/model/orders_model.dart';
import '../../../repository/auth/auth_repository.dart' show AuthRepository;

class OrderOngoing extends StatefulWidget {
  const OrderOngoing({super.key, required this.text, required this.order});
  final String text;
  final Order order;
  @override
  State<OrderOngoing> createState() => _OrderOngoingState();
}

class _OrderOngoingState extends State<OrderOngoing> {
  final AccountControllerImp accountControllerImp = Get.put(
    AccountControllerImp(authRepository: AuthRepository(apiClient: Get.find())),
  );
  int maxLine = 4;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openDetails,
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
                    onTap: _openDetails,
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
            SizedBox(width: 10.w),
            Expanded(
              flex: 2,
              child: Text(
                accountControllerImp.formatDate(widget.order.dateUpdate),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xff7f7f7f),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 60.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: const Color(0xffeded47),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Center(
                      child: Text(
                        "ongoing".tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xff0a4f01),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        barrierColor: const Color(0xffd9d9d9).withOpacity(0.45),
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            insetPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            title: Center(
                              child: Text(
                                "Do you want to cancel the order?".tr,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              _buildDialogButton(
                                "Yes".tr,
                                Colors.red,
                                Colors.white,
                                () async {
                                  accountControllerImp.editAllOrders(
                                    order: widget.order,
                                  );
                                },
                              ),
                              _buildDialogButton(
                                "cancel".tr,
                                Colors.white,
                                Colors.red,
                                () async {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 60.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "cancel".tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Icon(
                              Icons.block_flipped,
                              color: Colors.red,
                              size: 12.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails() {
    Get.toNamed(RouteHelper.orderDetailsScreen, arguments: widget.order);
  }
}

Widget _buildDialogButton(
  String text,
  Color bgColor,
  Color textColor,
  VoidCallback onPressed,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: Colors.red),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: textColor,
        ),
      ),
    ),
  );
}

Widget buildBottomSheetButton(
  String text,
  Color bgColor,
  Color textColor,
  VoidCallback onPressed,
) {
  return SizedBox(
    height: 45.h,
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.transparent),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
