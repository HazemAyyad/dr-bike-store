import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../controller/product/product_controller.dart';
import '../../../core/constants/dimensions.dart';

class ViewImageAndVideo extends StatefulWidget {
  const ViewImageAndVideo({
    super.key,
    required this.items,
    required this.controllerScreen,
  });
  final List<Widget> items;
  final ProductControllerImp controllerScreen;

  @override
  State<ViewImageAndVideo> createState() => _ViewImageAndVideoState();
}

class _ViewImageAndVideoState extends State<ViewImageAndVideo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                widget.controllerScreen.currentPage = index;
              });
              widget.controllerScreen.update();
            },
            aspectRatio: 1 / 1,
            height: 145.h,
            // enlargeCenterPage: true,
          ),
          items: widget.items,
        ),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (index) {
            if (widget.items.length == 1) {
              return const SizedBox.shrink();
            }
            return AnimatedContainer(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: widget.controllerScreen.currentPage == index ? 34.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusExtraLarge,
                ),
                color:
                    widget.controllerScreen.currentPage == index
                        ? Theme.of(context).primaryColor
                        : const Color(0xffa9a9a9),
              ),
              duration: const Duration(milliseconds: 500),
            );
          }),
        ),
      ],
    );
  }
}
