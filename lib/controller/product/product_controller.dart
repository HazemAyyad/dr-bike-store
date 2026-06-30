// ignore_for_file: public_member_api_docs, sort_constructors_first, deprecated_member_use, empty_catches
import 'dart:io';

import 'package:doctor_bike/core/helper/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_kit/overlay_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/classes/status_request.dart';
import '../../core/constants/app_constants.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/model/commint_model.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../repository/categories/categories_repository.dart';
import '../../repository/shop/shop_repository.dart';
import '../LocalizationController.dart';
import '../account/account_controller.dart';
import '../shop/shop_controller.dart';

abstract class ProductController extends GetxController {}

class ProductControllerImp extends ProductController {
  final key = GlobalKey(debugLabel: UniqueKey().toString());

  final CategoriesRepository categoriesRepository;
  late VideoPlayerController controllerVideo;
  Rx<bool> showMore = false.obs;
  bool isNormail = true;
  String? token;
  // int currentPage = 0;  '
  int currentPage = 0;
  late StatusRequest statusRequest;
  var isLoading = false.obs;

  var isLoadingCommints = false.obs;
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );

  Rx<int> rateProduct = 0.obs;
  late TextEditingController controller;
  ScreenshotController screenshotController = ScreenshotController();
  var commints = <Review>[].obs;
  Item? itemView;
  ProductControllerImp({required this.categoriesRepository});
  ItemsResponse? item;
  var item2 = <Item>[].obs;
  bool isVideo = false;
  bool videoPlayer = false;
  Color videoPlayerColors = Colors.white;

  AccountControllerImp? get accountController {
    if (Get.isRegistered<AccountControllerImp>()) {
      return Get.find<AccountControllerImp>();
    }
    return null;
  }

  ShopController get shopController {
    if (Get.isRegistered<ShopController>()) {
      return Get.find<ShopController>();
    }
    return Get.put(
      ShopController(shopRepository: ShopRepository(apiClient: Get.find())),
    );
  }

  checkVideoUrl(String videoUrl, dynamic widget, {required Item item}) async {
    // await getCategoryBySupId(item.supCategory);
    try {
      final response = await http.head(
        Uri.parse(AppConstants.appBaseUrl + videoUrl),
        // Uri.parse("https://youtu.be/horyqWfZnI4?si=oV7AjwZaoHvQJug1"),
      );
      // تعتبر ناجحة إذا كان الرد حالة الرمز 200
      isVideo = response.statusCode == 200;
      if (isVideo) {
        // إذا كانت الحالة 200، فهذا يعني أن الرابط صالح
        controllerVideo = VideoPlayerController.networkUrl(
            Uri.parse(
              AppConstants.appBaseUrl + widget.item.videoUrl.toString(),
            ),
          )
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            update();
          });
        update();
      } else {
        // إذا لم تكن الحالة 200، فهذا يعني أن الرابط غير صالح
        videoPlayer = false;
        videoPlayerColors = Colors.red;
      }
    } catch (e) {
      // أي خطأ يتم استثناءه
      isVideo = false;
    }
  }

  Future<void> takeScreenshotAndShare({
    required int selectedIndexSize,
    required int selectedIndexColors,
    required bool isAr,
    required bool isEng,
  }) async {
    try {
      // Capture the widget as bytes
      final imageBytes = await screenshotController.capture();
      if (imageBytes == null) throw Exception("Screenshot failed");

      // Save the image locally
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/screenshot.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Share the image + sentence

      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            'productName:${isAr
                ? itemView!.nameAr
                : isEng
                ? itemView!.nameEng
                : itemView!.nameAbree}\nprice:${itemView!.itemSizeId == null ? itemView!.normailPrice : (itemView!.itemSizes[selectedIndexSize].itemSizeColor[selectedIndexColors].normailPrice).toString()}\ndiscount:${itemView!.discount}\ndescription:${itemView!.itemSizeId == null ? (isAr
                    ? itemView!.descriptionAr
                    : isEng
                    ? itemView!.descriptionEng
                    : itemView!.descriptionAbree) : (itemView!.itemSizes[selectedIndexSize].description)}\nstock: ${itemView!.itemSizeColorsStock ?? itemView!.stock}',
      );
    } catch (e) {}
  }

  getCategoryBySupId({
    required Item item,
    required List<SupCategory> supId,
  }) async {
    loadingIsNormail();
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        item2.value = [];
        statusRequest = StatusRequest.loading;
        for (int i = 0; i < supId.length; i++) {
          var response = await categoriesRepository.getCategoriesBySupId(
            supId: supId[i].id,
          );
          if (response.statusCode == 200) {
            List<Item> list;
            list = List<Item>.from(
              response.body["rows"].map((x) => Item.fromJson(x)),
            );
            for (var ite in list) {
              if (item.id != ite.id) {
                item2.add(ite);
              }

              //
            }
            update();
            // item = ItemsResponse.fromJson(response.body);
            // item2.first = item!;
          }
        }
        update();
        OverlayLoadingProgress.stop();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
        OverlayLoadingProgress.stop();
      }
      update();
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    update();
  }

  getCategoryById({required int itemId}) async {
    loadingIsNormail();
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        var response = await categoriesRepository.getCategoriesById(
          categoryId: itemId,
        );
        if (response.statusCode == 200) {
          itemView = Item.fromJson(response.body);
          // item2.first = item!;
        }
        update();
        goToPageItem();
        OverlayLoadingProgress.stop();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
        OverlayLoadingProgress.stop();
      }
      update();
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    update();
  }

  getCategoryById2({required int itemId}) async {
    loadingIsNormail();
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        var response = await categoriesRepository.getCategoriesById(
          categoryId: itemId,
        );
        if (response.statusCode == 200) {
          itemView = Item.fromJson(response.body);
          // item2.first = item!;
        }
        update();
        goToPageItem();
        OverlayLoadingProgress.stop();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
        OverlayLoadingProgress.stop();
      }
      update();
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    update();
  }

  addCommint({
    required int itemId,
    required int rate,
    required String itemName,
    required String comment,
  }) async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(now);
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;

        var response = await categoriesRepository.postCommint(
          dateAdd: formattedDate,
          itemName: itemName,
          itemId: itemId,
          rate: rate,
          comment: comment,
        );

        if (response.statusCode == 200) {
          // item = ItemsResponse.fromJson(response.body);
          // // item2.first = item!;
          controller.clear();
          rateProduct = 0.obs;
        }

        await getAllCommintByCategoryId(itemId);

        OverlayLoadingProgress.stop();
        update();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  getAllCommintByCategoryId(int categoryId) async {
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;

        var response = await categoriesRepository.getCommintByCategoryId(
          categoryId: categoryId,
        );

        if (response.statusCode == 200) {
          commints.value = List<Review>.from(
            response.body["rows"].map((x) => Review.fromJson(x)),
          );
          // commints = ReviewResponse.fromJson(response.body);
          // item2.first = item!;
          update();
        }
        update();
        OverlayLoadingProgress.stop();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    update();
  }

  goToPageItem() {
    loadingIsNormail();
    accountController?.getConactUs();
    getCategoryBySupId(item: itemView!, supId: itemView!.supCategory);
    getAllCommintByCategoryId(itemView!.id);
    Get.toNamed(RouteHelper.productDetailsScreen);
  }

  goToPageItemsSimilar() {
    accountController?.getConactUs();
    getCategoryBySupId(item: itemView!, supId: itemView!.supCategory);
    getAllCommintByCategoryId(itemView!.id);
    Get.offNamed(RouteHelper.productDetailsScreen);
  }

  openWhatsAppAsk({required String text}) {
    final controller = accountController;
    if (controller == null) {
      showCustomSnackBar('An error occurred. Please try again.'.tr);
      return;
    }
    controller.openWhatsAppAsk(text: text);
  }

  loadingIsNormail() async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    update();
  }

  loadingToken() async {
    token = await AppUsageService.getToken();
    update();
  }

  @override
  void onInit() {
    currentPage = 0;
    loadingToken();
    loadingIsNormail();
    controller = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
