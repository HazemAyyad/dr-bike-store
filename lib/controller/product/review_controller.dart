import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/classes/store_view_state.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/model/commint_model.dart';
import '../../repository/product/review_repository.dart';

enum ReviewMutationState { idle, submitting, success, syncRequired, failure }

class ReviewController extends GetxController {
  ReviewController({
    required this.repository,
    required this.isAuthenticated,
    required this.accountRoles,
    Future<bool> Function()? connectivityCheck,
  }) : connectivityCheck =
           connectivityCheck ??
           (() async => await CheckInternet.checkInternet() == true);

  final ReviewDataSource repository;
  final bool Function() isAuthenticated;
  final List<String>? Function() accountRoles;
  final Future<bool> Function() connectivityCheck;
  final commentController = TextEditingController();

  int? productId;
  int rating = 0;
  StoreViewState<List<Review>> publicState = const StoreInitial();
  StoreViewState<List<Review>> ownState = const StoreInitial();
  ReviewMutationState mutationState = ReviewMutationState.idle;
  Review? ownReview;
  String? message;

  bool get canSubmit {
    if (!isAuthenticated()) return false;
    final roles = accountRoles();
    if (roles == null) return true;
    return roles.map((e) => e.toLowerCase()).contains('customer');
  }

  bool get rolesKnown => accountRoles() != null;
  bool get isGuest => !isAuthenticated();
  bool get canEdit => ownReview?.canEdit == true;

  void bindProduct(int id) {
    if (id <= 0) throw ArgumentError.value(id, 'productId');
    if (productId == id) return;
    productId = id;
    rating = 0;
    ownReview = null;
    commentController.clear();
  }

  void setRating(int value) {
    if (value < 1 || value > 5) throw ArgumentError.value(value, 'rating');
    rating = value;
    update();
  }

  String? validate() {
    if (rating < 1 || rating > 5) return 'اختر تقييماً من 1 إلى 5.';
    if (commentController.text.length > 5000) return 'التعليق يتجاوز 5000 حرف.';
    return null;
  }

  Future<void> loadPublic() async {
    final id = productId;
    if (id == null) return;
    if (!await connectivityCheck()) {
      publicState = const StoreOffline(message: 'storeOfflineMessage');
      update();
      return;
    }
    publicState = const StoreLoading();
    update();
    try {
      final response = await repository.publicReviews(id);
      if (response.statusCode != 200 || response.body is! Map) {
        throw const FormatException('public reviews');
      }
      final reviews =
          ReviewResponse.fromJson(
            Map<String, dynamic>.from(response.body as Map),
          ).rows;
      publicState =
          reviews.isEmpty
              ? const StoreEmpty(message: 'storeNoReviews')
              : StoreContent(reviews);
    } catch (_) {
      publicState = const StoreError(message: 'storeGenericError');
    }
    update();
  }

  Future<void> loadOwn() async {
    if (!isAuthenticated()) return;
    if (!await connectivityCheck()) {
      ownState = const StoreOffline(message: 'storeOfflineMessage');
      update();
      return;
    }
    ownState = const StoreLoading();
    update();
    try {
      final reviews = await _fetchOwnReviews();
      ownReview = reviews.firstWhereOrNull(
        (review) => review.productId == productId,
      );
      ownState =
          reviews.isEmpty
              ? const StoreEmpty(message: 'لا يوجد تقييم شخصي.')
              : StoreContent(reviews);
    } catch (_) {
      ownState = const StoreError(message: 'storeGenericError');
    }
    update();
  }

  Future<bool> submit() async {
    final id = productId;
    message = validate();
    if (id == null || message != null || !canSubmit) {
      message ??= isGuest ? 'يجب تسجيل الدخول أولاً.' : 'يلزم حساب عميل نشط.';
      mutationState = ReviewMutationState.failure;
      update();
      return false;
    }
    mutationState = ReviewMutationState.submitting;
    update();
    final original = ownReview;
    try {
      final response = await repository.submitReview(
        id,
        rating,
        _commentOrNull(),
      );
      final parsed = _parseMutation(response, expectedStatus: 201);
      ownReview = parsed;
      mutationState = ReviewMutationState.success;
      message =
          parsed.status == ReviewStatus.pending
              ? 'تم إرسال تقييمك للمراجعة'
              : 'تم حفظ التقييم.';
      update();
      return true;
    } catch (_) {
      ownReview = original;
      mutationState = ReviewMutationState.failure;
      message = 'تعذر إرسال التقييم.';
      update();
      return false;
    }
  }

  Future<bool> updatePending() async {
    final current = ownReview;
    if (current == null || !current.canEdit || validate() != null) return false;
    mutationState = ReviewMutationState.submitting;
    update();
    Response response;
    try {
      response = await repository.updatePendingReview(
        current.id,
        current.productId,
        rating,
        _commentOrNull(),
      );
      if (!_isAcceptedCompatibilityMutation(response)) {
        throw const FormatException('review update acknowledgment');
      }
    } catch (_) {
      ownReview = current;
      mutationState = ReviewMutationState.failure;
      message = 'تعذر تحديث التقييم.';
      update();
      return false;
    }

    try {
      final reviews = await _fetchOwnReviews();
      final refreshed = reviews.firstWhere(
        (review) =>
            review.id == current.id && review.productId == current.productId,
      );
      ownReview = refreshed;
      ownState = StoreContent(reviews);
      mutationState = ReviewMutationState.success;
      message = 'تم تحديث تقييمك وهو قيد المراجعة.';
    } catch (_) {
      mutationState = ReviewMutationState.syncRequired;
      message = 'تم حفظ التقييم، لكن تعذر تحديث حالته. أعد المحاولة.';
    }
    update();
    return true;
  }

  bool _isAcceptedCompatibilityMutation(Response response) {
    if (response.statusCode != 200 || response.body is! Map) return false;
    final body = response.body as Map;
    return body['isSuccess'] == true && body['isFailure'] != true;
  }

  Future<List<Review>> _fetchOwnReviews() async {
    final response = await repository.ownReviews();
    if (response.statusCode != 200 || response.body is! Map) {
      throw const FormatException('own reviews');
    }
    final raw = (response.body as Map)['data'];
    if (raw is! List) throw const FormatException('own reviews data');
    return raw
        .whereType<Map>()
        .map((row) => Review.fromOwnJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Review _parseMutation(Response response, {required int expectedStatus}) {
    if (response.statusCode != expectedStatus || response.body is! Map) {
      throw const FormatException('review mutation');
    }
    final data = (response.body as Map)['data'];
    if (data is! Map) throw const FormatException('review mutation data');
    return Review.fromOwnJson(Map<String, dynamic>.from(data));
  }

  String? _commentOrNull() =>
      commentController.text.trim().isEmpty
          ? null
          : commentController.text.trim();

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
