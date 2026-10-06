import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/product/product_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/widget/store_media.dart';
import 'image_view.dart';
import 'product_360_view.dart';
import 'video_view.dart';

class ViewImageAndVideo extends StatelessWidget {
  const ViewImageAndVideo({required this.controllerScreen, super.key});

  final ProductControllerImp controllerScreen;

  @override
  Widget build(BuildContext context) {
    final media = controllerScreen.media;
    final selected = controllerScreen.selectedMedia;
    if (media.isEmpty || selected == null) {
      return const AspectRatio(
        aspectRatio: StoreCalibration.productMediaAspectRatio,
        child: StoreMediaPlaceholder(),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: StoreCalibration.productMediaAspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(StoreRadii.lg),
            child: _hero(context, selected),
          ),
        ),
        if (media.length > 1) ...[
          const SizedBox(height: StoreSpacing.sm),
          SizedBox(
            height: 68,
            child: ListView.separated(
              key: const Key('product-media-thumbnails'),
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              separatorBuilder:
                  (_, _) => const SizedBox(width: StoreSpacing.xs),
              itemBuilder: (context, index) {
                final item = media[index];
                return Semantics(
                  button: true,
                  selected: index == controllerScreen.selectedMediaIndex,
                  label: _typeLabel(item),
                  child: InkWell(
                    onTap: () => controllerScreen.selectMedia(index),
                    borderRadius: BorderRadius.circular(StoreRadii.sm),
                    child: Container(
                      width: 68,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(StoreRadii.sm),
                        border: Border.all(
                          color:
                              index == controllerScreen.selectedMediaIndex
                                  ? StorePalette.purple
                                  : StorePalette.border,
                          width:
                              index == controllerScreen.selectedMediaIndex
                                  ? 2
                                  : 1,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          StoreNetworkMedia(
                            url: _mediaUrl(item.posterPath ?? item.path),
                            semanticLabel: _typeLabel(item),
                            type: _badgeType(item),
                          ),
                          if (!item.isSupported)
                            const StoreMediaPlaceholder(
                              icon: Icons.extension_off_outlined,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _hero(BuildContext context, ProductMedia media) {
    return switch (media.type) {
      ProductMediaType.image => GestureDetector(
        key: const Key('product-image-hero'),
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder:
                    (_) => ImageView(
                      images: controllerScreen.imageMedia,
                      initialIndex: controllerScreen.selectedImageIndex,
                      onIndexChanged: controllerScreen.selectImage,
                    ),
              ),
            ),
        child: StoreNetworkMedia(
          url: _mediaUrl(media.path),
          semanticLabel: _typeLabel(media),
          fit: BoxFit.contain,
        ),
      ),
      ProductMediaType.video => VideoView(media: media),
      ProductMediaType.interactive360 => Product360View(media: media),
      ProductMediaType.unsupported => StoreMediaPlaceholder(
        icon: Icons.extension_off_outlined,
        message: 'storeMediaUnsupported'.tr,
      ),
    };
  }

  StoreMediaType _badgeType(ProductMedia media) => switch (media.type) {
    ProductMediaType.image => StoreMediaType.image,
    ProductMediaType.video => StoreMediaType.video,
    ProductMediaType.interactive360 => StoreMediaType.spin360,
    ProductMediaType.unsupported => StoreMediaType.model3d,
  };

  String _typeLabel(ProductMedia media) => switch (media.type) {
    ProductMediaType.image => 'storeMediaImage'.tr,
    ProductMediaType.video => 'storeMediaVideo'.tr,
    ProductMediaType.interactive360 => 'storeMedia360'.tr,
    ProductMediaType.unsupported => 'storeMediaUnsupported'.tr,
  };
}

String _mediaUrl(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;
  return '${AppConstants.appBaseUrl}${path.startsWith('/') ? '' : '/'}$path';
}
