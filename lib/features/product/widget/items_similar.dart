import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/product/product_controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/images.dart';
import '../../../core/constants/styles.dart';
import '../../../core/model/get_all_item_model.dart';
import '../../../core/widget/custom_image_widget.dart';

Widget itemsSimilar({
  required ProductControllerImp productControllerImp,
  required BuildContext context,
}) {
  bool isAr =
      productControllerImp.localizationController.locale.languageCode == 'ar';
  bool isEng =
      productControllerImp.localizationController.locale.languageCode == 'en';
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        productControllerImp.item2.length,
        (index) => Padding(
          padding: EdgeInsetsDirectional.only(end: 10),
          child: InkWell(
            onTap: () async {
              await Get.find<ProductControllerImp>().getCategoryById2(
                itemId: productControllerImp.item2[index].id,
              );
            },
            child: SizedBox(
              height: 150.h,
              width: 105.w,
              child: Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      (productControllerImp.item2[index].discount > 0.0)
                          ? Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              width: 50.w,
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
                                "${"discount".tr} ${productControllerImp.item2[index].discount.toString()}%",
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeOverSmall,
                                ),
                              ),
                            ),
                          )
                          : SizedBox(),
                      CustomImageWidget(
                        height: 80,
                        image: _itemImage(productControllerImp.item2[index]),
                        // fit: BoxFit.fitWidth,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              isAr == 'ar'
                                  ? productControllerImp.item2[index].nameAr
                                  : isEng == 'en'
                                  ? productControllerImp.item2[index].nameEng
                                  : productControllerImp.item2[index].nameAbree,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeOverSmall.sp,
                                color: Theme.of(context).primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "⭐ ${productControllerImp.item2[index].rate}",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeOverSmall.sp,
                              color: Theme.of(context).hoverColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isAr == 'ar'
                            ? productControllerImp.item2[index].nameAr
                            : isEng == 'en'
                            ? productControllerImp.item2[index].nameEng
                            : productControllerImp.item2[index].nameAbree,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).hoverColor,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Flexible(
                        child: Text(
                          "₪ ${productControllerImp.item2[index].normailPrice}",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall.sp,
                            color: Theme.of(context).hoverColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            textAlign: TextAlign.start,
                            productControllerImp
                                    .item2[index]
                                    .itemSizes
                                    .isNotEmpty
                                ? ""
                                : "${"left".tr} ${productControllerImp.item2[index].stock} ${"pieces".tr}",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: const Color(0xff8e8e93),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
