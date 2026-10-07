import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_media.dart';
import 'product_media_presentation.dart';

class Product360View extends StatelessWidget {
  const Product360View({
    required this.media,
    this.onOpenViewer,
    this.dark = false,
    super.key,
  });

  final ProductMedia media;
  final VoidCallback? onOpenViewer;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (!media.isInteractive360) {
      return StoreMediaPlaceholder(
        icon: Icons.threesixty,
        message: _unavailableLabel(context),
      );
    }
    final preview =
        media.posterPath ?? (_canRenderPath(media) ? media.path : null);
    final content = Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: dark ? const Color(0xFF0D0E12) : StorePalette.surface,
          child:
              preview == null
                  ? StoreMediaPlaceholder(
                    icon: Icons.threesixty,
                    message: _unavailableLabel(context),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(StoreSpacing.sm),
                    child: StoreNetworkMedia(
                      url: productMediaUrl(preview),
                      semanticLabel: 'store360Media'.tr,
                      fit: BoxFit.contain,
                    ),
                  ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(StoreSpacing.sm),
            padding: const EdgeInsets.symmetric(
              horizontal: StoreSpacing.sm,
              vertical: StoreSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: const Color(0xB30D0E12),
              borderRadius: BorderRadius.circular(StoreRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.threesixty, color: Colors.white),
                const SizedBox(width: StoreSpacing.xs),
                Flexible(
                  child: Text(
                    _unavailableLabel(context),
                    key: const Key('product-360-unavailable'),
                    textAlign: TextAlign.center,
                    style: StoreTypography.caption.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    if (onOpenViewer == null) return content;
    return GestureDetector(onTap: onOpenViewer, child: content);
  }

  bool _canRenderPath(ProductMedia media) {
    if (media.mimeType?.startsWith('image/') == true) return true;
    final lower = media.path.toLowerCase().split('?').first;
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  String _unavailableLabel(BuildContext context) =>
      (Get.locale?.languageCode ??
                  Localizations.localeOf(context).languageCode) ==
              'ar'
          ? 'المعاينة متاحة، العارض التفاعلي غير متوفر'
          : 'Preview available; interactive viewer unavailable';
}
