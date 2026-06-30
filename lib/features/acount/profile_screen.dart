// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controller/LocalizationController.dart';
import '../../controller/account/account_controller.dart';
import '../../controller/shop/shop_controller.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/theme_services.dart';
import '../../core/helper/route_helper.dart';
import '../../core/widget/build_bottom_sheet_button.dart';
import '../../core/widget/build_dialog_button.dart';
import '../../core/widget/dialog_login_and_register.dart';
import '../../repository/shop/shop_repository.dart';
import 'widget/profile_item.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final ShopController shopController = Get.put(
    ShopController(shopRepository: ShopRepository(apiClient: Get.find())),
  );
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountControllerImp>(
      builder: (accountControllerImp) {
        accountControllerImp.loadingToken();
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset(
                    !ThemeServices().loadThemeFromBox()
                        ? Images.logo
                        : Images.logoDark,
                    width: 100.w,
                    height: 70.h,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Profile".tr,
                    style: TextStyle(
                      color: Theme.of(context).hoverColor,

                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  accountControllerImp.token != null
                      ? ProfileItem(
                        icon: Images.iconPersonal,
                        title: "Personal Details".tr,
                        onTap: () async {
                          accountControllerImp.getUserById();
                        },
                      )
                      : BuildDialogButton(
                        borderSideColor: Theme.of(context).primaryColor,
                        text: "register/log in.".tr,
                        bgColor: Colors.white,
                        fontSize: Dimensions.fontSizeDefault,
                        textColor: Theme.of(context).primaryColor,
                        horizontal: 10,
                        vertical: 4,
                        borderRadius: 12,
                        onPressed: () async {
                          Get.toNamed(RouteHelper.intoLog);
                        },
                      ),
                  accountControllerImp.token != null
                      ? ProfileItem(
                        icon: Images.iconLock,
                        title: "change password".tr,
                        onTap:
                            () => Get.toNamed(RouteHelper.changePasswordScreen),
                      )
                      : SizedBox(),
                  ProfileItem(
                    icon: Images.iconBox,
                    title: "My orders".tr,
                    onTap: () async {
                      if (await AppUsageService.getToken() != null) {
                        accountControllerImp.getAllOrders();
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
                  ),
                  ProfileItem(
                    icon: Images.iconDocument,
                    title: "Terms and Conditions".tr,
                    onTap: () => Get.toNamed(RouteHelper.termsConditionsPage),
                  ),
                  ProfileItem(
                    icon: Images.iconInfo,
                    title: "Who are we".tr,
                    onTap: () => Get.toNamed(RouteHelper.aboutUsScreen),
                  ),
                  ProfileItem(
                    icon: Images.iconCall,
                    title: "Contact us".tr,
                    onTap: () => Get.toNamed(RouteHelper.contactUsPage),
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        barrierColor: const Color(0xffd9d9d9).withOpacity(0.45),
                        backgroundColor: Colors.transparent,
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return GetBuilder<LocalizationController>(
                            builder: (localizationController) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffffffff),
                                      borderRadius: BorderRadius.circular(25.r),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Doctor Bike will start to apply this change"
                                              .tr,
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: const Color(
                                              0xff091133,
                                            ).withOpacity(0.58),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        const Divider(
                                          thickness: 1,
                                          color: Color(0xffeeeeee),
                                        ),
                                        const SizedBox(height: 10),
                                        localizationController.selectedIndex !=
                                                0
                                            ? BuildBottomSheetButton(
                                              text: "تغيير إلى اللغة العربية",
                                              bgColor:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                              textColor:
                                                  Theme.of(context).hoverColor,
                                              onPressed: () {
                                                localizationController
                                                    .setLanguage(
                                                      Locale(
                                                        AppConstants
                                                            .languages[0]
                                                            .languageCode!,
                                                        AppConstants
                                                            .languages[0]
                                                            .countryCode,
                                                      ),
                                                    );
                                                localizationController
                                                    .setSelectIndex(0);
                                                Navigator.pop(context);
                                              },
                                            )
                                            : const SizedBox(),
                                        localizationController.selectedIndex !=
                                                1
                                            ? BuildBottomSheetButton(
                                              text: "Change to English",
                                              bgColor:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                              textColor:
                                                  Theme.of(context).hoverColor,

                                              onPressed: () {
                                                localizationController
                                                    .setLanguage(
                                                      Locale(
                                                        AppConstants
                                                            .languages[1]
                                                            .languageCode!,
                                                        AppConstants
                                                            .languages[1]
                                                            .countryCode,
                                                      ),
                                                    );
                                                localizationController
                                                    .setSelectIndex(1);
                                                Navigator.pop(context);
                                              },
                                            )
                                            : const SizedBox(),
                                        SizedBox(height: 5.h),
                                        localizationController.selectedIndex !=
                                                2
                                            ? BuildBottomSheetButton(
                                              text: "שנה לעברית",
                                              bgColor:
                                                  Theme.of(context).hoverColor,
                                              textColor:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,

                                              onPressed: () {
                                                localizationController
                                                    .setLanguage(
                                                      Locale(
                                                        AppConstants
                                                            .languages[2]
                                                            .languageCode!,
                                                        AppConstants
                                                            .languages[2]
                                                            .countryCode,
                                                      ),
                                                    );
                                                localizationController
                                                    .setSelectIndex(2);
                                                Navigator.pop(context);
                                              },
                                            )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Container(
                                    margin: EdgeInsetsDirectional.only(
                                      bottom: 40.h,
                                    ),
                                    height: 50.h,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffffffff),
                                      borderRadius: BorderRadius.circular(25.r),
                                    ),
                                    child: BuildBottomSheetButton(
                                      text: "Cancel".tr,
                                      bgColor: Colors.white,
                                      textColor: Colors.black,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              Images.iconLang,
                              width: 24.w,
                              height: 24.h,
                              color:
                                  !ThemeServices().loadThemeFromBox()
                                      ? Theme.of(context).hoverColor
                                      : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'the language'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              (accountControllerImp
                                          .localizationController
                                          .locale
                                          .languageCode) ==
                                      'ar'
                                  ? "العربية"
                                  : (accountControllerImp
                                          .localizationController
                                          .locale
                                          .languageCode) ==
                                      'en'
                                  ? 'English'
                                  : 'Hebrew',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).hintColor,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            Images.iconTheme,
                            width: 24.w,
                            height: 24.h,
                            color:
                                !ThemeServices().loadThemeFromBox()
                                    ? Theme.of(context).hoverColor
                                    : Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'night mode'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: accountControllerImp.isDarkMode,
                        onChanged: (value) {
                          accountControllerImp.isDarkMode = value;
                          ThemeServices().switchTheme();
                          accountControllerImp.update();
                        },
                        inactiveThumbColor: Theme.of(context).primaryColor,
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  accountControllerImp.token != null
                      ? GetPlatform.isIOS
                          ? Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(0),
                                ),
                                onPressed: () {
                                  showDialog(
                                    barrierColor: const Color(
                                      0xffd9d9d9,
                                    ).withOpacity(0.45),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        insetPadding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14.r,
                                          ),
                                        ),
                                        title: Center(
                                          child: Text(
                                            "Do you want to delete the account?"
                                                .tr,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                        actions: [
                                          BuildDialogButton(
                                            text: "Yes".tr,
                                            bgColor: Colors.red,
                                            textColor: Colors.white,
                                            onPressed: () async {
                                              // await PreferenceUtils.clearAllPreferences();
                                              accountControllerImp
                                                  .deleteUserAccount();
                                              // Perform logout action
                                            },
                                          ),
                                          BuildDialogButton(
                                            text: "cancel".tr,
                                            bgColor: Colors.white,
                                            textColor: Colors.red,
                                            onPressed: () async {
                                              Get.back();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 24.w,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      "delete account".tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          : SizedBox()
                      : SizedBox(),

                  accountControllerImp.token != null
                      ? Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(0),
                          ),
                          onPressed: () {
                            _showLogoutDialog(context);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                Images.iconExit,
                                width: 24.w,
                                height: 24.h,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "Log out".tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    barrierColor: const Color(0xffd9d9d9).withOpacity(0.45),
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Center(
          child: Text(
            "Are you sure you want to log out?".tr,
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
          BuildDialogButton(
            text: "Yes".tr,
            bgColor: Colors.red,
            textColor: Colors.white,
            onPressed: () async {
              // await PreferenceUtils.clearAllPreferences();
              await AppUsageService.deleteIsLogin();
              await AppUsageService.deleteToken();
              await AppUsageService.deleteUserEmail();
              await AppUsageService.deleteUserId();
              await AppUsageService.deleteUserName();
              await AppUsageService.deleteTypeUser();
              await Get.find<AccountControllerImp>().loadingToken();
              Get.back();
              // Perform logout action
            },
          ),
          BuildDialogButton(
            text: "cancel".tr,
            bgColor: Colors.white,
            textColor: Colors.red,
            onPressed: () async {
              Get.back();
            },
          ),
        ],
      );
    },
  );
}
