import 'package:doctor_bike/core/theme/store_colors.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/product/review_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/commint_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';
import '../../core/widget/store_states.dart';
import 'widget/commints.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({required this.productId, super.key});
  final int productId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final ReviewController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.bindProduct(widget.productId);
    controller.loadPublic();
    controller.loadOwn();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: ui.TextDirection.rtl,
    child: Scaffold(
      backgroundColor: StoreColors.resolve(context, StorePalette.background),
      appBar: AppBar(
        title: Text(
          'التقييمات'.tr,
          style: StoreColors.text(context, StoreTypography.title),
        ),
      ),
      body: GetBuilder<ReviewController>(
        builder:
            (controller) => ListView(
              padding: const EdgeInsets.all(StoreSpacing.md),
              children: [
                ProductReviewsSection(
                  state: controller.publicState,
                  onRetry: controller.loadPublic,
                ),
                const SizedBox(height: StoreSpacing.lg),
                Text(
                  'تقييمي'.tr,
                  style: StoreColors.text(context, StoreTypography.title),
                ),
                const SizedBox(height: StoreSpacing.sm),
                if (controller.isGuest)
                  StoreMessageState(
                    kind: StoreMessageKind.empty,
                    message: 'سجّل الدخول لإرسال تقييمك.'.tr,
                    actionLabel: 'تسجيل الدخول'.tr,
                    onAction: () => Get.toNamed(RouteHelper.signIn),
                  )
                else if (!controller.canSubmit)
                  StoreMessageState(
                    kind: StoreMessageKind.error,
                    message: 'إرسال التقييم يتطلب حساب عميل نشط.'.tr,
                  )
                else ...[
                  if (controller.ownReview case final review?)
                    _OwnReview(review),
                  if (controller.ownReview == null || controller.canEdit)
                    _Composer(controller),
                ],
              ],
            ),
      ),
    ),
  );
}

class _OwnReview extends StatelessWidget {
  const _OwnReview(this.review);
  final Review review;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(StoreSpacing.md),
    margin: const EdgeInsets.only(bottom: StoreSpacing.md),
    decoration: BoxDecoration(
      color: StoreColors.resolve(context, StorePalette.surface),
      border: Border.all(
        color: StoreColors.resolve(context, StorePalette.border),
      ),
      borderRadius: BorderRadius.circular(StoreRadii.lg),
    ),
    child: Text(switch (review.status) {
      ReviewStatus.pending => 'تم إرسال تقييمك للمراجعة'.tr,
      ReviewStatus.published => 'تقييمك منشور'.tr,
      ReviewStatus.rejected => 'لم يتم قبول تقييمك'.tr,
      ReviewStatus.unknown => 'حالة التقييم غير معروفة'.tr,
    }, style: StoreColors.text(context, StoreTypography.bodyMedium)),
  );
}

class _Composer extends StatelessWidget {
  const _Composer(this.controller);
  final ReviewController controller;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        children: List.generate(
          5,
          (index) => IconButton(
            onPressed: () => controller.setRating(index + 1),
            icon: Icon(
              index < controller.rating ? Icons.star : Icons.star_border,
              color: StorePalette.warning,
            ),
            tooltip: '@rating من 5'.trParams({'rating': '${index + 1}'}),
          ),
        ),
      ),
      TextField(
        controller: controller.commentController,
        maxLength: 5000,
        maxLines: 5,
        decoration: InputDecoration(labelText: 'تعليق اختياري'.tr),
      ),
      if (controller.message != null)
        Padding(
          padding: const EdgeInsets.only(bottom: StoreSpacing.sm),
          child: Text(
            controller.message!,
            style: StoreColors.text(context, StoreTypography.body).copyWith(
              color:
                  controller.mutationState == ReviewMutationState.failure
                      ? StorePalette.error
                      : StorePalette.success,
            ),
          ),
        ),
      StoreButton(
        label: controller.canEdit ? 'تحديث التقييم'.tr : 'إرسال التقييم'.tr,
        onPressed:
            controller.mutationState == ReviewMutationState.submitting
                ? null
                : () =>
                    controller.canEdit
                        ? controller.updatePending()
                        : controller.submit(),
        expand: true,
        isLoading: controller.mutationState == ReviewMutationState.submitting,
      ),
    ],
  );
}
