// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controller/account/account_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';
import '../../core/functions/theme_services.dart';
import '../../core/widget/store_states.dart';
import '../../repository/auth/auth_repository.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  late final AccountControllerImp controller =
      Get.isRegistered<AccountControllerImp>()
          ? Get.find<AccountControllerImp>()
          : Get.put(
            AccountControllerImp(
              authRepository: AuthRepository(apiClient: Get.find()),
            ),
          );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.conactUsModel == null && !controller.contactLoading) {
        controller.getConactUs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic text direction
      child: GetBuilder<AccountControllerImp>(
        builder: (accountControllerImp) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                "Contact us".tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge2,
                  color: Theme.of(context).hoverColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body:
                accountControllerImp.contactLoading &&
                        accountControllerImp.conactUsModel == null
                    ? const StoreSkeletonList(itemCount: 4)
                    : accountControllerImp.contactMessage != null &&
                        accountControllerImp.conactUsModel == null
                    ? StoreMessageState(
                      kind: StoreMessageKind.error,
                      message: accountControllerImp.contactMessage!,
                      actionLabel: 'storeRetry'.tr,
                      onAction: accountControllerImp.getConactUs,
                    )
                    : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                "Our friendly team is ready to talk to you during business hours."
                                    .tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Theme.of(context).hintColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Buttons for Message and Call
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildContactButton(
                                  onTap: accountControllerImp.openCall,
                                  Images.iconCall,
                                  "Contact us",
                                  context,
                                ),
                                const SizedBox(width: 20),
                                _buildContactButton(
                                  onTap: accountControllerImp.openSms,
                                  Images.iconChat,
                                  "message".tr,
                                  context,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Divider with "أو"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Color(0xffeeeeee),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    "or".tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Color(0xffeeeeee),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Social Media Icons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialIcon(
                                  Images.facebookIcon,
                                  onTap: accountControllerImp.openTwitter,
                                ),
                                const SizedBox(width: 20),
                                _buildSocialIcon(
                                  Images.iconsInstagram,
                                  onTap: accountControllerImp.openInstagram,
                                ),
                                const SizedBox(width: 20),
                                _buildSocialIcon(
                                  Images.iconWhatsapp2,
                                  onTap: accountControllerImp.openWhatsApp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildContactButton(
    String icon,
    String text,
    BuildContext context, {
    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset(icon, width: 24.w, height: 24.h),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String icon, {void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        icon,
        width: 54.w,
        height: 50.h,
        color:
            icon != Images.iconTwitter
                ? null
                : (!ThemeServices().loadThemeFromBox() ? null : Colors.white),
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
