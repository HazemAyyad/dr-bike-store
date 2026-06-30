// ignore_for_file: must_be_immutable, unrelated_type_equality_checks, deprecated_member_use

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
import '../../core/widget/custom_image_widget.dart';
import '../../repository/categories/categories_repository.dart';
import '../../repository/shop/shop_repository.dart';
import 'widget/build_list_view.dart';

class CategoryAndFiltter extends StatefulWidget {
  const CategoryAndFiltter({super.key});

  @override
  State<CategoryAndFiltter> createState() => _CategoryAndFiltterState();
}

class _CategoryAndFiltterState extends State<CategoryAndFiltter> {
  final CategoresControllerImp controller = Get.put(
    CategoresControllerImp(
      categoriesRepository: CategoriesRepository(apiClient: Get.find()),
    ),
  );
  final ShopController shopController = Get.put(
    ShopController(shopRepository: ShopRepository(apiClient: Get.find())),
  );
  @override
  void initState() {
    controller.filtter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        controller.useFiltter = false.obs;
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
              controller.useFiltter = false.obs;
            },
            icon: const Icon(Icons.arrow_back, color: Color(0xff7f7f7f)),
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
              () => Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 10),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      controller.isThree.value = !controller.isThree.value;
                    },
                    child:
                        controller.isGrid.value
                            ? controller.isThree.value
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
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
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
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
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
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
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
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
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
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
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
            ),
            SizedBox(width: 15.w),
            Obx(
              () => InkWell(
                onTap: () {
                  controller.isGrid.value = !controller.isGrid.value;
                },
                child: SvgPicture.asset(
                  controller.isGrid.value ? Images.iconList2 : Images.iconList3,
                  width: 28.w,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            SizedBox(width: 15.w),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          return controller.itemList!.rows.isEmpty
              ? Center(
                child: Text(
                  'No Item Found',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              controller.isGrid == true
                                  ? controller.isThree.value
                                      ? 3
                                      : 2
                                  : 1,
                          childAspectRatio: 0.7,
                          mainAxisExtent:
                              controller.isGrid == false ? 102.h : 170.h,
                          crossAxisSpacing: controller.isGrid == false ? 5 : 15,
                          mainAxisSpacing: controller.isGrid == false ? 5 : 10,
                        ),
                        itemCount: controller.filteredProducts.length,
                        itemBuilder: (context, index) {
                          return (!controller.isGrid.value == true
                              ? BuildListView(
                                item: controller.itemList!.rows[index],
                              )
                              : (controller.isThree.value
                                  ? buildThreeItem(
                                    item: controller.itemList!.rows[index],
                                    context: context,
                                    controller: shopController,
                                  )
                                  : buildTwoItem(
                                    item: controller.itemList!.rows[index],
                                    context: context,
                                    controller: shopController,
                                  )));
                        },
                      ),
                    ),
                  ),
                ],
              );
        }),
      ),
    );
  }

  Widget buildThreeItem({
    required Item item,
    required BuildContext context,
    required ShopController controller,
  }) {
    bool isAr = controller.localizationController.locale.languageCode == 'ar';
    bool isEng = controller.localizationController.locale.languageCode == 'en';
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
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall.sp,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).hoverColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "₪ ${controller.token == null ? item.normailPrice : (controller.isNormail ? item.normailPrice : item.wholesalePrice)}",
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
    bool isAr = controller.localizationController.locale.languageCode == 'ar';
    bool isEng = controller.localizationController.locale.languageCode == 'en';
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
                "₪ ${controller.token == null ? item.normailPrice : (controller.isNormail ? item.normailPrice : item.wholesalePrice)}",
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
