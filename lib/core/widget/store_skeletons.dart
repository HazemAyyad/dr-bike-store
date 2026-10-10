import 'package:flutter/material.dart';

import '../theme/store_tokens.dart';
import 'store_states.dart';

/// Content-shaped loading placeholders shared by Store screens.
///
/// Action progress (for example submitting checkout or signing in) deliberately
/// remains on the action itself. These skeletons are for data-backed content.
class StoreProductCollectionSkeleton extends StatelessWidget {
  const StoreProductCollectionSkeleton({
    this.isGrid = true,
    this.showHeader = true,
    this.itemCount = 9,
    super.key,
  });

  final bool isGrid;
  final bool showHeader;
  final int itemCount;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const ValueKey('store-product-collection-skeleton'),
    physics: const NeverScrollableScrollPhysics(),
    slivers: [
      if (showHeader) const SliverToBoxAdapter(child: _CatalogHeaderSkeleton()),
      SliverPadding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          StoreSpacing.sm,
          StoreSpacing.xs,
          StoreSpacing.sm,
          StoreSpacing.lg,
        ),
        sliver:
            isGrid
                ? SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: StoreCalibration.denseProductCardHeight,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (_, _) => const _ProductCardSkeleton(),
                )
                : SliverList.separated(
                  itemCount: itemCount,
                  separatorBuilder:
                      (_, _) => const SizedBox(height: StoreSpacing.sm),
                  itemBuilder: (_, _) => const _ProductListCardSkeleton(),
                ),
      ),
    ],
  );
}

class StoreProductDetailsSkeleton extends StatelessWidget {
  const StoreProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    key: const ValueKey('store-product-details-skeleton'),
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsetsDirectional.fromSTEB(
      StoreSpacing.sm,
      StoreSpacing.xxs,
      StoreSpacing.sm,
      StoreSpacing.lg,
    ),
    children: const [
      StoreSkeletonBox(height: 330, borderRadius: StoreRadii.lg),
      SizedBox(height: StoreSpacing.sm),
      StoreSkeletonBox(width: 210, height: 22),
      SizedBox(height: StoreSpacing.xs),
      StoreSkeletonBox(width: 118, height: 16),
      SizedBox(height: StoreSpacing.md),
      Row(
        children: [
          Expanded(child: StoreSkeletonBox(height: 58)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 58)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 58)),
        ],
      ),
      SizedBox(height: StoreSpacing.md),
      StoreSkeletonBox(height: 92, borderRadius: StoreRadii.lg),
      SizedBox(height: StoreSpacing.sm),
      Row(
        children: [
          Expanded(child: StoreSkeletonBox(height: 44)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 44)),
        ],
      ),
      SizedBox(height: StoreSpacing.md),
      StoreSkeletonBox(height: 156, borderRadius: StoreRadii.lg),
    ],
  );
}

class StoreHorizontalProductsSkeleton extends StatelessWidget {
  const StoreHorizontalProductsSkeleton({this.itemCount = 3, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('store-horizontal-products-skeleton'),
    height: 240,
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(width: StoreSpacing.sm),
      itemBuilder:
          (_, _) => const SizedBox(width: 150, child: _ProductCardSkeleton()),
    ),
  );
}

class StoreReviewsSkeleton extends StatelessWidget {
  const StoreReviewsSkeleton({this.itemCount = 3, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('store-reviews-skeleton'),
    children: List.generate(
      itemCount,
      (_) => const Padding(
        padding: EdgeInsets.only(bottom: StoreSpacing.xs),
        child: _ReviewCardSkeleton(),
      ),
    ),
  );
}

class StoreOrdersSkeleton extends StatelessWidget {
  const StoreOrdersSkeleton({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const ValueKey('store-orders-skeleton'),
    padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 20),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: itemCount,
    separatorBuilder: (_, _) => const SizedBox(height: StoreSpacing.xs),
    itemBuilder:
        (_, _) => Container(
          height: 132,
          padding: const EdgeInsets.all(StoreSpacing.sm),
          decoration: BoxDecoration(
            color: StorePalette.surface,
            borderRadius: BorderRadius.circular(StoreRadii.lg),
            border: Border.all(color: StorePalette.border),
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  Expanded(child: StoreSkeletonBox(height: 14)),
                  SizedBox(width: StoreSpacing.lg),
                  StoreSkeletonBox(width: 62, height: 22),
                ],
              ),
              SizedBox(height: StoreSpacing.xs),
              Row(
                children: [
                  StoreSkeletonBox(width: 46, height: 46),
                  SizedBox(width: StoreSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StoreSkeletonBox(height: 13),
                        SizedBox(height: StoreSpacing.xxs),
                        StoreSkeletonBox(width: 110, height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  StoreSkeletonBox(width: 72, height: 13),
                  Spacer(),
                  StoreSkeletonBox(width: 84, height: 13),
                ],
              ),
            ],
          ),
        ),
  );
}

class StoreAddressesSkeleton extends StatelessWidget {
  const StoreAddressesSkeleton({this.itemCount = 3, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const ValueKey('store-addresses-skeleton'),
    padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 96),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: itemCount,
    separatorBuilder: (_, _) => const SizedBox(height: StoreSpacing.xs),
    itemBuilder:
        (_, _) => Container(
          height: 116,
          padding: const EdgeInsets.all(StoreSpacing.sm),
          decoration: BoxDecoration(
            color: StorePalette.surface,
            borderRadius: BorderRadius.circular(StoreRadii.lg),
            border: Border.all(color: StorePalette.border),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoreSkeletonBox(width: 40, height: 40),
              SizedBox(width: StoreSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoreSkeletonBox(width: 92, height: 14),
                    SizedBox(height: StoreSpacing.xs),
                    StoreSkeletonBox(height: 12),
                    SizedBox(height: StoreSpacing.xxs),
                    StoreSkeletonBox(width: 146, height: 10),
                    Spacer(),
                    StoreSkeletonBox(width: 120, height: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
  );
}

class StoreInlineFieldSkeleton extends StatelessWidget {
  const StoreInlineFieldSkeleton({this.height = 56, this.label, super.key});

  final double height;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label ?? 'جاري التحميل',
    child: ExcludeSemantics(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: StorePalette.surface,
          borderRadius: BorderRadius.circular(StoreRadii.md),
          border: Border.all(color: StorePalette.border),
        ),
        child: const Row(
          children: [
            StoreSkeletonBox(
              width: 24,
              height: 24,
              borderRadius: StoreRadii.md,
            ),
            SizedBox(width: StoreSpacing.sm),
            Expanded(child: StoreSkeletonBox(height: 14)),
            SizedBox(width: StoreSpacing.lg),
            StoreSkeletonBox(width: 16, height: 16),
          ],
        ),
      ),
    ),
  );
}

class _CatalogHeaderSkeleton extends StatelessWidget {
  const _CatalogHeaderSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsetsDirectional.fromSTEB(
      StoreSpacing.md,
      StoreSpacing.sm,
      StoreSpacing.md,
      StoreSpacing.xs,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoreSkeletonBox(width: 150, height: 18),
        SizedBox(height: StoreSpacing.sm),
        Row(
          children: [
            Expanded(child: StoreSkeletonBox(height: 40)),
            SizedBox(width: StoreSpacing.xs),
            Expanded(child: StoreSkeletonBox(height: 40)),
          ],
        ),
        SizedBox(height: StoreSpacing.xs),
        StoreSkeletonBox(width: 64, height: 11),
      ],
    ),
  );
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(StoreSpacing.xs),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      border: Border.all(color: StorePalette.border),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: StoreSkeletonBox(borderRadius: StoreRadii.md)),
        SizedBox(height: StoreSpacing.sm),
        StoreSkeletonBox(height: 13),
        SizedBox(height: StoreSpacing.xs),
        StoreSkeletonBox(width: 72, height: 11),
        SizedBox(height: StoreSpacing.sm),
        StoreSkeletonBox(height: 36, borderRadius: StoreRadii.md),
      ],
    ),
  );
}

class _ProductListCardSkeleton extends StatelessWidget {
  const _ProductListCardSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    height: 168,
    padding: const EdgeInsets.all(StoreSpacing.sm),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      border: Border.all(color: StorePalette.border),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 124,
          child: StoreSkeletonBox(borderRadius: StoreRadii.md),
        ),
        SizedBox(width: StoreSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoreSkeletonBox(height: 16),
              SizedBox(height: StoreSpacing.xs),
              StoreSkeletonBox(width: 84, height: 12),
              Spacer(),
              StoreSkeletonBox(height: 38, borderRadius: StoreRadii.md),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReviewCardSkeleton extends StatelessWidget {
  const _ReviewCardSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(StoreSpacing.sm),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      borderRadius: BorderRadius.circular(StoreRadii.md),
      border: Border.all(color: StorePalette.border),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StoreSkeletonBox(
              width: 36,
              height: 36,
              borderRadius: StoreRadii.round,
            ),
            SizedBox(width: StoreSpacing.xs),
            Expanded(child: StoreSkeletonBox(height: 13)),
            SizedBox(width: StoreSpacing.lg),
            StoreSkeletonBox(width: 44, height: 13),
          ],
        ),
        SizedBox(height: StoreSpacing.sm),
        StoreSkeletonBox(height: 12),
        SizedBox(height: StoreSpacing.xxs),
        StoreSkeletonBox(width: 180, height: 12),
      ],
    ),
  );
}
