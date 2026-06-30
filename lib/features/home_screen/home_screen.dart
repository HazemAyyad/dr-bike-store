// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/categores/categores_controller.dart';
import '../../controller/check_account/account_service.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/helper/route_helper.dart';
import '../../core/widget/custom_button.dart';
import '../../core/widget/custom_image_widget.dart';
import '../../core/widget/dialog_login_and_register.dart';
import '../../repository/home/home_repository.dart';
import 'widget/main_categorys.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var shopController = Get.find<ShopController>();
    final CategoresControllerImp categoresControllerImp =
        Get.find<CategoresControllerImp>();

    final HomeControllerImp homeControllerImp = Get.put(
      HomeControllerImp(homeRepository: HomeRepository(apiClient: Get.find())),
    );

    bool isAr =
        homeControllerImp.localizationController.locale.languageCode == 'ar';
    bool isEng =
        homeControllerImp.localizationController.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          if (await AppUsageService.getToken() != null) {
            await Get.find<HomeControllerImp>().getNotifications();
          }
          await Get.find<HomeControllerImp>().getMainCategores();
          await Get.find<HomeControllerImp>().getOnlineAds();
          await Get.find<HomeControllerImp>().getAllItemIsMoreSales();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // appbar
                  Row(
                    children: [
                      InkWell(
                        radius: 17.r,
                        onTap: () => Get.toNamed(RouteHelper.searchScreen),
                        child: Container(
                          width: 270.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17.r),
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                            border: Border.all(
                              width: 1,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  Images.iconSearch,
                                  width: 25.w,
                                  fit: BoxFit.fill,
                                  color: const Color(0xff7f7f7f),
                                ),
                              ),
                              Text(
                                "search".tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Color(0xff7f7f7f),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        alignment: AlignmentDirectional.topStart,
                        children: [
                          Container(
                            width: 42.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                            child: IconButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                              ),
                              icon: Image.asset(
                                Images.iconNotification,
                                width: 24.w,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                Get.put(
                                  () async => ApiService().checkAccountStatus(),
                                );
                                if (await AppUsageService.getToken() != null) {
                                  Get.toNamed(RouteHelper.notificationScreen);
                                } else {
                                  Get.defaultDialog(
                                    titlePadding: EdgeInsets.only(
                                      top: 15,
                                      bottom: 5,
                                    ),
                                    title: "You must register/log in.".tr,
                                    titleStyle: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    content: DialogLoginAndRegister(),
                                  );
                                }
                              },
                            ),
                          ),
                          homeControllerImp.isNotificationNotRead.value
                              ? Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              )
                              : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Carousel Slider
                  Obx(() {
                    if (homeControllerImp.adsResponse.isEmpty &&
                        homeControllerImp.isLoadingGetOnlineAds.value == true) {
                      return _HomeBannerSkeleton();
                    } else if (homeControllerImp.adsResponse.isEmpty &&
                        homeControllerImp.isLoadingGetOnlineAds.value ==
                            false) {
                      return SizedBox();
                    }
                    return Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            onPageChanged: (index, reason) {
                              homeControllerImp.currentPage.value = index;
                            },
                            aspectRatio: 16 / 10,
                            height: 110.h,
                            viewportFraction: 0.95,
                            autoPlay:
                                homeControllerImp.adsResponse.length == 1
                                    ? false
                                    : true,
                            enlargeCenterPage: true,
                          ),
                          items:
                              homeControllerImp.adsResponse.map((img) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.h,
                                    horizontal: 10.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 160.w,
                                            child: Text(
                                              img.description,
                                              style: robotoBold.copyWith(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).hoverColor,
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          CustomButton(
                                            buttonText: "Shop now".tr,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 12.sp,
                                            width: 70.w,
                                            isBold: false,
                                            height: 27.h,
                                            radius: 15.r,
                                            onPressed: () {
                                              homeControllerImp.openWeb(
                                                homeControllerImp
                                                    .adsResponse[homeControllerImp
                                                        .currentPage
                                                        .value]
                                                    .urlAds,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 5.w),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CustomImageWidget(
                                          image: img.imgUrl,
                                          fit: BoxFit.fitWidth,
                                          width: 125.w,
                                          height: 125.h,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            homeControllerImp.adsResponse.length,
                            (index) {
                              return buildDot(
                                index: index,
                                context: context,
                                currentPage:
                                    homeControllerImp.currentPage.value,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),

                  SizedBox(height: 30.h),
                  // Best-Selling Products Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Best selling products".tr,
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).hoverColor,
                        ),
                      ),
                      Obx(
                        () => Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 10,
                          ),
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                homeControllerImp.isTwo.value =
                                    !homeControllerImp.isTwo.value;
                              },
                              child:
                                  homeControllerImp.isTwo.value
                                      ? SizedBox(
                                        height: 30,
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 2,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
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
                                                SizedBox(width: 5),
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
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                          ],
                                        ),
                                      )
                                      : SizedBox(
                                        height: 30,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 2,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
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
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Obx(() {
                    if (homeControllerImp.itemList.isEmpty) {
                      return homeControllerImp.isLoadingGetItems.value
                          ? _HomeProductsSkeleton(
                            isTwo: homeControllerImp.isTwo.value,
                          )
                          : SizedBox();
                    }
                    return homeControllerImp.isTwo.value
                        ? buildTwoItem(
                          homeControllerImp: homeControllerImp,
                          shopController: shopController,
                          context: context,
                        )
                        : buildThreeItem(
                          context: context,
                          homeControllerImp: homeControllerImp,
                          shopController: shopController,
                        );
                  }),
                  SizedBox(height: 15.h), // Categories Section
                  Text(
                    "Sections".tr,
                    style: robotoRegular.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Theme.of(context).hoverColor,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Obx(() {
                    if (homeControllerImp.mainCategoresModel.isEmpty) {
                      return homeControllerImp.isLoadingGetCategories.value
                          ? _HomeCategoriesSkeleton()
                          : SizedBox();
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // عدد الأعمدة
                        crossAxisSpacing: 5.w, // المسافة الأفقية بين العناصر
                        mainAxisSpacing: 5.h, // المسافة الرأسية بين العناصر
                        childAspectRatio: 0.69,
                      ),
                      itemCount: homeControllerImp.mainCategoresModel.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            categoresControllerImp.mainCategoresId =
                                homeControllerImp.mainCategoresModel[index].id;
                            categoresControllerImp.titleMain =
                                isAr
                                    ? homeControllerImp
                                        .mainCategoresModel[index]
                                        .nameAr
                                    : isEng
                                    ? homeControllerImp
                                        .mainCategoresModel[index]
                                        .nameEng
                                    : homeControllerImp
                                        .mainCategoresModel[index]
                                        .nameAbree;
                            // await categoresControllerImp.getAllCategores(
                            //   homeControllerImp.mainCategoresModel[index].id,
                            // );
                            await categoresControllerImp
                                .getSupCategoresByMainCategoresId(
                                  homeControllerImp
                                      .mainCategoresModel[index]
                                      .id,
                                );
                          },
                          child: MainCategorys(
                            image: _safeImageUrl(
                              homeControllerImp
                                  .mainCategoresModel[index]
                                  .imageUrl
                                  .toString(),
                            ),
                            title:
                                isAr
                                    ? homeControllerImp
                                        .mainCategoresModel[index]
                                        .nameAr
                                    : isEng
                                    ? homeControllerImp
                                        .mainCategoresModel[index]
                                        .nameEng
                                    : homeControllerImp
                                        .mainCategoresModel[index]
                                        .nameAbree,
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDot({
    required int index,
    required int currentPage,
    required BuildContext context,
  }) {
    return AnimatedContainer(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      width: currentPage == index ? 34.w : 8,
      height: 8.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        color:
            currentPage == index
                ? Theme.of(context).primaryColor
                : const Color(0xffa9a9a9),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget buildThreeItem({
    required HomeControllerImp homeControllerImp,
    required ShopController shopController,
    required BuildContext context,
  }) {
    bool isAr =
        homeControllerImp.localizationController.locale.languageCode == 'ar';
    bool isEng =
        homeControllerImp.localizationController.locale.languageCode == 'en';
    return Obx(() {
      if (homeControllerImp.itemList.isEmpty) {
        return homeControllerImp.isLoadingGetItems.value
            ? _HomeProductsSkeleton(isTwo: false)
            : SizedBox();
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          mainAxisExtent: 161.h,
        ),
        itemCount: homeControllerImp.itemList.length,
        itemBuilder: (context, index) {
          return InkWell(
            radius: 7.r,
            onTap: () async {
              await Get.find<ProductControllerImp>().getCategoryById(
                itemId: homeControllerImp.itemList[index].id,
              );
            },
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
                    (homeControllerImp.itemList[index].discount > 0.0)
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
                              "${"discount".tr} ${homeControllerImp.itemList[index].discount.toString()}%",
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeOverSmall,
                              ),
                            ),
                          ),
                        )
                        : SizedBox(),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImageWidget(
                        height: 75.h,
                        image: _itemImage(homeControllerImp.itemList[index]),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _itemCategoryName(
                              homeControllerImp.itemList[index],
                              isAr,
                              isEng,
                            ),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "⭐ ${homeControllerImp.itemList[index].rate}",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hoverColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isAr == 'ar'
                          ? homeControllerImp.itemList[index].nameAr
                          : isEng == 'en'
                          ? homeControllerImp.itemList[index].nameEng
                          : homeControllerImp.itemList[index].nameAbree,
                      textAlign: TextAlign.center,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall.sp,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).hoverColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "₪ ${homeControllerImp.token == null
                          ? homeControllerImp.itemList[index].normailPrice
                          : homeControllerImp.isNormail
                          ? homeControllerImp.itemList[index].normailPrice
                          : homeControllerImp.itemList[index].wholesalePrice}",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).hoverColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          homeControllerImp.itemList[index].itemSizes.isNotEmpty
                              ? ""
                              : "${"left".tr} ${homeControllerImp.itemList[index].stock} ${"pieces".tr}",
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
        },
      );
    });
  }

  Widget buildTwoItem({
    required HomeControllerImp homeControllerImp,
    required ShopController shopController,
    required BuildContext context,
  }) {
    bool isAr =
        homeControllerImp.localizationController.locale.languageCode == 'ar';
    bool isEng =
        homeControllerImp.localizationController.locale.languageCode == 'en';
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 5.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.69,
          crossAxisSpacing: 5.w,
          mainAxisSpacing: 10.h,
          mainAxisExtent: 205.h,
        ),
        itemCount: homeControllerImp.itemList.length,
        itemBuilder: (context, index) {
          return InkWell(
            radius: 7.r,
            onTap: () async {
              await Get.find<ProductControllerImp>().getCategoryById(
                itemId: homeControllerImp.itemList[index].id,
              );
            },
            child: Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (homeControllerImp.itemList[index].discount > 0.0)
                        ? Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            width: isEng ? 75.w : 57.w,
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
                              "${"discount".tr} ${homeControllerImp.itemList[index].discount.toString()}%",
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                            ),
                          ),
                        )
                        : SizedBox(),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CustomImageWidget(
                        height: 115.h,
                        image: _itemImage(homeControllerImp.itemList[index]),
                        fit: BoxFit.fill,

                        // height: 65.h,
                        // width: 110.w,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            // isAr
                            //     ? homeControllerImp
                            //         .itemList[index]
                            //         .nameAr
                            //     : isEng
                            //     ? homeControllerImp
                            //         .itemList[index]
                            //         .nameEng
                            //     : homeControllerImp
                            //         .itemList[index]
                            //         .nameAbree,
                            _itemCategoryName(
                              homeControllerImp.itemList[index],
                              isAr,
                              isEng,
                            ),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "⭐ ${homeControllerImp.itemList[index].rate}",
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
                              ? homeControllerImp.itemList[index].nameAr
                              : isEng
                              ? homeControllerImp.itemList[index].nameEng
                              : homeControllerImp.itemList[index].nameAbree,
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
                      "₪ ${homeControllerImp.itemList[index].normailPrice}",
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
                          homeControllerImp.itemList[index].itemSizes.isNotEmpty
                              ? ""
                              : "${"left".tr} ${homeControllerImp.itemList[index].stock} ${"pieces".tr}",
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
        },
      ),
    );
  }

  String _itemImage(dynamic item) {
    final viewImages = item.viewImagesItems;
    if (viewImages.isNotEmpty) {
      final imageUrl = viewImages.first.imageUrl?.toString() ?? '';
      if (imageUrl.trim().isNotEmpty) return imageUrl;
    }

    final normalImages = item.normalImagesItems;
    if (normalImages.isNotEmpty) {
      final imageUrl = normalImages.first.imageUrl?.toString() ?? '';
      if (imageUrl.trim().isNotEmpty) return imageUrl;
    }

    return Images.logo;
  }

  String _itemCategoryName(dynamic item, bool isAr, bool isEng) {
    final supCategories = item.supCategory;
    if (supCategories.isNotEmpty) {
      final category = supCategories.first;
      final categoryName =
          isAr
              ? category.nameAr
              : isEng
              ? category.nameEng
              : category.nameAbree;
      if (categoryName.toString().trim().isNotEmpty) {
        return categoryName.toString();
      }
    }

    final itemName =
        isAr
            ? item.nameAr
            : isEng
            ? item.nameEng
            : item.nameAbree;
    return itemName.toString();
  }

  String _safeImageUrl(String imageUrl) {
    return imageUrl.trim().isEmpty ? Images.logo : imageUrl;
  }
}

class _HomeBannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
      child: _SkeletonBox(
        width: double.infinity,
        height: 120.h,
        borderRadius: 25.r,
      ),
    );
  }
}

class _HomeProductsSkeleton extends StatelessWidget {
  final bool isTwo;

  const _HomeProductsSkeleton({required this.isTwo});

  @override
  Widget build(BuildContext context) {
    final count = isTwo ? 4 : 6;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTwo ? 2 : 3,
        crossAxisSpacing: 5.w,
        mainAxisSpacing: 10.h,
        mainAxisExtent: isTwo ? 205.h : 161.h,
      ),
      itemBuilder: (context, index) {
        return Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(isTwo ? 10 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: double.infinity,
                  height: isTwo ? 110.h : 72.h,
                  borderRadius: 10.r,
                ),
                SizedBox(height: 10.h),
                _SkeletonBox(width: 70.w, height: 9.h, borderRadius: 8.r),
                SizedBox(height: 7.h),
                _SkeletonBox(width: double.infinity, height: 10.h),
                SizedBox(height: 7.h),
                _SkeletonBox(width: 45.w, height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeCategoriesSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.w,
        mainAxisSpacing: 5.h,
        childAspectRatio: 0.69,
      ),
      itemBuilder: (context, index) {
        return Column(
          children: [
            _SkeletonBox(width: double.infinity, height: 120.h),
            SizedBox(height: 8.h),
            _SkeletonBox(width: 100.w, height: 12.h),
          ],
        );
      },
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06);
    final highlightColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.16)
            : Colors.black.withOpacity(0.11);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.1, 0.5, 0.9],
              colors: [baseColor, highlightColor, baseColor],
              transform: _SlidingGradientTransform(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}
