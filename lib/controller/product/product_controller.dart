import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/classes/store_view_state.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/commint_model.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/product_media_model.dart';
import '../../repository/categories/categories_repository.dart';
import '../../repository/shop/shop_repository.dart';
import '../LocalizationController.dart';
import '../shop/shop_controller.dart';

typedef ProductDetailLoader = Future<Response> Function(int productId);
typedef ProductConnectivityCheck = Future<bool> Function();
typedef ProductCheckoutStarter = bool Function(Item item);

abstract class ProductController extends GetxController {}

class ProductIdentityState {
  const ProductIdentityState({this.productId, this.listingId});

  final int? productId;
  final int? listingId;

  bool get hasProduct => productId != null && productId! > 0;
  bool get hasListing => listingId != null && listingId! > 0;
}

class ProductQuantityState {
  const ProductQuantityState({
    this.value = 1,
    this.minimum = 1,
    this.maximum = 0,
  });

  final int value;
  final int minimum;
  final int maximum;

  bool get canIncrement => value < maximum;
  bool get canDecrement => value > minimum;
}

class ProductOptionState {
  const ProductOptionState({this.selectedSizeIndex, this.selectedColorIndex});

  final int? selectedSizeIndex;
  final int? selectedColorIndex;
}

class ProductControllerImp extends ProductController {
  ProductControllerImp({
    required this.categoriesRepository,
    ProductDetailLoader? detailLoader,
    ProductConnectivityCheck? connectivityCheck,
    ShopController? shopController,
    ProductCheckoutStarter? checkoutStarter,
  }) : _detailLoader = detailLoader,
       _connectivityCheck =
           connectivityCheck ??
           (() async => await CheckInternet.checkInternet()),
       _injectedShopController = shopController,
       _checkoutStarter = checkoutStarter;

  final CategoriesRepository categoriesRepository;
  final ProductDetailLoader? _detailLoader;
  final ProductConnectivityCheck _connectivityCheck;
  final ShopController? _injectedShopController;
  final ProductCheckoutStarter? _checkoutStarter;

  StoreViewState<Item> productState = const StoreInitial<Item>();
  StoreViewState<List<ProductMedia>> mediaState =
      const StoreInitial<List<ProductMedia>>();
  StoreViewState<List<Review>> reviewsState =
      const StoreInitial<List<Review>>();
  StoreViewState<List<Item>> similarItemsState =
      const StoreInitial<List<Item>>();

  ProductIdentityState identity = const ProductIdentityState();
  ProductQuantityState quantity = const ProductQuantityState();
  ProductOptionState options = const ProductOptionState();
  ProductMedia? selectedMedia;
  int selectedMediaIndex = 0;
  int selectedImageIndex = 0;
  Item? itemView;
  final TextEditingController reviewController = TextEditingController();

  List<ProductMedia> get media => itemView?.storefrontMedia ?? const [];
  List<ProductMedia> get imageMedia =>
      media.where((item) => item.isImage).toList(growable: false);
  bool get hasOptions => itemView?.itemSizes.isNotEmpty == true;
  LocalizationController get localizationController =>
      Get.find<LocalizationController>();
  bool get canPurchase {
    final item = itemView;
    return item != null &&
        identity.hasListing &&
        item.available &&
        item.purchasable &&
        quantity.maximum > 0 &&
        quantity.value >= quantity.minimum &&
        quantity.value <= quantity.maximum &&
        _hasValidOptionSelection(item);
  }

  ShopController get shopController {
    if (_injectedShopController != null) return _injectedShopController;
    if (Get.isRegistered<ShopController>()) return Get.find<ShopController>();
    return Get.put(
      ShopController(shopRepository: ShopRepository(apiClient: Get.find())),
    );
  }

  Future<void> loadProductDetail({
    required int productId,
    bool navigate = false,
  }) async {
    if (productId <= 0) {
      _setDetailError('productId must be a positive integer', 'invalid_id');
      return;
    }

    identity = ProductIdentityState(productId: productId);
    productState = const StoreLoading<Item>();
    mediaState = const StoreLoading<List<ProductMedia>>();
    update();

    if (!await _connectivityCheck()) {
      productState = const StoreOffline<Item>(message: 'storeOffline');
      mediaState = const StoreOffline<List<ProductMedia>>(
        message: 'storeOffline',
      );
      update();
      return;
    }

    try {
      final response =
          _detailLoader == null
              ? await categoriesRepository.getCategoriesById(
                categoryId: productId,
              )
              : await _detailLoader(productId);
      if (response.statusCode == 404) {
        _setUnavailable();
        return;
      }
      if (response.statusCode == 1 || response.statusCode == 0) {
        productState = const StoreOffline<Item>(message: 'storeOffline');
        mediaState = const StoreOffline<List<ProductMedia>>(
          message: 'storeOffline',
        );
        update();
        return;
      }
      if (response.statusCode != 200 || response.body is! Map) {
        _setDetailError('Unable to load product', 'http_error');
        return;
      }

      final body = Map<String, dynamic>.from(response.body as Map);
      final parsed = Item.fromJson(body);
      if (parsed.productId != productId || parsed.listingId == null) {
        throw const FormatException('product detail identity mismatch');
      }

      itemView = parsed;
      identity = ProductIdentityState(
        productId: parsed.productId,
        listingId: parsed.listingId,
      );
      selectedMediaIndex = parsed.storefrontMedia.indexWhere(
        (item) => item.isMain,
      );
      selectedMediaIndex = selectedMediaIndex < 0 ? 0 : selectedMediaIndex;
      selectedMedia = parsed.storefrontMedia[selectedMediaIndex];
      selectedImageIndex = imageMedia.indexOf(selectedMedia!);
      if (selectedImageIndex < 0) selectedImageIndex = 0;
      quantity = ProductQuantityState(maximum: _maximumQuantity(parsed));
      options = const ProductOptionState();
      productState = StoreContent<Item>(parsed);
      mediaState = StoreContent<List<ProductMedia>>(parsed.storefrontMedia);
      reviewsState = const StoreInitial<List<Review>>();
      similarItemsState = const StoreInitial<List<Item>>();
      update();

      if (navigate) Get.toNamed(RouteHelper.productDetailsScreen);
      await Future.wait(<Future<void>>[
        loadReviews(parsed.productId),
        loadSimilarItems(parsed),
      ]);
    } on FormatException catch (error) {
      _setDetailError(error.message, 'malformed_response');
    } catch (_) {
      _setDetailError('Unable to load product', 'unexpected_error');
    }
  }

  Future<void> getCategoryById({required int itemId}) =>
      loadProductDetail(productId: itemId, navigate: true);

  Future<void> getCategoryById2({required int itemId}) =>
      loadProductDetail(productId: itemId, navigate: false);

  Future<void> loadReviews(int productId) async {
    reviewsState = const StoreLoading<List<Review>>();
    update();
    try {
      final response = await categoriesRepository.getCommintByCategoryId(
        categoryId: productId,
      );
      if (response.statusCode == 1 || response.statusCode == 0) {
        reviewsState = const StoreOffline<List<Review>>(
          message: 'storeOffline',
        );
      } else if (response.statusCode != 200 || response.body is! Map) {
        reviewsState = const StoreError<List<Review>>(
          message: 'storeGenericError',
        );
      } else {
        final rows = (response.body as Map)['rows'];
        if (rows is! List) throw const FormatException('reviews.rows');
        final reviews = rows
            .whereType<Map>()
            .map((row) => Review.fromJson(Map<String, dynamic>.from(row)))
            .where((review) => review.isShow)
            .toList(growable: false);
        reviewsState =
            reviews.isEmpty
                ? const StoreEmpty<List<Review>>(message: 'storeNoReviews')
                : StoreContent<List<Review>>(reviews);
      }
    } catch (_) {
      reviewsState = const StoreError<List<Review>>(
        message: 'storeGenericError',
      );
    }
    update();
  }

  Future<void> loadSimilarItems(Item item) async {
    if (item.supCategory.isEmpty) {
      similarItemsState = const StoreEmpty<List<Item>>(
        message: 'storeNoSimilarProducts',
      );
      update();
      return;
    }
    similarItemsState = const StoreLoading<List<Item>>();
    update();
    try {
      final response = await categoriesRepository.getCategoriesBySupId(
        supId: item.supCategory.first.id,
      );
      if (response.statusCode != 200 || response.body is! Map) {
        similarItemsState = const StoreError<List<Item>>(
          message: 'storeGenericError',
        );
      } else {
        final parsed = ItemsResponse.fromJson(
          Map<String, dynamic>.from(response.body as Map),
        );
        final items = parsed.rows
            .where((candidate) => candidate.productId != item.productId)
            .toList(growable: false);
        similarItemsState =
            items.isEmpty
                ? const StoreEmpty<List<Item>>(
                  message: 'storeNoSimilarProducts',
                )
                : StoreContent<List<Item>>(items);
      }
    } catch (_) {
      similarItemsState = const StoreError<List<Item>>(
        message: 'storeGenericError',
      );
    }
    update();
  }

  void selectMedia(int index) {
    if (index < 0 || index >= media.length) return;
    selectedMediaIndex = index;
    selectedMedia = media[index];
    if (selectedMedia!.isImage) {
      final imageIndex = imageMedia.indexOf(selectedMedia!);
      if (imageIndex >= 0) selectedImageIndex = imageIndex;
    }
    update();
  }

  void selectImage(int index) {
    if (index < 0 || index >= imageMedia.length) return;
    selectedImageIndex = index;
    selectMedia(media.indexOf(imageMedia[index]));
  }

  void setQuantity(int value) {
    final bounded = value.clamp(quantity.minimum, quantity.maximum);
    quantity = ProductQuantityState(
      value: bounded,
      minimum: quantity.minimum,
      maximum: quantity.maximum,
    );
    if (itemView != null) itemView!.count = bounded;
    update();
  }

  void incrementQuantity() {
    if (quantity.canIncrement) setQuantity(quantity.value + 1);
  }

  void decrementQuantity() {
    if (quantity.canDecrement) setQuantity(quantity.value - 1);
  }

  void selectSize(int index) {
    final item = itemView;
    if (item == null || index < 0 || index >= item.itemSizes.length) return;
    options = ProductOptionState(selectedSizeIndex: index);
    item.itemSizeId = item.itemSizes[index].id;
    item.isSize = true;
    update();
  }

  void selectColor(int index) {
    final item = itemView;
    final sizeIndex = options.selectedSizeIndex;
    if (item == null || sizeIndex == null) return;
    final colors = item.itemSizes[sizeIndex].itemSizeColor;
    if (index < 0 || index >= colors.length) return;
    final color = colors[index];
    options = ProductOptionState(
      selectedSizeIndex: sizeIndex,
      selectedColorIndex: index,
    );
    item.itemSizeColorId = color.id;
    item.itemSizeColorsStock = color.stock;
    item.itemSizeColorsprice = color.normailPrice;
    item.itemSizediscount = color.discount;
    quantity = ProductQuantityState(maximum: color.stock ?? 0);
    update();
  }

  bool addToCart() {
    final item = itemView;
    if (item == null || !canPurchase) return false;
    item.count = quantity.value;
    shopController.addItem(item);
    return true;
  }

  bool buyNow() {
    final item = itemView;
    if (item == null || !canPurchase) return false;
    item.count = quantity.value;
    return (_checkoutStarter ?? shopController.startBuyNowCheckout)(item);
  }

  void _setUnavailable() {
    itemView = null;
    identity = ProductIdentityState(productId: identity.productId);
    productState = const StoreEmpty<Item>(message: 'storeProductUnavailable');
    mediaState = const StoreEmpty<List<ProductMedia>>(
      message: 'storeMediaUnavailable',
    );
    update();
  }

  void _setDetailError(String message, String code) {
    itemView = null;
    productState = StoreError<Item>(message: message, code: code);
    mediaState = StoreError<List<ProductMedia>>(message: message, code: code);
    update();
  }

  int _maximumQuantity(Item item) {
    if (!item.available || !item.purchasable || item.stock <= 0) return 0;
    return item.stock;
  }

  bool _hasValidOptionSelection(Item item) {
    if (item.itemSizes.isEmpty) return true;
    final sizeIndex = options.selectedSizeIndex;
    if (sizeIndex == null || sizeIndex >= item.itemSizes.length) return false;
    final colors = item.itemSizes[sizeIndex].itemSizeColor;
    return colors.isEmpty || options.selectedColorIndex != null;
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
