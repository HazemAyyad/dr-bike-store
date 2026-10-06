// ignore_for_file: must_be_immutable, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controller/categores/categores_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/widget/custom_image_widget.dart';
import '../../repository/categories/categories_repository.dart';
import '../../repository/shop/shop_repository.dart';
import 'widget/build_list_view.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});
  final CategoresControllerImp controller = Get.put(
    CategoresControllerImp(
      categoriesRepository: CategoriesRepository(apiClient: Get.find()),
    ),
  );
  final ShopController shopController = Get.put(
    ShopController(shopRepository: ShopRepository(apiClient: Get.find())),
  );
  final ProductControllerImp productControllerImp = Get.put(
    ProductControllerImp(
      categoriesRepository: CategoriesRepository(apiClient: Get.find()),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Theme.of(context).hoverColor),
        ),
        title: Text(
          controller.titleMain.toString(),
          style: robotoRegular.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeExtraLarge,
          ),
        ),
        actions: [
          Obx(
            () => Center(
              child: InkWell(
                onTap: () {
                  controller.isThree.value = !controller.isThree.value;
                },
                child:
                    !controller.isGrid.value
                        ? !controller.isThree.value
                            ? SizedBox(
                              height: 30,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                          border: Border.all(
                                            width: 1.5,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                          border: Border.all(
                                            width: 1.5,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: 30,
                                    height: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            )
                            : SizedBox(
                              height: 30,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                          border: Border.all(
                                            width: 1.5,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Container(
                                        width: 8,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                          border: Border.all(
                                            width: 1.5,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Container(
                                        width: 8,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                          border: Border.all(
                                            width: 1.5,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: 30,
                                    height: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            )
                        : SizedBox(),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Obx(
            () => InkWell(
              onTap: () {
                controller.isGrid.value = !controller.isGrid.value;
              },
              child: SvgPicture.asset(
                !controller.isGrid.value ? Images.iconList2 : Images.iconList3,
                width: 28.w,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          SizedBox(width: 15.w),
          CircleAvatar(
            backgroundColor: const Color(0xffeeeeee),
            child: Opacity(
              opacity: 0.38,
              child: SvgPicture.asset(
                Images.iconFilter2,
                width: 18.w,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SizedBox(width: 15.w),
        ],
      ),
      body: Obx(() {
        final state = controller.catalogState.value;
        if (state is StoreLoading<List<Item>>) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is StoreOffline<List<Item>>) {
          return _CatalogMessage(
            message: state.message,
            icon: Icons.wifi_off,
            onRetry:
                () => controller.getProductsByOnlineStoreCategory(
                  controller.selectedOnlineStoreCategoryId,
                  navigate: false,
                ),
          );
        }
        if (state is StoreError<List<Item>>) {
          return _CatalogMessage(
            message: state.message,
            icon: Icons.error_outline,
            onRetry:
                () => controller.getProductsByOnlineStoreCategory(
                  controller.selectedOnlineStoreCategoryId,
                  navigate: false,
                ),
          );
        }
        if (state is StoreEmpty<List<Item>>) {
          return _CatalogMessage(
            message: state.message,
            icon: Icons.inventory_2_outlined,
            onRetry:
                () => controller.getProductsByOnlineStoreCategory(
                  controller.selectedOnlineStoreCategoryId,
                  navigate: false,
                ),
          );
        }
        return controller.itemList?.rows.isNotEmpty ?? false
            ? RefreshIndicator(
              onRefresh:
                  () => controller.getProductsByOnlineStoreCategory(
                    controller.selectedOnlineStoreCategoryId,
                    navigate: false,
                  ),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 10.w,
                          vertical: 10.h,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    controller.isGrid == true
                                        ? 1
                                        : controller.isThree.value
                                        ? 3
                                        : 2,
                                childAspectRatio:
                                    controller.isThree.value ? 0.51 : 0.69,
                                mainAxisExtent:
                                    controller.isGrid == true ? 102.h : null,
                                crossAxisSpacing: 5,
                                mainAxisSpacing:
                                    controller.isGrid == true
                                        ? 5
                                        : controller.isThree.value
                                        ? 5
                                        : 10,
                              ),
                          itemCount: controller.itemList?.rows.length ?? 0,
                          itemBuilder: (context, index) {
                            return (controller.isGrid == true
                                ? BuildListView(
                                  item: controller.itemList!.rows[index],
                                )
                                : controller.isThree.value
                                ? buildThreeItem(
                                  item: controller.itemList!.rows[index],
                                  context: context,
                                  controller: shopController,
                                )
                                : buildTwoItem(
                                  item: controller.itemList!.rows[index],
                                  context: context,
                                  controller: shopController,
                                ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            : Center(
              child: Text(
                'No Item Found'.tr,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            );
      }),
    );
  }

  Widget buildThreeItem({
    required Item item,
    required BuildContext context,
    required ShopController controller,
  }) {
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
          padding: const EdgeInsets.all(7.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (item.discount != 0.0)
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
              CustomImageWidget(image: _itemImage(item)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
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
              Flexible(
                child: Text(
                  isAr
                      ? item.nameAr
                      : isEng
                      ? item.nameEng
                      : item.nameAbree,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall.sp,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).hoverColor,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "₪ ${item.normailPrice}",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hoverColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.itemSizes.isNotEmpty
                        ? ""
                        : "${"left".tr} ${item.stock} ${"pieces".tr}",
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
    );
  }

  Widget buildTwoItem({
    required Item item,
    required BuildContext context,
    required ShopController controller,
  }) {
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
              CustomImageWidget(image: _itemImage(item), fit: BoxFit.fill),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _itemCategoryName(item, isAr, isEng),

                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "⭐ ${item.rate}",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hoverColor,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Center(
                  child: Text(
                    isAr
                        ? item.nameAr
                        : isEng
                        ? item.nameEng
                        : item.nameAbree,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall.sp,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).hoverColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Text(
                "₪ ${item.normailPrice}",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).hoverColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.itemSizes.isNotEmpty
                        ? ""
                        : "${"left".tr} ${item.stock} ${"pieces".tr}",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xff8e8e93),
                    ),
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
    return item.storefrontMedia.firstWhere((media) => media.isMain).path;
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

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
    required this.message,
    required this.icon,
    required this.onRetry,
  });
  final String message;
  final IconData icon;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: Theme.of(context).hintColor),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: Text('Retry'.tr)),
      ],
    ),
  );
}
