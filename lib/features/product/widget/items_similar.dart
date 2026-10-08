import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/product/product_controller.dart';
import '../../../core/classes/store_view_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/model/get_all_item_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_cards.dart';
import '../../../core/widget/store_media.dart';
import '../../../core/widget/store_skeletons.dart';

class SimilarItemsSection extends StatelessWidget {
  const SimilarItemsSection({required this.controller, super.key});

  final ProductControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.similarItemsState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('storeSimilarProducts'.tr, style: StoreTypography.title),
        const SizedBox(height: StoreSpacing.sm),
        switch (state) {
          StoreInitial<List<Item>>() ||
          StoreLoading<List<Item>>() => const StoreHorizontalProductsSkeleton(),
          StoreEmpty<List<Item>>(:final message) => Text(
            message.tr,
            style: StoreTypography.body,
          ),
          StoreOffline<List<Item>>(:final message) ||
          StoreError<List<Item>>(:final message) => Column(
            children: [
              Text(message.tr, style: StoreTypography.body),
              TextButton(
                onPressed: () {
                  final item = controller.itemView;
                  if (item != null) controller.loadSimilarItems(item);
                },
                child: Text('storeRetry'.tr),
              ),
            ],
          ),
          StoreContent<List<Item>>(:final data) => SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              separatorBuilder:
                  (_, _) => const SizedBox(width: StoreSpacing.sm),
              itemBuilder: (context, index) {
                final item = data[index];
                return SizedBox(
                  width: 150,
                  child: StoreProductCard(
                    compact: true,
                    name: _name(item),
                    price: item.normailPrice,
                    rating: item.rate,
                    reviewCount: item.reviewCount,
                    inStock: item.available,
                    discountPercent: item.discount > 0 ? item.discount : null,
                    media: StoreNetworkMedia(
                      url: _mainMedia(item),
                      semanticLabel: _name(item),
                    ),
                    onTap:
                        () =>
                            controller.getCategoryById2(itemId: item.productId),
                  ),
                );
              },
            ),
          ),
          StoreSuccess<List<Item>>() => const SizedBox.shrink(),
        },
      ],
    );
  }

  String _name(Item item) => switch (Get.locale?.languageCode) {
    'en' => item.nameEng,
    'he' => item.nameAbree,
    _ => item.nameAr,
  };

  String? _mainMedia(Item item) {
    if (item.storefrontMedia.isEmpty) return null;
    final media = item.storefrontMedia.firstWhere((media) => media.isMain);
    final path = media.posterPath ?? media.path;
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;
    return '${AppConstants.appBaseUrl}${path.startsWith('/') ? '' : '/'}$path';
  }
}
