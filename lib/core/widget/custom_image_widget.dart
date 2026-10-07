import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';
import '../constants/images.dart';
import 'store_states.dart';

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
    final resolvedHeight = height ?? 85.h;
    return CachedNetworkImage(
      placeholder:
          (context, url) => SizedBox(
            height: resolvedHeight,
            width: width,
            child: const StoreSkeletonBox(borderRadius: 0),
          ),
      imageUrl: AppConstants.appBaseUrl + image,
      fit: fit ?? BoxFit.cover,
      height: resolvedHeight,
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
