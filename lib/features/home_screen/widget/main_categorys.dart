import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widget/custom_image_widget.dart';

class MainCategorys extends StatelessWidget {
  final String image;
  final String title;
  const MainCategorys({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CustomImageWidget(
              image: image,
              // height: 65.h,
              // width: 95.w,
              // fit: BoxFit.fill,
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Center(
                child: Text(
                  title,
                  style: robotoBold.copyWith(
                    color: Theme.of(context).hoverColor,
                    fontSize: Dimensions.fontSizeExtraSmall.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
