import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/product/product_controller.dart';
import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/widget/store_media.dart';
import 'image_view.dart';
import 'product_360_view.dart';
import 'product_media_presentation.dart';
import 'video_view.dart';

class ViewImageAndVideo extends StatefulWidget {
  const ViewImageAndVideo({required this.controllerScreen, super.key});

  final ProductControllerImp controllerScreen;

  @override
  State<ViewImageAndVideo> createState() => _ViewImageAndVideoState();
}

class _ViewImageAndVideoState extends State<ViewImageAndVideo> {
  late final PageController _pageController = PageController(
    initialPage: widget.controllerScreen.selectedMediaIndex,
  );

  @override
  void didUpdateWidget(covariant ViewImageAndVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.controllerScreen.selectedMediaIndex;
    if (_pageController.hasClients &&
        _pageController.page?.round() != target &&
        target < widget.controllerScreen.media.length) {
      _pageController.animateToPage(
        target,
        duration: StoreMotion.standard,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.controllerScreen.media;
    if (media.isEmpty || widget.controllerScreen.selectedMedia == null) {
      return const AspectRatio(
        aspectRatio: 1.05,
        child: StoreMediaPlaceholder(),
      );
    }
    final multiple = media.length > 1;
    final shortcuts = _mediaShortcuts(media);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final height = (constraints.maxWidth * 0.86).clamp(250.0, 350.0);
            return SizedBox(
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(StoreRadii.lg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: StorePalette.surface,
                      child: PageView.builder(
                        key: const Key('product-media-pages'),
                        controller: _pageController,
                        reverse:
                            Directionality.of(context) == TextDirection.rtl,
                        itemCount: media.length,
                        onPageChanged: widget.controllerScreen.selectMedia,
                        itemBuilder:
                            (context, index) => _hero(context, media[index]),
                      ),
                    ),
                    if (multiple) ...[
                      PositionedDirectional(
                        start: StoreSpacing.xs,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _MediaArrow(
                            key: const Key('product-media-previous'),
                            icon:
                                Directionality.of(context) == TextDirection.rtl
                                    ? Icons.chevron_right
                                    : Icons.chevron_left,
                            onPressed:
                                widget.controllerScreen.selectedMediaIndex > 0
                                    ? () => _goTo(
                                      widget
                                              .controllerScreen
                                              .selectedMediaIndex -
                                          1,
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        end: StoreSpacing.xs,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _MediaArrow(
                            key: const Key('product-media-next'),
                            icon:
                                Directionality.of(context) == TextDirection.rtl
                                    ? Icons.chevron_left
                                    : Icons.chevron_right,
                            onPressed:
                                widget.controllerScreen.selectedMediaIndex <
                                        media.length - 1
                                    ? () => _goTo(
                                      widget
                                              .controllerScreen
                                              .selectedMediaIndex +
                                          1,
                                    )
                                    : null,
                          ),
                        ),
                      ),
                    ],
                    PositionedDirectional(
                      end: StoreSpacing.sm,
                      bottom: StoreSpacing.sm,
                      child: Container(
                        key: const Key('product-media-counter'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: StoreSpacing.sm,
                          vertical: StoreSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: StorePalette.derivedScrim,
                          borderRadius: BorderRadius.circular(StoreRadii.pill),
                        ),
                        child: Text(
                          '${widget.controllerScreen.selectedMediaIndex + 1}/${media.length}',
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (shortcuts.isNotEmpty)
                      Positioned(
                        left: StoreSpacing.xs,
                        top: StoreSpacing.xs,
                        child: Column(
                          children: [
                            for (final shortcut in shortcuts) ...[
                              _MediaTypeShortcut(
                                media: shortcut.$2,
                                selected:
                                    shortcut.$1 ==
                                    widget.controllerScreen.selectedMediaIndex,
                                onPressed: () => _goTo(shortcut.$1),
                              ),
                              const SizedBox(height: StoreSpacing.xxs),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (multiple) ...[
          const SizedBox(height: StoreSpacing.sm),
          SizedBox(
            height: 72,
            child: ListView.separated(
              key: const Key('product-media-thumbnails'),
              padding: const EdgeInsets.symmetric(horizontal: StoreSpacing.xxs),
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              separatorBuilder:
                  (_, _) => const SizedBox(width: StoreSpacing.xs),
              itemBuilder:
                  (context, index) => ProductMediaThumbnail(
                    key: ValueKey('product-media-thumbnail-$index'),
                    media: media[index],
                    selected:
                        index == widget.controllerScreen.selectedMediaIndex,
                    onTap: () => _goTo(index),
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _hero(BuildContext context, ProductMedia media) {
    return switch (media.type) {
      ProductMediaType.image => GestureDetector(
        key: ValueKey('product-image-hero-${media.id}'),
        onTap: () => _openViewer(context),
        child: Padding(
          padding: const EdgeInsets.all(StoreSpacing.sm),
          child: StoreNetworkMedia(
            url: productMediaUrl(media.path),
            semanticLabel: productMediaAlt(context, media),
            fit: BoxFit.contain,
          ),
        ),
      ),
      ProductMediaType.video => VideoView(
        key: ValueKey('product-video-${media.id}'),
        media: media,
        onOpenViewer: () => _openViewer(context),
      ),
      ProductMediaType.interactive360 => Product360View(
        key: ValueKey('product-360-${media.id}'),
        media: media,
        onOpenViewer: () => _openViewer(context),
      ),
      ProductMediaType.unsupported => GestureDetector(
        onTap: () => _openViewer(context),
        child: StoreMediaPlaceholder(
          icon: Icons.view_in_ar_outlined,
          message:
              isExplicitModel3d(media) ? _unsupported3dLabel(context) : null,
        ),
      ),
    };
  }

  String _unsupported3dLabel(BuildContext context) =>
      (Get.locale?.languageCode ??
                  Localizations.localeOf(context).languageCode) ==
              'ar'
          ? 'عارض 3D التفاعلي غير متوفر'
          : 'Interactive 3D viewer is unavailable';

  void _openViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => ProductMediaViewer(
              media: widget.controllerScreen.media,
              initialIndex: widget.controllerScreen.selectedMediaIndex,
              onIndexChanged: widget.controllerScreen.selectMedia,
            ),
      ),
    );
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.controllerScreen.media.length) return;
    _pageController.animateToPage(
      index,
      duration: StoreMotion.standard,
      curve: Curves.easeOutCubic,
    );
  }

  List<(int, ProductMedia)> _mediaShortcuts(List<ProductMedia> media) {
    final shortcuts = <(int, ProductMedia)>[];
    final seen = <StoreMediaType>{};
    for (var index = 0; index < media.length; index++) {
      final item = media[index];
      if (item.isImage && !isExplicitModel3d(item)) continue;
      final type = productMediaBadgeType(item);
      if (seen.add(type)) shortcuts.add((index, item));
    }
    return shortcuts;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _MediaTypeShortcut extends StatelessWidget {
  const _MediaTypeShortcut({
    required this.media,
    required this.selected,
    required this.onPressed,
  });

  final ProductMedia media;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: productMediaTypeLabel(media),
    child: IconButton(
      key: ValueKey('product-media-shortcut-${media.id}'),
      tooltip: productMediaTypeLabel(media),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor:
            selected ? StorePalette.lightPurple : StorePalette.background,
        foregroundColor: selected ? StorePalette.purple : StorePalette.navy,
        side: BorderSide(
          color: selected ? StorePalette.purple : StorePalette.border,
        ),
      ),
      icon: Icon(_icon),
    ),
  );

  IconData get _icon => switch (productMediaBadgeType(media)) {
    StoreMediaType.image => Icons.image_outlined,
    StoreMediaType.video => Icons.play_circle_outline,
    StoreMediaType.model3d => Icons.view_in_ar_outlined,
    StoreMediaType.spin360 => Icons.threesixty,
  };
}

class _MediaArrow extends StatelessWidget {
  const _MediaArrow({required this.icon, required this.onPressed, super.key});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: StorePalette.derivedScrim,
      disabledBackgroundColor: Colors.black12,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white54,
    ),
    icon: Icon(icon),
  );
}
