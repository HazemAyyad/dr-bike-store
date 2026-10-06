import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_media.dart';

class Product360View extends StatelessWidget {
  const Product360View({required this.media, super.key});

  final ProductMedia media;

  @override
  Widget build(BuildContext context) {
    if (!media.isInteractive360) {
      return StoreMediaPlaceholder(
        icon: Icons.threesixty,
        message: 'store360Unavailable'.tr,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          minScale: 1,
          maxScale: 3,
          panEnabled: true,
          child: StoreNetworkMedia(
            url: _mediaUrl(media.path),
            semanticLabel: 'store360Media'.tr,
            fit: BoxFit.contain,
          ),
        ),
        PositionedDirectional(
          start: StoreSpacing.sm,
          bottom: StoreSpacing.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: StoreSpacing.sm,
              vertical: StoreSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: StorePalette.derivedScrim,
              borderRadius: BorderRadius.circular(StoreRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.threesixty, color: Colors.white),
                const SizedBox(width: StoreSpacing.xs),
                Text(
                  'store360Hint'.tr,
                  style: StoreTypography.caption.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _mediaUrl(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;
  return '${AppConstants.appBaseUrl}${path.startsWith('/') ? '' : '/'}$path';
}
