import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';

Future<bool> alertExitApp(BuildContext context) {
  Get.defaultDialog(
      title: "".tr,
      titleStyle:  TextStyle(
          color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold,fontSize: 14),
      middleText: "doYouWantExit".tr,
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(Theme.of(context).primaryColor)),
            onPressed: () {
              exit(0);
            },
            child: Text("sure".tr,
                style: robotoMedium.copyWith(color: Theme.of(context).cardColor))),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(Theme.of(context).primaryColor)),
            onPressed: () {
              Get.back();
            },
            child: Text(
              "cancel".tr,
              style:  robotoMedium.copyWith(color: Theme.of(context).cardColor),
            ))
      ]);
  return Future.value(true);
}
