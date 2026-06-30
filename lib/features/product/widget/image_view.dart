import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/model/get_all_item_model.dart';
import '../../../core/widget/custom_image_widget.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.image});
  final NormalImageItem image;
  @override
  Widget build(BuildContext context) {
    // print(AppConstants.appBaseUrl + image.imageUrl);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 10.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.r)),
      child: Center(
        child: CustomImageWidget(
          image: image.imageUrl.toString(),
          fit: BoxFit.fill,
          width: 150.w,
          height: 125.h,
        ),
      ),
    );
  }
}
