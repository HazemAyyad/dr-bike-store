import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/dimensions.dart';
import '../helper/route_helper.dart';
import 'build_dialog_button.dart';

class DialogLoginAndRegister extends StatelessWidget {
  const DialogLoginAndRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BuildDialogButton(
            text: "logIn".tr,
            bgColor: Theme.of(context).primaryColor,
            textColor: Colors.white,
            horizontal: 10,
            vertical: 4,
            borderSideColor: Theme.of(context).primaryColor,
            fontSize: Dimensions.fontSizeDefault,

            onPressed: () {
              Get.toNamed(RouteHelper.signIn);
            },
          ),
          BuildDialogButton(
            borderSideColor: Theme.of(context).primaryColor,
            text: "createAccount".tr,
            bgColor: Colors.white,
            fontSize: Dimensions.fontSizeDefault,
            textColor: Theme.of(context).primaryColor,
            horizontal: 10,
            vertical: 4,
            onPressed: () async {
              Get.toNamed(RouteHelper.signUp);
            },
          ),
        ],
      ),
    );
  }
}
