import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/categores/categores_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/styles.dart';
import '../../core/functions/theme_services.dart';
import '../../core/widget/custom_button.dart';
import '../../core/widget/custom_text_field.dart';
import 'category_and_filtter.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoresControllerImp>(
      builder: (categoresControllerImp) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Get.back();
                categoresControllerImp.tabViewController.index = 0;
                categoresControllerImp.useFiltter = false.obs;
              },
              icon: Icon(Icons.arrow_back, color: const Color(0xff7f7f7f)),
            ),
            title: Text(
              "filtering".tr,
              style: robotoBold.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "the price".tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPriceField(
                          "lowest price".tr,
                          categoresControllerImp.priceRange.start
                              .toInt()
                              .toString(),
                        ),
                        SizedBox(width: 10.w),
                        _buildPriceField(
                          "Highest price".tr,
                          categoresControllerImp.priceRange.end
                              .toInt()
                              .toString(),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: categoresControllerImp.priceRange,
                      min: 0,
                      max: 10000,
                      divisions: 100,

                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (RangeValues values) {
                        setState(() {
                          categoresControllerImp.priceRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      radius: 8.r,
                      buttonText: "Refine search".tr,
                      color: Theme.of(context).hoverColor,
                      textColor:
                          !ThemeServices().loadThemeFromBox()
                              ? Colors.white
                              : Theme.of(context).primaryColor,

                      fontSize: Dimensions.fontSizeLarge,
                      onPressed: () {
                        Get.to(() => CategoryAndFiltter());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceField(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 5),
        CustomTextField(
          hintText: value,
          colorBorder: const Color(0xffeeeeee),
          colorFill: const Color(0xffeeeeee),
          height: 40.h,
          width: 154.w,
          borderRadius: 9.r,
          fontSize: 14.sp,
        ),
      ],
    );
  }
}
