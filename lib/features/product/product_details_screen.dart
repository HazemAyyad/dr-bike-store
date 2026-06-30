// ignore_for_file: must_be_immutable, deprecated_member_use, use_build_context_synchronously

import 'package:doctor_bike/features/product/widget/commints.dart';
import 'package:doctor_bike/features/product/widget/plus_and_mins.dart';
import 'package:doctor_bike/features/product/widget/view_image_and_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import '../../controller/product/product_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/theme_services.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/widget/button.dart';
import '../../core/widget/customTextField.widgets.dart';
import '../../core/widget/custom_image_widget.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../core/widget/dialog_login_and_register.dart';
import 'widget/image_view.dart';
import 'widget/items_similar.dart';
import 'widget/video_view.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({super.key});
  int? selectedIndexSize;
  int? selectedIndexColors;
  TextEditingController countController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    countController.text = '1';
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return GetBuilder<ProductControllerImp>(
      builder: (controllerScreen) {
        bool isAr =
            controllerScreen.localizationController.locale.languageCode == 'ar';
        bool isEng =
            controllerScreen.localizationController.locale.languageCode == 'en';
        final productImages = _productImages(controllerScreen.itemView);
        return WillPopScope(
          onWillPop: () async {
            controllerScreen.commints.clear();
            // Get.offAndToNamed(RouteHelper.homePage);
            return true;
          },
          child: Screenshot(
            controller: controllerScreen.screenshotController,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    // Get.offAllNamed(RouteHelper.homePage);
                    Get.back();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      controllerScreen.takeScreenshotAndShare(
                        isAr: isAr,
                        isEng: isEng,
                        selectedIndexSize: selectedIndexSize ?? 0,
                        selectedIndexColors: selectedIndexColors ?? 0,
                      );
                    },
                    icon: Icon(
                      Icons.ios_share_rounded,
                      size: 28.w,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.76,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Carousel Slider\
                              ViewImageAndVideo(
                                items:
                                    controllerScreen.itemView!.videoUrl == null
                                        ? productImages.map((image) {
                                          return Center(
                                            child: InkWell(
                                              onTap: () {
                                                Get.dialog(
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                        ),
                                                    child: Stack(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .topStart,
                                                      children: [
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: List.generate(
                                                              productImages
                                                                  .length,
                                                              (
                                                                index,
                                                              ) => Container(
                                                                margin:
                                                                    EdgeInsetsDirectional.symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          170.h,
                                                                    ),
                                                                child: InteractiveViewer(
                                                                  maxScale: 5,
                                                                  child: ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                    child: CustomImageWidget(
                                                                      image:
                                                                          productImages[index]
                                                                              .imageUrl
                                                                              .toString(),

                                                                      width:
                                                                          330.w,
                                                                      height:
                                                                          430.h,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            Get.back();
                                                          },
                                                          icon: Icon(
                                                            size: 30.w,
                                                            Icons.cancel,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ImageView(image: image),
                                            ),
                                          );
                                        }).toList()
                                        : productImages.map((image) {
                                              return Center(
                                                child: InkWell(
                                                  onTap: () {
                                                    Get.dialog(
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 5,
                                                            ),
                                                        child: Stack(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .topStart,
                                                          children: [
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: List.generate(
                                                                  productImages
                                                                      .length,
                                                                  (
                                                                    index,
                                                                  ) => Container(
                                                                    margin: EdgeInsetsDirectional.symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          170.h,
                                                                    ),
                                                                    child: InteractiveViewer(
                                                                      maxScale:
                                                                          5,
                                                                      child: CustomImageWidget(
                                                                        image:
                                                                            productImages[index].imageUrl.toString(),

                                                                        width:
                                                                            330.w,
                                                                        height:
                                                                            430.h,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              icon: Icon(
                                                                size: 30.w,
                                                                Icons.cancel,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: ImageView(
                                                    image: image,
                                                  ),
                                                ),
                                              );
                                            }).toList() +
                                            [
                                              Center(
                                                child: VideoView(
                                                  videoUrl:
                                                      controllerScreen
                                                          .itemView!
                                                          .videoUrl
                                                          .toString(),
                                                ),
                                              ),
                                            ],
                                controllerScreen: controllerScreen,
                              ),

                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      _itemCategoryName(
                                        controllerScreen.itemView!,
                                        isAr,
                                        isEng,
                                      ),
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    controllerScreen.itemView!.itemSizes.isEmpty
                                        ? "${"left".tr} ${controllerScreen.itemView!.stock} ${"pieces".tr}"
                                        : controllerScreen
                                                .itemView!
                                                .itemSizeColorsStock ==
                                            null
                                        ? ''
                                        : "${"left".tr} ${controllerScreen.itemView!.itemSizeColorsStock} ${"pieces".tr}",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color:
                                          ((controllerScreen
                                                          .itemView!
                                                          .itemSizeColorsStock ??
                                                      controllerScreen
                                                          .itemView!
                                                          .stock)) >
                                                  5
                                              ? Theme.of(context).hintColor
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      isAr
                                          ? controllerScreen.itemView!.nameAr
                                          : isEng
                                          ? controllerScreen.itemView!.nameEng
                                          : controllerScreen
                                              .itemView!
                                              .nameAbree,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraLarge,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).hoverColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    controllerScreen.itemView!.itemSizes.isEmpty
                                        ? "₪ ${controllerScreen.token == null
                                            ? controllerScreen.itemView!.normailPrice
                                            : controllerScreen.isNormail
                                            ? (controllerScreen.itemView!.normailPrice)
                                            : (controllerScreen.itemView!.wholesalePrice)}"
                                        : ((controllerScreen
                                                    .itemView!
                                                    .itemSizeColorsprice ==
                                                null) &&
                                            (selectedIndexColors == null))
                                        ? ''
                                        : "₪ ${controllerScreen.token == null
                                            ? (controllerScreen.itemView!.itemSizes[selectedIndexSize!].itemSizeColor[selectedIndexColors!].normailPrice)
                                            : controllerScreen.isNormail
                                            ? (controllerScreen.itemView!.itemSizes[selectedIndexSize!].itemSizeColor[selectedIndexColors!].normailPrice)
                                            : (controllerScreen.itemView!.itemSizes[selectedIndexSize!].itemSizeColor[selectedIndexColors!].wholesalePrice)}",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).hoverColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.h),
                              Container(
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: 3,
                                ),
                                height: 27.h,
                                width: 98.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: PlusAndMins(
                                  controllerScreen: controllerScreen,
                                  selectedIndexColors: selectedIndexColors,
                                  selectedIndexSize: selectedIndexSize,
                                  countController: countController,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                (controllerScreen
                                            .itemView!
                                            .itemSizes
                                            .isNotEmpty &&
                                        selectedIndexSize != null)
                                    ? (controllerScreen
                                        .itemView!
                                        .itemSizes[selectedIndexSize!]
                                        .description
                                        .toString())
                                    : (isAr
                                        ? controllerScreen
                                            .itemView!
                                            .descriptionAr
                                        : isEng
                                        ? controllerScreen
                                            .itemView!
                                            .descriptionEng
                                        : controllerScreen
                                            .itemView!
                                            .descriptionAbree),
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),

                              const SizedBox(height: 12),
                              DefaultButtom(
                                Child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Ask about the product".tr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Image.asset(
                                      Images.iconWhatsapp,
                                      width: 25.w,
                                      height: 25.h,
                                    ),
                                  ],
                                ),
                                OnTap: () {
                                  controllerScreen.openWhatsAppAsk(
                                    text:
                                        'productId:${controllerScreen.itemView!.id}\nproductName:${isAr
                                            ? controllerScreen.itemView!.nameAr
                                            : isEng
                                            ? controllerScreen.itemView!.nameEng
                                            : controllerScreen.itemView!.nameAbree}\nprice:${(controllerScreen.token == null
                                            ? controllerScreen.itemView!.normailPrice
                                            : controllerScreen.isNormail
                                            ? controllerScreen.itemView!.normailPrice
                                            : controllerScreen.itemView!.wholesalePrice)}\ndiscount:${controllerScreen.itemView!.discount}\ndescription:${isAr
                                            ? controllerScreen.itemView!.descriptionAr
                                            : isEng
                                            ? controllerScreen.itemView!.descriptionEng
                                            : controllerScreen.itemView!.descriptionAbree}',
                                  );
                                },
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                Height: 30.h,
                                radius: 10.r,
                                colorShadow: Colors.transparent,
                                Width: double.infinity,
                                PaddingHorizontal: 0,
                                PaddingVertical: 0,
                                colorBorder: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              controllerScreen
                                      .itemView!
                                      .normalImagesItems!
                                      .isNotEmpty
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Real pictures".tr,
                                        style: robotoBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraLarge,
                                          color: Theme.of(context).hoverColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(
                                            controllerScreen
                                                .itemView!
                                                .normalImagesItems!
                                                .length,
                                            (index) => InkWell(
                                              onTap: () {
                                                Get.dialog(
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                        ),
                                                    child: Stack(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .topStart,
                                                      children: [
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: List.generate(
                                                              controllerScreen
                                                                  .itemView!
                                                                  .normalImagesItems!
                                                                  .length,
                                                              (
                                                                index,
                                                              ) => Container(
                                                                margin:
                                                                    EdgeInsetsDirectional.symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          170.h,
                                                                    ),
                                                                child: InteractiveViewer(
                                                                  maxScale: 5,
                                                                  child: CustomImageWidget(
                                                                    image:
                                                                        controllerScreen
                                                                            .itemView!
                                                                            .normalImagesItems![index]
                                                                            .imageUrl
                                                                            .toString(),
                                                                    fit:
                                                                        BoxFit
                                                                            .fill,
                                                                    width:
                                                                        330.w,
                                                                    height:
                                                                        430.h,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            Get.back();
                                                          },
                                                          icon: Icon(
                                                            size: 30.w,
                                                            Icons.cancel,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ImageView(
                                                image:
                                                    controllerScreen
                                                        .itemView!
                                                        .normalImagesItems![index],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : SizedBox(),

                              const SizedBox(height: 16),

                              //  Dimensional pictures
                              controllerScreen.itemView!.images3DItems!.isEmpty
                                  ? SizedBox()
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Dimensional pictures".tr,
                                        style: robotoBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraLarge,
                                          color: Theme.of(context).hoverColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(
                                            controllerScreen
                                                .itemView!
                                                .images3DItems!
                                                .length,
                                            (index) => InkWell(
                                              onTap: () {
                                                Get.dialog(
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                        ),
                                                    child: Stack(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .topStart,
                                                      children: [
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: List.generate(
                                                              controllerScreen
                                                                  .itemView!
                                                                  .images3DItems!
                                                                  .length,
                                                              (
                                                                index,
                                                              ) => Container(
                                                                margin:
                                                                    EdgeInsetsDirectional.symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          170.h,
                                                                    ),
                                                                child: InteractiveViewer(
                                                                  maxScale: 5,
                                                                  child: CustomImageWidget(
                                                                    image:
                                                                        controllerScreen
                                                                            .itemView!
                                                                            .images3DItems![index]
                                                                            .imageUrl
                                                                            .toString(),

                                                                    width:
                                                                        330.w,
                                                                    height:
                                                                        430.h,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            Get.back();
                                                          },
                                                          icon: Icon(
                                                            size: 30.w,
                                                            Icons.cancel,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ImageView(
                                                image:
                                                    controllerScreen
                                                        .itemView!
                                                        .images3DItems![index],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                              //size
                              controllerScreen.itemView!.itemSizes.isEmpty
                                  ? SizedBox()
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 16),
                                      Text(
                                        "Size".tr,
                                        style: robotoBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraLarge,
                                          color: Theme.of(context).hoverColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: List.generate(
                                            controllerScreen
                                                .itemView!
                                                .itemSizes
                                                .length,
                                            (index) {
                                              controllerScreen
                                                  .itemView!
                                                  .isSize = true;
                                              bool isSelected =
                                                  selectedIndexSize == index;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    controllerScreen
                                                        .itemView!
                                                        .count = 0;
                                                    selectedIndexSize = index;
                                                    controllerScreen.update();
                                                    controllerScreen
                                                            .itemView!
                                                            .itemSizediscount =
                                                        controllerScreen
                                                            .itemView!
                                                            .itemSizes[index]
                                                            .discount;

                                                    controllerScreen
                                                            .itemView!
                                                            .itemSizeId =
                                                        controllerScreen
                                                            .itemView!
                                                            .itemSizes[selectedIndexSize!]
                                                            .id;
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isSelected
                                                              ? Theme.of(
                                                                context,
                                                              ).primaryColor
                                                              : Colors
                                                                  .transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      controllerScreen
                                                          .itemView!
                                                          .itemSizes[index]
                                                          .size,
                                                      style: TextStyle(
                                                        color:
                                                            isSelected
                                                                ? Colors.white
                                                                : Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              // colors
                              controllerScreen.itemView!.itemSizes.isEmpty
                                  ? SizedBox()
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      Text(
                                        "Color".tr,
                                        style: robotoBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraLarge,
                                          color: Theme.of(context).hoverColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: List.generate(
                                            selectedIndexColors == null
                                                ? controllerScreen
                                                    .itemView!
                                                    .itemSizes[0]
                                                    .itemSizeColor
                                                    .length
                                                : controllerScreen
                                                    .itemView!
                                                    .itemSizes[selectedIndexSize!]
                                                    .itemSizeColor
                                                    .length,
                                            (index) {
                                              bool isSelected =
                                                  selectedIndexColors == index;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (selectedIndexSize !=
                                                        null) {
                                                      controllerScreen
                                                              .itemView!
                                                              .count =
                                                          (controllerScreen
                                                                          .itemView!
                                                                          .itemSizes[selectedIndexSize!]
                                                                          .itemSizeColor[index]
                                                                          .stock ??
                                                                      0) >
                                                                  0
                                                              ? 1
                                                              : 0;
                                                      countController.text =
                                                          '1';
                                                      selectedIndexColors =
                                                          index;

                                                      controllerScreen
                                                              .itemView!
                                                              .itemSizeColorId =
                                                          controllerScreen
                                                              .itemView!
                                                              .itemSizes[selectedIndexSize!]
                                                              .itemSizeColor[index]
                                                              .id;

                                                      controllerScreen
                                                              .itemView!
                                                              .itemSizeColorsStock =
                                                          controllerScreen
                                                              .itemView!
                                                              .itemSizes[selectedIndexSize!]
                                                              .itemSizeColor[index]
                                                              .stock;
                                                      controllerScreen
                                                              .itemView!
                                                              .itemSizeColorsprice =
                                                          controllerScreen
                                                                      .token ==
                                                                  null
                                                              ? controllerScreen
                                                                  .itemView!
                                                                  .itemSizes[selectedIndexSize!]
                                                                  .itemSizeColor[index]
                                                                  .normailPrice
                                                              : (controllerScreen
                                                                      .isNormail
                                                                  ? controllerScreen
                                                                      .itemView!
                                                                      .itemSizes[selectedIndexSize!]
                                                                      .itemSizeColor[index]
                                                                      .normailPrice
                                                                  : controllerScreen
                                                                      .itemView!
                                                                      .itemSizes[selectedIndexSize!]
                                                                      .itemSizeColor[index]
                                                                      .wholesalePrice);

                                                      controllerScreen.update();
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isSelected
                                                              ? Theme.of(
                                                                context,
                                                              ).primaryColor
                                                              : Colors
                                                                  .transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      isAr
                                                          ? (selectedIndexSize ==
                                                                      null
                                                                  ? controllerScreen
                                                                      .itemView!
                                                                      .itemSizes[0]
                                                                      .itemSizeColor[index]
                                                                      .colorAr
                                                                  : controllerScreen
                                                                      .itemView!
                                                                      .itemSizes[selectedIndexSize!]
                                                                      .itemSizeColor[index]
                                                                      .colorAr)
                                                              .toString()
                                                          : isEng
                                                          ? (selectedIndexSize ==
                                                                      0
                                                                  ? controllerScreen
                                                                      .itemView!
                                                                      .itemSizes[0]
                                                                      .itemSizeColor[index]
                                                                      .colorEn
                                                                  : controllerScreen
                                                                      .itemView!
                                                                      .itemSizes[selectedIndexSize ??
                                                                          0]
                                                                      .itemSizeColor[index]
                                                                      .colorEn)
                                                              .toString()
                                                          : (selectedIndexSize ==
                                                                      0
                                                                  ? controllerScreen
                                                                      .itemView!
                                                                      .itemSizes[0]
                                                                      .itemSizeColor[index]
                                                                      .colorAbbr
                                                                  : controllerScreen
                                                                      .itemView!
                                                                      .itemSizes[selectedIndexSize!]
                                                                      .itemSizeColor[index]
                                                                      .colorAbbr)
                                                              .toString(),
                                                      style: TextStyle(
                                                        color:
                                                            isSelected
                                                                ? Colors.white
                                                                : Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                              controllerScreen.itemView!.itemSizes.isEmpty
                                  ? SizedBox()
                                  : const SizedBox(height: 16),
                              //commints
                              controllerScreen.commints.isEmpty
                                  ? SizedBox(height: 0, width: 30)
                                  : Container(
                                    padding: EdgeInsetsDirectional.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          ThemeServices().theme ==
                                                  ThemeMode.light
                                              ? Colors.grey.shade300
                                              : Color.fromARGB(255, 49, 49, 49),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        children: [
                                          Column(
                                            children:
                                                controllerScreen.showMore.value
                                                    ? showMoreCommints(
                                                      commints:
                                                          controllerScreen
                                                              .commints,
                                                    )
                                                    : showLessCommints(
                                                      commints:
                                                          controllerScreen
                                                              .commints,
                                                    ),
                                          ),
                                          controllerScreen.commints.length > 5
                                              ? Padding(
                                                padding: const EdgeInsets.all(
                                                  10.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    controllerScreen
                                                            .showMore
                                                            .value =
                                                        !controllerScreen
                                                            .showMore
                                                            .value;
                                                  },
                                                  child: Text(
                                                    controllerScreen
                                                            .showMore
                                                            .value
                                                        ? "less".tr
                                                        : "More".tr,
                                                    style: robotoBlack.copyWith(
                                                      fontSize:
                                                          Dimensions
                                                              .fontSizeSmall,
                                                      color:
                                                          Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                              const SizedBox(height: 5),
                              CustomTextFieldChat(
                                controller: controllerScreen.controller,
                                onPress: () async {
                                  if (await AppUsageService.getToken() !=
                                      null) {
                                    if (controllerScreen.controller.text !=
                                        '') {
                                      controllerScreen.addCommint(
                                        comment:
                                            controllerScreen.controller.text,
                                        itemId: controllerScreen.itemView!.id,
                                        rate: 0,
                                        itemName:
                                            isAr
                                                ? controllerScreen
                                                    .itemView!
                                                    .nameAr
                                                : isEng
                                                ? controllerScreen
                                                    .itemView!
                                                    .nameEng
                                                : controllerScreen
                                                    .itemView!
                                                    .nameAbree,
                                      );

                                      controllerScreen.update();
                                    }
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
                              const SizedBox(height: 16),
                              controllerScreen.item2.isEmpty
                                  ? SizedBox()
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Similar products".tr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      itemsSimilar(
                                        productControllerImp: controllerScreen,
                                        context: context,
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          DefaultButtom(
                            colorShadow: Colors.transparent,
                            Child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Add to cart".tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: const Color(0xffffffff),
                                  ),
                                ),
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 20.w,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            Height: 30.h,
                            radius: 7.r,
                            Width: double.infinity,
                            PaddingHorizontal: 0,
                            colorBorder: Colors.transparent,
                            color:
                                !ThemeServices().loadThemeFromBox()
                                    ? Theme.of(context).hoverColor
                                    : Theme.of(context).primaryColor,
                            PaddingVertical: 5.h,
                            OnTap: () {
                              if (((controllerScreen
                                          .itemView!
                                          .itemSizeColorsStock ??
                                      controllerScreen.itemView!.stock)) ==
                                  0) {
                                showCustomSnackBar(
                                  "This product is currently unavailable for purchase."
                                      .tr,
                                  isError: true,
                                );
                              } else if (controllerScreen.itemView!.stock > 0 &&
                                  controllerScreen
                                      .itemView!
                                      .itemSizes
                                      .isEmpty) {
                                // widget.item.count = 1;
                                controllerScreen.shopController.addItem(
                                  controllerScreen.itemView!,
                                );
                              } else {
                                if (controllerScreen
                                    .itemView!
                                    .itemSizes
                                    .isNotEmpty) {
                                  if (controllerScreen.itemView!.itemSizeId ==
                                      null) {
                                    showCustomSnackBar(
                                      "The product contains more than one size in different colors."
                                          .tr,
                                      isError: true,
                                    );
                                  } else if (controllerScreen
                                          .itemView!
                                          .itemSizeColorId ==
                                      null) {
                                    showCustomSnackBar(
                                      'Select the desired color'.tr,
                                      isError: true,
                                    );
                                  }

                                  if (controllerScreen.itemView!.itemSizeId !=
                                          null &&
                                      controllerScreen
                                              .itemView!
                                              .itemSizeColorId !=
                                          null) {
                                    controllerScreen.itemView!.isSize = true;
                                    controllerScreen
                                        .itemView!
                                        .itemSizeColorSelect = isAr
                                            ? controllerScreen
                                                .itemView!
                                                .itemSizes[selectedIndexSize!]
                                                .itemSizeColor[selectedIndexColors!]
                                                .colorAr
                                            : isEng
                                            ? controllerScreen
                                                .itemView!
                                                .itemSizes[selectedIndexSize!]
                                                .itemSizeColor[selectedIndexColors!]
                                                .colorEn
                                            : controllerScreen
                                                .itemView!
                                                .itemSizes[selectedIndexSize!]
                                                .itemSizeColor[selectedIndexColors!]
                                                .colorAbbr;

                                    controllerScreen.itemView!.itemSizeSelect =
                                        controllerScreen
                                            .itemView!
                                            .itemSizes[selectedIndexSize!]
                                            .size;

                                    controllerScreen.shopController.addItem(
                                      controllerScreen.itemView!,
                                    );
                                    countController.text = '1';
                                    controllerScreen.update();
                                  }

                                  selectedIndexColors = 0;
                                  selectedIndexSize = 0;
                                }
                              }
                            },
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
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

  List<NormalImageItem> _productImages(dynamic item) {
    if (item == null) return [];

    final viewImages = item.viewImagesItems;
    if (viewImages.isNotEmpty) {
      return List<NormalImageItem>.from(viewImages);
    }

    final normalImages = item.normalImagesItems;
    if (normalImages.isNotEmpty) {
      return List<NormalImageItem>.from(normalImages);
    }

    return [NormalImageItem(id: 0, imageUrl: Images.logo, itemId: 0)];
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
}
