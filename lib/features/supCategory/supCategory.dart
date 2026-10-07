// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/categores/categores_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/styles.dart';
import '../../core/widget/store_navigation_icons.dart';
import '../../repository/categories/categories_repository.dart';
import '../home_screen/widget/main_categorys.dart';

class SupcategoryScreen extends StatelessWidget {
  const SupcategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoresControllerImp controller = Get.put(
      CategoresControllerImp(
        categoriesRepository: CategoriesRepository(apiClient: Get.find()),
      ),
    );
    bool isAr = controller.localizationController.locale.languageCode == 'ar';
    bool isEng = controller.localizationController.locale.languageCode == 'en';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            storeBackIcon(context),
            color: Theme.of(context).hoverColor,
          ),
        ),
        title: Text(
          controller.titleMain.toString(),
          style: robotoRegular.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeExtraLarge,
          ),
        ),
      ),
      body:
          controller.supCategores.isNotEmpty
              ? Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 20.w,
                  vertical: 10.h,
                ),
                child: Obx(() {
                  return GridView.builder(
                    shrinkWrap: true,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // عدد الأعمدة
                      crossAxisSpacing: 5.w, // المسافة الأفقية بين العناصر
                      mainAxisSpacing: 5.h, // المسافة الرأسية بين العناصر
                      childAspectRatio: 0.75,
                    ),
                    itemCount: controller.supCategores.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          controller.mainCategoresId =
                              controller.supCategores[index].id;
                          controller.titleMain =
                              isAr
                                  ? controller.supCategores[index].nameAr
                                  : isEng
                                  ? controller.supCategores[index].nameEng
                                  : controller.supCategores[index].nameAbree;
                          await controller.getAllCategores(
                            controller.supCategores[index].id,
                          );
                        },
                        child: MainCategorys(
                          image:
                              controller.supCategores[index].imageUrl
                                  .toString(),
                          title:
                              isAr
                                  ? controller.supCategores[index].nameAr
                                  : isEng
                                  ? controller.supCategores[index].nameEng
                                  : controller.supCategores[index].nameAbree,
                        ),
                      );
                    },
                  );
                }),
              )
              : Center(
                child: Text(
                  'No SubCategory Found'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
    );
  }
}
