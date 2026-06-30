import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/product/product_controller.dart';
import '../../../controller/shop/shop_controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/images.dart';
import '../../../core/constants/styles.dart';
import '../../../core/model/get_all_item_model.dart';
import '../../../core/widget/button.dart';
import '../../../core/widget/custom_image_widget.dart';
import '../../../core/widget/custom_snackbar.dart';
import '../../../repository/categories/categories_repository.dart';
import '../../../repository/shop/shop_repository.dart';

class BuildGridView extends StatelessWidget {
  const BuildGridView({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final ShopController shopController = Get.put(
      ShopController(shopRepository: ShopRepository(apiClient: Get.find())),
    );
    final ProductControllerImp productControllerImp = Get.put(
      ProductControllerImp(
        categoriesRepository: CategoriesRepository(apiClient: Get.find()),
      ),
    );
    bool isAr =
        productControllerImp.localizationController.locale.languageCode == 'ar';
    bool isEng =
        productControllerImp.localizationController.locale.languageCode == 'en';
    return GestureDetector(
      onTap: () async {
        await Get.find<ProductControllerImp>().getCategoryById(itemId: item.id);
      },
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.r)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (item.discount != 0.0)
                  ? Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      width: isEng ? 70.w : 50.w,
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(3.r),
                          bottomStart: Radius.circular(3.r),
                          topEnd: Radius.circular(15.r),
                          bottomEnd: Radius.circular(15.r),
                        ),
                      ),
                      child: Text(
                        "${"discount".tr} ${item.discount}%",
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeOverSmall,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  : const SizedBox(),
              CustomImageWidget(
                image: _itemImage(item),
                height: 70.h,
                fit: BoxFit.fill,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 50.w,
                    child: Text(
                      _itemCategoryName(item, isAr, isEng),

                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "⭐ ${item.rate}",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).hoverColor,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 110.w,
                child: Center(
                  child: Text(
                    isAr
                        ? item.nameAr
                        : isEng
                        ? item.nameEng
                        : item.nameAbree,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).hoverColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: Center(
                  child: Text(
                    "${item.normailPrice}₪",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).hoverColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 58.w,
                    child: Text(
                      item.itemSizes.isNotEmpty
                          ? ''
                          : "${"left".tr} ${item.stock} ${"pieces".tr}",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: const Color(0xff8e8e93),
                      ),
                    ),
                  ),
                  DefaultButtom(
                    colorShadow: Colors.transparent,
                    Child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Add".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                        Icon(
                          Icons.shopping_cart,
                          size: 9.w,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Height: 22.h,
                    Width: 55.w,
                    colorBorder: Colors.transparent,
                    PaddingHorizontal: 0,
                    PaddingVertical: 0,
                    radius: 7.r,
                    OnTap: () {
                      if (item.itemSizes.isNotEmpty) {
                        if (item.itemSizeId == null) {
                          showCustomSnackBar(
                            "The product contains more than one size in different colors."
                                .tr,
                            isError: true,
                          );
                        } else if (item.itemSizeColorId == null) {
                          showCustomSnackBar(
                            'Select the desired color'.tr,
                            isError: true,
                          );
                        }

                        if (item.itemSizeId != null &&
                            item.itemSizeColorId != null) {
                          item.isSize = true;
                          shopController.addItem(item);
                        }
                      }

                      shopController.update();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
