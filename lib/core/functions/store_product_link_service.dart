import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../../controller/product/product_controller.dart';
import '../constants/app_constants.dart';
import '../helper/route_helper.dart';

typedef StoreProductLinkOpener = Future<void> Function(int productId);

class StoreProductLinkService extends GetxService {
  StoreProductLinkService({
    Stream<Uri>? linkStream,
    Future<Uri?> Function()? initialLink,
    StoreProductLinkOpener? openProduct,
  }) : _injectedLinkStream = linkStream,
       _injectedInitialLink = initialLink,
       _injectedOpenProduct = openProduct;

  final Stream<Uri>? _injectedLinkStream;
  final Future<Uri?> Function()? _injectedInitialLink;
  final StoreProductLinkOpener? _injectedOpenProduct;

  StreamSubscription<Uri>? _subscription;
  int? _pendingProductId;
  bool _navigationReady = false;
  bool _initialized = false;
  String? _lastAcceptedLink;
  DateTime? _lastAcceptedAt;

  int? get pendingProductId => _pendingProductId;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final needsPlugin =
        _injectedLinkStream == null || _injectedInitialLink == null;
    final appLinks = needsPlugin ? AppLinks() : null;
    final stream = _injectedLinkStream ?? appLinks!.uriLinkStream;
    final getInitialLink = _injectedInitialLink ?? appLinks!.getInitialLink;

    _subscription = stream.listen(
      (uri) => unawaited(_accept(uri)),
      onError: (_) {},
    );

    try {
      final initial = await getInitialLink();
      if (initial != null) await _accept(initial);
    } catch (_) {
      // A malformed or unavailable platform link must never block app startup.
    }
  }

  Future<bool> markNavigationReady() async {
    _navigationReady = true;
    final productId = _pendingProductId;
    if (productId == null) return false;

    _pendingProductId = null;
    await _openProduct(productId);
    return true;
  }

  Future<void> _accept(Uri uri) async {
    final productId = productIdFromUri(uri);
    if (productId == null) return;

    final now = DateTime.now();
    if (_lastAcceptedLink == uri.toString() &&
        _lastAcceptedAt != null &&
        now.difference(_lastAcceptedAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastAcceptedLink = uri.toString();
    _lastAcceptedAt = now;

    if (!_navigationReady) {
      _pendingProductId = productId;
      return;
    }

    await _openProduct(productId);
  }

  Future<void> _openProduct(int productId) async {
    if (_injectedOpenProduct != null) {
      await _injectedOpenProduct(productId);
      return;
    }
    if (!Get.isRegistered<ProductControllerImp>()) {
      _pendingProductId = productId;
      return;
    }

    final controller = Get.find<ProductControllerImp>();
    await controller.loadProductDetail(
      productId: productId,
      navigate: Get.currentRoute != RouteHelper.productDetailsScreen,
    );
  }

  static int? productIdFromUri(Uri uri) {
    final segments = uri.pathSegments
        .where((segment) => segment.trim().isNotEmpty)
        .toList(growable: false);

    if (uri.scheme.toLowerCase() == 'doctorbike-store') {
      if (uri.host.toLowerCase() != 'products' || segments.length != 1) {
        return null;
      }
      return _positiveInt(segments.single);
    }

    final configuredBase = Uri.tryParse(AppConstants.storePublicBaseUrl);
    if (uri.scheme.toLowerCase() != 'https' ||
        configuredBase == null ||
        uri.host.toLowerCase() != configuredBase.host.toLowerCase()) {
      return null;
    }

    final isRootPath =
        segments.length == 3 &&
        segments[0] == 'store' &&
        segments[1] == 'products';
    final isPublicPath =
        segments.length == 4 &&
        segments[0] == 'public' &&
        segments[1] == 'store' &&
        segments[2] == 'products';
    if (!isRootPath && !isPublicPath) return null;

    return _positiveInt(segments.last);
  }

  static int? _positiveInt(String value) {
    final parsed = int.tryParse(value);
    return parsed != null && parsed > 0 ? parsed : null;
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel());
    super.onClose();
  }
}
