// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controller/home/home_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  final HomeControllerImp homeControllerImp = Get.find<HomeControllerImp>();
  @override
  Widget build(BuildContext context) {
    homeControllerImp.postNotificationsIsRead();
    return WillPopScope(
      onWillPop: () async {
        homeControllerImp.getNotifications();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Notifications".tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge2,
              color: Theme.of(context).hintColor,
            ),
          ),
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: Theme.of(context).hoverColor),
          ),
        ),
        body: Obx(() {
          if (homeControllerImp.notifications?.value.rows == null) {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColor,
              ),
            );
          }
          if (homeControllerImp.notifications!.value.rows == []) {
            return SizedBox();
          }
          return homeControllerImp.notifications!.value.rows.isEmpty
              ? Center(
                child: Text(
                  'Empty Notification',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: Color(0xff7f7f7f),
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                itemCount: homeControllerImp.notifications!.value.rows.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5.h),
                    width: 370.w,
                    height: 75.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault.r,
                      ),
                      border: Border.all(
                        color: const Color(0xffd9d9d9).withOpacity(0.61),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.h,
                          padding: const EdgeInsets.all(5),
                          margin: EdgeInsetsDirectional.only(start: 15.w),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault.r,
                            ),
                          ),
                          child: SvgPicture.asset(
                            Images.notification,
                            fit: BoxFit.fitWidth,
                            width: 38.w,
                            height: 40.h,
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              homeControllerImp
                                  .notifications!
                                  .value
                                  .rows[index]
                                  .title,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Text(
                              homeControllerImp
                                  .notifications!
                                  .value
                                  .rows[index]
                                  .content,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              homeControllerImp.formatDate(
                                homeControllerImp
                                    .notifications!
                                    .value
                                    .rows[index]
                                    .createdAt,
                              ),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
        }),
      ),
    );
  }
}
