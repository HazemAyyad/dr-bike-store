import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/widget/store_media.dart';

String productMediaUrl(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;
  return '${AppConstants.appBaseUrl}${path.startsWith('/') ? '' : '/'}$path';
}

bool isExplicitModel3d(ProductMedia media) {
  final type = media.metadata['media_type']?.toString().toLowerCase();
  return type == '3d' || type == 'model' || type == 'model_3d';
}

StoreMediaType productMediaBadgeType(ProductMedia media) {
  if (isExplicitModel3d(media)) return StoreMediaType.model3d;
  return switch (media.type) {
    ProductMediaType.image => StoreMediaType.image,
    ProductMediaType.video => StoreMediaType.video,
    ProductMediaType.interactive360 => StoreMediaType.spin360,
    ProductMediaType.unsupported => StoreMediaType.model3d,
  };
}

String productMediaTypeLabel(ProductMedia media) {
  if (isExplicitModel3d(media)) return 'storeMedia3d'.tr;
  return switch (media.type) {
    ProductMediaType.image => 'storeMediaImage'.tr,
    ProductMediaType.video => 'storeMediaVideo'.tr,
    ProductMediaType.interactive360 => 'storeMedia360'.tr,
    ProductMediaType.unsupported => 'storeMediaUnsupported'.tr,
  };
}

String productMediaAlt(BuildContext context, ProductMedia media) {
  final language =
      Get.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
  return media.altTranslations[language] ??
      media.altTranslations['ar'] ??
      productMediaTypeLabel(media);
}

class ProductMediaThumbnail extends StatelessWidget {
  const ProductMediaThumbnail({
    required this.media,
    required this.selected,
    required this.onTap,
    this.width = 68,
    this.dark = false,
    super.key,
  });

  final ProductMedia media;
  final bool selected;
  final VoidCallback onTap;
  final double width;
  final bool dark;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: productMediaTypeLabel(media),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(StoreRadii.sm),
      child: AnimatedContainer(
        duration: StoreMotion.fast,
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF191A20) : StorePalette.surface,
          borderRadius: BorderRadius.circular(StoreRadii.sm),
          border: Border.all(
            color:
                selected
                    ? StorePalette.purple
                    : dark
                    ? Colors.white24
                    : StorePalette.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ThumbnailMedia(media: media),
            if (!media.isImage)
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: const EdgeInsets.all(StoreSpacing.xxs),
                  child: _CompactMediaBadge(type: productMediaBadgeType(media)),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _CompactMediaBadge extends StatelessWidget {
  const _CompactMediaBadge({required this.type});

  final StoreMediaType type;

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    decoration: BoxDecoration(
      color: const Color(0xB30D0E12),
      borderRadius: BorderRadius.circular(StoreRadii.sm),
    ),
    alignment: Alignment.center,
    child: Icon(_icon, size: 17, color: Colors.white),
  );

  IconData get _icon => switch (type) {
    StoreMediaType.image => Icons.image_outlined,
    StoreMediaType.video => Icons.play_arrow_rounded,
    StoreMediaType.model3d => Icons.view_in_ar_outlined,
    StoreMediaType.spin360 => Icons.threesixty,
  };
}

class _ThumbnailMedia extends StatelessWidget {
  const _ThumbnailMedia({required this.media});

  final ProductMedia media;

  @override
  Widget build(BuildContext context) {
    final poster = media.posterPath;
    if (poster != null) {
      return StoreNetworkMedia(
        url: productMediaUrl(poster),
        semanticLabel: productMediaTypeLabel(media),
        fit: BoxFit.cover,
      );
    }
    if (media.isVideo || isExplicitModel3d(media)) {
      return ColoredBox(
        color: const Color(0xFF15161B),
        child: Icon(
          media.isVideo ? Icons.play_circle_outline : Icons.view_in_ar_outlined,
          color: Colors.white,
          size: StoreIconSizes.large,
        ),
      );
    }
    return StoreNetworkMedia(
      url: productMediaUrl(media.path),
      semanticLabel: productMediaTypeLabel(media),
      fit: BoxFit.cover,
    );
  }
}
