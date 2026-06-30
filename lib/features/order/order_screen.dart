import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/account/account_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/styles.dart';
import 'widget/order_canceled.dart';
import 'widget/order_completed.dart';
import 'widget/order_ongoing.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountControllerImp>(
      builder: (accountControllerImp) {
        bool isAr =
            accountControllerImp.localizationController.locale.languageCode ==
            'ar';
        bool isEng =
            accountControllerImp.localizationController.locale.languageCode ==
            'en';
        return RefreshIndicator(
          onRefresh: () => accountControllerImp.getAllOrders(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                "My orders".tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge2,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            body: Column(
              children: [
                Container(
                  width: 320.w,
                  height: 48.h,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xffeeeeee),
                    borderRadius: BorderRadius.circular(31.r),
                  ),
                  child: Row(
                    children: [
                      buildConditionButton(
                        accountControllerImp: accountControllerImp,
                        text: "Completed requests".tr,
                        index: 0,
                        context: context,
                        //   selectedCondition: selectedCondition,
                      ),
                      buildConditionButton(
                        accountControllerImp: accountControllerImp,
                        text: 'Current requests'.tr,
                        index: 1,
                        context: context,
                        // selectedCondition: selectedCondition,
                      ),
                      buildConditionButton(
                        accountControllerImp: accountControllerImp,
                        text: 'Cancelled requests'.tr,
                        index: 2,
                        context: context,
                        // selectedCondition: selectedCondition,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6b65bd),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Products'.tr,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: robotoRegular.copyWith(
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Request creation date'.tr,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: robotoRegular.copyWith(
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 25.w),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Order status'.tr,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: robotoRegular.copyWith(
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child:
                        accountControllerImp.selectedCondition == 0
                            ? accountControllerImp.ordersDone!.rows.isEmpty
                                ? Center(
                                  child: Text(
                                    "No complete applications".tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                )
                                : GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        childAspectRatio: 0.7,
                                        mainAxisExtent: 70.h,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                      ),
                                  itemCount:
                                      accountControllerImp
                                          .ordersDone
                                          ?.rows
                                          .length ??
                                      0,
                                  itemBuilder: (context, index) {
                                    if (accountControllerImp.ordersDone?.rows ==
                                        null) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    String items = '';
                                    for (
                                      int i = 0;
                                      i <
                                          accountControllerImp
                                              .ordersDone!
                                              .rows[index]
                                              .details
                                              .length;
                                      i++
                                    ) {
                                      items =
                                          "$items,${isAr
                                              ? accountControllerImp.ordersDone!.rows[index].details[i].item.nameAr
                                              : isEng
                                              ? accountControllerImp.ordersDone!.rows[index].details[i].item.nameEng
                                              : accountControllerImp.ordersDone!.rows[index].details[i].item.nameAbree}";
                                    }

                                    return OrderCompleted(
                                      order:
                                          accountControllerImp
                                              .ordersDone!
                                              .rows[index],
                                      text: items,
                                      date: accountControllerImp.formatDate(
                                        accountControllerImp
                                            .ordersDone!
                                            .rows[index]
                                            .dateUpdate,
                                      ),
                                    );
                                  },
                                )
                            : accountControllerImp.selectedCondition == 1
                            ? accountControllerImp.ordersNew!.rows.isEmpty
                                ? Center(
                                  child: Text(
                                    "There are no pending orders.".tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                )
                                : GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        childAspectRatio: 0.7,
                                        mainAxisExtent: 70.h,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                      ),
                                  itemCount:
                                      accountControllerImp
                                          .ordersNew
                                          ?.rows
                                          .length ??
                                      0,
                                  itemBuilder: (context, index) {
                                    if (accountControllerImp.ordersNew?.rows ==
                                        null) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    String items = '';
                                    for (
                                      int i = 0;
                                      i <
                                          accountControllerImp
                                              .ordersNew!
                                              .rows[index]
                                              .details
                                              .length;
                                      i++
                                    ) {
                                      items =
                                          "$items,${isAr
                                              ? accountControllerImp.ordersNew!.rows[index].details[i].item.nameAr
                                              : isEng
                                              ? accountControllerImp.ordersNew!.rows[index].details[i].item.nameEng
                                              : accountControllerImp.ordersNew!.rows[index].details[i].item.nameAbree}";
                                    }

                                    return OrderOngoing(
                                      text: items,
                                      order:
                                          accountControllerImp
                                              .ordersNew!
                                              .rows[index],
                                    );
                                  },
                                )
                            : accountControllerImp.ordersCanceled!.rows.isEmpty
                            ? Center(
                              child: Text(
                                "There are no canceled orders.".tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            )
                            : GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 0.7,
                                    mainAxisExtent: 70.h,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                  ),
                              itemCount:
                                  accountControllerImp
                                      .ordersCanceled
                                      ?.rows
                                      .length ??
                                  0,
                              itemBuilder: (context, index) {
                                if (accountControllerImp.ordersCanceled?.rows ==
                                    null) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                String items = '';
                                for (
                                  int i = 0;
                                  i <
                                      accountControllerImp
                                          .ordersCanceled!
                                          .rows[index]
                                          .details
                                          .length;
                                  i++
                                ) {
                                  items =
                                      "$items,${isAr
                                          ? accountControllerImp.ordersCanceled!.rows[index].details[i].item.nameAr
                                          : isEng
                                          ? accountControllerImp.ordersCanceled!.rows[index].details[i].item.nameEng
                                          : accountControllerImp.ordersCanceled!.rows[index].details[i].item.nameAbree}";
                                }

                                return OrderCanceled(
                                  text: items,
                                  date: accountControllerImp.formatDate(
                                    accountControllerImp
                                        .ordersCanceled!
                                        .rows[index]
                                        .dateUpdate,
                                  ),
                                  order:
                                      accountControllerImp
                                          .ordersCanceled!
                                          .rows[index],
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildConditionButton({
    required String text,
    required int index,
    // required int selectedCondition,
    required AccountControllerImp accountControllerImp,
    required BuildContext context,
  }) {
    bool isSelected = accountControllerImp.selectedCondition == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          accountControllerImp.selectedCondition = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        height: 40.h,
        width: 96.w,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeExtraSmall,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(31.r),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}
