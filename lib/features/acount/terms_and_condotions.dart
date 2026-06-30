import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/dimensions.dart';
import '../../core/constants/styles.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic text direction
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Terms and Conditions".tr,
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${"Terms and Conditions for Using the Doctor Bike App".tr}"
                  "${"Welcome to the Doctor Bike app. Please read these terms and conditions carefully before use.".tr}"
                  "${"By using this application, you agree to be bound by these terms and conditions.".tr}",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    height: 2,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: "${"1. Acceptance of the Terms".tr} : ",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).hintColor,
                    ),
                    children: [
                      TextSpan(
                        text:
                            "By downloading or using the Doctor Bike App, you agree to all terms and conditions set forth herein."
                                .tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          height: 2,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTermsSection(
                  "2. Registration and Use of the Account".tr,
                  "${"• The user must create an account to use the application with accurate and complete information.\n".tr}"
                  "${"You are responsible for protecting your account and notifying us immediately of any unauthorized activity.".tr}",
                  context,
                ),
                _buildTermsSection(
                  "3. Permitted Use".tr,
                  "You are permitted to use the Application only for lawful purposes in accordance with these Terms."
                      .tr,
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection(
    String title,
    String content,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            height: 2,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }
}
