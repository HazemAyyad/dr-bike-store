import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/classes/store_view_state.dart';
import '../../../core/model/commint_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';

class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({
    required this.state,
    required this.onRetry,
    super.key,
  });

  final StoreViewState<List<Review>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('storeReviews'.tr, style: StoreTypography.title),
        const SizedBox(height: StoreSpacing.sm),
        switch (state) {
          StoreInitial<List<Review>>() || StoreLoading<List<Review>>() =>
            const Center(child: CircularProgressIndicator()),
          StoreEmpty<List<Review>>(:final message) => _SectionMessage(
            message: message.tr,
          ),
          StoreOffline<List<Review>>(:final message) => _SectionMessage(
            message: message.tr,
            onRetry: onRetry,
          ),
          StoreError<List<Review>>(:final message) => _SectionMessage(
            message: message.tr,
            onRetry: onRetry,
          ),
          StoreContent<List<Review>>(:final data) => Column(
            children: data.take(5).map(_ReviewCard.new).toList(),
          ),
          StoreSuccess<List<Review>>() => const SizedBox.shrink(),
        },
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(this.review);

  final Review review;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: StoreSpacing.xs),
    padding: const EdgeInsets.all(StoreSpacing.sm),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      border: Border.all(color: StorePalette.border),
      borderRadius: BorderRadius.circular(StoreRadii.md),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: StorePalette.lightPurple,
              child: Icon(Icons.person_outline, color: StorePalette.navy),
            ),
            const SizedBox(width: StoreSpacing.xs),
            Expanded(
              child: Text(review.userName, style: StoreTypography.label),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: StorePalette.warning),
                Text('${review.rate}', style: StoreTypography.caption),
              ],
            ),
          ],
        ),
        const SizedBox(height: StoreSpacing.xs),
        Text(review.comment ?? '', style: StoreTypography.body),
      ],
    ),
  );
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(StoreSpacing.md),
    decoration: BoxDecoration(
      color: StorePalette.background,
      borderRadius: BorderRadius.circular(StoreRadii.md),
    ),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center, style: StoreTypography.body),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: Text('storeRetry'.tr)),
      ],
    ),
  );
}
