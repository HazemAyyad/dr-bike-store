import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';
import '../constants/images.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  const CustomImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder = Images.logo,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder:
          (context, url) => Image.asset(
            placeholder ?? Images.logo,
            height: height,
            width: width,
          ),
      imageUrl: AppConstants.appBaseUrl + image,
      fit: fit ?? BoxFit.cover,
      height: height ?? 85.h,
      width: width,
      errorWidget:
          (c, o, s) => Image.asset(
            placeholder ?? Images.logo,
            height: height,
            width: width,
            fit: BoxFit.fitWidth,
          ),
    );
  }
}
