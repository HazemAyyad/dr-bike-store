import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/images.dart';
import '../../../core/constants/styles.dart';
import '../../../core/functions/theme_services.dart';
import '../../../core/model/commint_model.dart';

List<Widget> showMoreCommints({required RxList<Review> commints}) {
  return commints.map((com) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      margin: EdgeInsetsDirectional.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color:
            ThemeServices().theme == ThemeMode.light
                ? Colors.grey.shade100
                : Color(0xff202020),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundImage: AssetImage(Images.item)),
              const SizedBox(width: 8),
              Text(
                com.userName,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xff878787),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            com.comment,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: const Color(0xff7f7f7f),
            ),
          ),
        ],
      ),
    );
  }).toList();
}

List<Widget> showLessCommints({required RxList<Review> commints}) {
  int i = 0;

  return commints.map((com) {
    if (i < 5) {
      i++;
      return Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        margin: EdgeInsetsDirectional.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color:
              ThemeServices().theme == ThemeMode.light
                  ? Colors.grey.shade100
                  : Color(0xff202020),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundImage: AssetImage(Images.item)),
                const SizedBox(width: 8),
                Text(
                  com.userName,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color:
                        ThemeServices().theme == ThemeMode.light
                            ? const Color(0xff878787)
                            : Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              com.comment,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color:
                    ThemeServices().theme == ThemeMode.light
                        ? const Color(0xff878787)
                        : Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }).toList();
}
