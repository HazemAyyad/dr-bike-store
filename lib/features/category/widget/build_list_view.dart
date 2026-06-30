import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/product/product_controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/images.dart';
import '../../../core/constants/styles.dart';
import '../../../core/model/get_all_item_model.dart';
import '../../../core/widget/custom_image_widget.dart';
import '../../../repository/categories/categories_repository.dart';

class BuildListView extends StatelessWidget {
  const BuildListView({super.key, required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    final ProductControllerImp productControllerImp = Get.put(
      ProductControllerImp(
        categoriesRepository: CategoriesRepository(apiClient: Get.find()),
      ),
    );
    bool isAr =
        productControllerImp.localizationController.locale.languageCode == 'ar';
    bool isEng =
        productControllerImp.localizationController.locale.languageCode == 'en';
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            radius: 10.r,
            onTap: () async {
              await Get.find<ProductControllerImp>().getCategoryById(
                itemId: item.id,
              );
            },
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: CustomImageWidget(
                image: _itemImage(item),
                width: 82.w,
                height: 66.h,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.55,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    _itemCategoryName(item, isAr, isEng),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).hoverColor,
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        isAr
                            ? item.nameAr
                            : isEng
                            ? item.nameEng
                            : item.nameAbree,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      "₪ ${productControllerImp.token == null ? item.normailPrice : (productControllerImp.isNormail ? item.normailPrice : item.wholesalePrice)}",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).hoverColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.h),
                Row(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.itemSizes.isNotEmpty ? '' : "left".tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: const Color(0xff7f7f7f),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10.h),
                        Center(
                          child: Text(
                            item.itemSizes.isNotEmpty ? '' : " ${item.stock} ",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: const Color(0xff7f7f7f),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item.itemSizes.isNotEmpty ? '' : "pieces".tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: const Color(0xff7f7f7f),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _itemImage(Item item) {
    if (item.viewImagesItems.isNotEmpty) {
      final imageUrl = item.viewImagesItems.first.imageUrl;
      if (imageUrl.trim().isNotEmpty) return imageUrl;
    }

    final normalImages = item.normalImagesItems;
    if (normalImages != null && normalImages.isNotEmpty) {
      final imageUrl = normalImages.first.imageUrl;
      if (imageUrl.trim().isNotEmpty) return imageUrl;
    }

    return Images.logo;
  }

  String _itemCategoryName(Item item, bool isAr, bool isEng) {
    if (item.supCategory.isNotEmpty) {
      final category = item.supCategory.first;
      final categoryName =
          isAr
              ? category.nameAr
              : isEng
              ? category.nameEng
              : category.nameAbree;
      if (categoryName.trim().isNotEmpty) return categoryName;
    }

    return isAr
        ? item.nameAr
        : isEng
        ? item.nameEng
        : item.nameAbree;
  }
}
