import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/product/product_controller.dart';
import '../../../controller/shop/shop_controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/images.dart';
import '../../../core/constants/styles.dart';
import '../../../core/model/get_all_item_model.dart';
import '../../../core/widget/custom_image_widget.dart';
import '../../../core/widget/custom_snackbar.dart';
import 'message_delete.dart';

class BuildThreeItem extends StatefulWidget {
  const BuildThreeItem({super.key, required this.item});
  final Item item;
  @override
  State<BuildThreeItem> createState() => _BuildThreeItemState();
}

class _BuildThreeItemState extends State<BuildThreeItem> {
  TextEditingController countController = TextEditingController();
  @override
  void initState() {
    countController.text = widget.item.count.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(
      builder: (controller) {
        bool isAr =
            controller.localizationController.locale.languageCode == 'ar';
        bool isEng =
            controller.localizationController.locale.languageCode == 'en';
        return Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    InkWell(
                      radius: 7.r,
                      onTap: () async {
                        await Get.find<ProductControllerImp>().getCategoryById(
                          itemId: widget.item.id,
                        );
                      },
                      child: CustomImageWidget(
                        image: _itemImage(widget.item),
                        height: 57.h,
                        width: 80.w,
                      ),
                    ),

                    Column(
                      children: [
                        Text(
                          isAr
                              ? widget.item.nameAr
                              : isEng
                              ? widget.item.nameEng
                              : widget.item.nameAbree,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hoverColor,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.item.itemSizeId == null
                              ? (widget.item.itemSizes.isEmpty
                                  ? "${controller.token == null
                                      ? widget.item.normailPrice
                                      : controller.isNormail
                                      ? widget.item.normailPrice
                                      : widget.item.wholesalePrice}₪"
                                  : '')
                              : "${widget.item.itemSizeColorsprice}₪",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hoverColor,
                          ),
                        ),
                      ],
                    ),

                    widget.item.itemSizes.isNotEmpty
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${"Size".tr}: ${widget.item.itemSizeSelect}',

                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${"Color".tr}: ${widget.item.itemSizeColorSelect}',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        )
                        : SizedBox(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 80.w,
                          child: Center(
                            child: Text(
                              widget.item.itemSizeColorsStock == null
                                  ? (widget.item.itemSizes.isEmpty
                                      ? "${"left".tr} ${widget.item.stock} ${"pieces".tr}"
                                      : '')
                                  : "${"left".tr} ${widget.item.itemSizeColorsStock} ${"pieces".tr}",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: const Color(0xff8e8e93),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          height: 27.h,
                          width: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 1.w),
                              GestureDetector(
                                onTap: () {
                                  int maxStock =
                                      widget.item.itemSizeColorsStock ??
                                      widget.item.stock;
                                  if (widget.item.count < maxStock) {
                                    setState(() {
                                      widget.item.count++;
                                      countController.text =
                                          widget.item.count.toString();
                                    });
                                    controller.saveCart();
                                    controller.update();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.r),
                                  ),
                                  margin: const EdgeInsets.all(2),
                                  child: Icon(Icons.add, size: 22.w),
                                ),
                              ),
                              SizedBox(
                                width: 34.w,
                                child: TextFormField(
                                  controller: countController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) {
                                    int? newCount = int.tryParse(value);
                                    if (newCount != null && newCount > 0) {
                                      int maxStock =
                                          widget.item.itemSizeColorsStock ??
                                          widget.item.stock;
                                      if (newCount <= maxStock) {
                                        setState(() {
                                          widget.item.count = newCount;
                                        });

                                        controller.saveCart();
                                        controller.update();
                                      } else {
                                        countController.text =
                                            widget.item.count.toString();
                                      }
                                    }
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.item.count > 1) {
                                    setState(() {
                                      widget.item.count--;
                                      countController.text =
                                          widget.item.count.toString();
                                    });
                                    controller.saveCart();
                                    controller.update();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.r),
                                  ),
                                  margin: const EdgeInsets.all(2),
                                  child: Icon(Icons.remove, size: 22.w),
                                ),
                              ),
                              SizedBox(width: 1.w),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: GestureDetector(
                onTap: () {
                  showLogoutDialog(
                    context,
                    onPressed: () async {
                      for (int i = 0; i < controller.items.length; i++) {
                        if (controller.items[i].id == widget.item.id) {
                          controller.items.remove(controller.items[i]);
                          showCustomSnackBar(
                            "The product has been removed.".tr,
                            isError: false,
                          );
                        }
                      }
                      controller.saveCart();
                      controller.update();
                      Get.back();
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  margin: const EdgeInsets.all(2),
                  child: Icon(Icons.delete, color: Colors.red, size: 20.w),
                ),
              ),
            ),
          ],
        );
      },
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
}
