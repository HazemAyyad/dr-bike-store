import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_media.dart';
import 'product_360_view.dart';
import 'product_media_presentation.dart';
import 'video_view.dart';

/// Backwards-compatible image-only entry point.
class ImageView extends StatelessWidget {
  const ImageView({
    required this.images,
    this.initialIndex = 0,
    this.onIndexChanged,
    super.key,
  });

  final List<ProductMedia> images;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  @override
  Widget build(BuildContext context) => ProductMediaViewer(
    media: images,
    initialIndex: initialIndex,
    onIndexChanged: onIndexChanged,
  );
}

class ProductMediaViewer extends StatefulWidget {
  const ProductMediaViewer({
    required this.media,
    this.initialIndex = 0,
    this.onIndexChanged,
    super.key,
  });

  final List<ProductMedia> media;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  @override
  State<ProductMediaViewer> createState() => _ProductMediaViewerState();
}

class _ProductMediaViewerState extends State<ProductMediaViewer> {
  late final PageController _pageController;
  late int _index;
  bool _immersive = false;

  @override
  void initState() {
    super.initState();
    final lastIndex = widget.media.isEmpty ? 0 : widget.media.length - 1;
    _index = widget.initialIndex.clamp(0, lastIndex);
    _pageController = PageController(initialPage: _index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) {
      return const Scaffold(body: StoreMediaPlaceholder());
    }
    final multiple = widget.media.length > 1;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E12),
      body: SafeArea(
        child: Column(
          children: [
            _ViewerHeader(
              index: _index,
              total: widget.media.length,
              immersive: _immersive,
              onClose: () => Navigator.of(context).pop(),
              onFullscreen: _toggleFullscreen,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    key: const Key('fullscreen-media-pages'),
                    controller: _pageController,
                    itemCount: widget.media.length,
                    onPageChanged: _select,
                    itemBuilder:
                        (context, index) =>
                            _mediaPage(context, widget.media[index]),
                  ),
                  if (multiple) ...[
                    PositionedDirectional(
                      start: StoreSpacing.sm,
                      child: _GalleryArrow(
                        key: const Key('gallery-previous'),
                        icon:
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_right
                                : Icons.chevron_left,
                        onPressed: _index > 0 ? () => _move(-1) : null,
                      ),
                    ),
                    PositionedDirectional(
                      end: StoreSpacing.sm,
                      child: _GalleryArrow(
                        key: const Key('gallery-next'),
                        icon:
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                        onPressed:
                            _index < widget.media.length - 1
                                ? () => _move(1)
                                : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (multiple)
              Container(
                key: const Key('fullscreen-media-thumbnails'),
                height: 86,
                padding: const EdgeInsets.symmetric(vertical: StoreSpacing.xs),
                color: const Color(0xFF0D0E12),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StoreSpacing.sm,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.media.length,
                  separatorBuilder:
                      (_, _) => const SizedBox(width: StoreSpacing.xs),
                  itemBuilder:
                      (context, index) => ProductMediaThumbnail(
                        key: ValueKey('fullscreen-media-thumbnail-$index'),
                        media: widget.media[index],
                        selected: index == _index,
                        onTap: () => _goTo(index),
                        width: 64,
                        dark: true,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _mediaPage(BuildContext context, ProductMedia media) {
    return switch (media.type) {
      ProductMediaType.image => InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: StoreSpacing.sm),
          child: StoreNetworkMedia(
            url: productMediaUrl(media.path),
            semanticLabel: productMediaAlt(context, media),
            fit: BoxFit.contain,
          ),
        ),
      ),
      ProductMediaType.video => Padding(
        padding: const EdgeInsets.symmetric(vertical: StoreSpacing.sm),
        child: VideoView(
          key: ValueKey('fullscreen-video-${media.id}'),
          media: media,
          showFullscreen: false,
        ),
      ),
      ProductMediaType.interactive360 => Product360View(
        key: ValueKey('fullscreen-360-${media.id}'),
        media: media,
        dark: true,
      ),
      ProductMediaType.unsupported => StoreMediaPlaceholder(
        icon: Icons.view_in_ar_outlined,
        message: isExplicitModel3d(media) ? _unsupported3dLabel(context) : null,
      ),
    };
  }

  String _unsupported3dLabel(BuildContext context) =>
      (Get.locale?.languageCode ??
                  Localizations.localeOf(context).languageCode) ==
              'ar'
          ? 'عارض 3D التفاعلي غير متوفر'
          : 'Interactive 3D viewer is unavailable';

  void _select(int index) {
    setState(() => _index = index);
    widget.onIndexChanged?.call(index);
  }

  void _move(int delta) => _goTo(_index + delta);

  void _goTo(int index) {
    if (index < 0 || index >= widget.media.length) return;
    _pageController.animateToPage(
      index,
      duration: StoreMotion.standard,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _toggleFullscreen() async {
    _immersive = !_immersive;
    if (_immersive) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_immersive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _pageController.dispose();
    super.dispose();
  }
}

class _ViewerHeader extends StatelessWidget {
  const _ViewerHeader({
    required this.index,
    required this.total,
    required this.immersive,
    required this.onClose,
    required this.onFullscreen,
  });

  final int index;
  final int total;
  final bool immersive;
  final VoidCallback onClose;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Text(
          '${index + 1}/$total',
          key: const Key('fullscreen-media-counter'),
          textDirection: TextDirection.ltr,
          style: StoreTypography.label.copyWith(color: Colors.white),
        ),
        PositionedDirectional(
          start: StoreSpacing.xs,
          child: IconButton.filled(
            key: const Key('fullscreen-media-close'),
            tooltip:
                (Get.locale?.languageCode ??
                            Localizations.localeOf(context).languageCode) ==
                        'ar'
                    ? 'إغلاق'
                    : 'Close',
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF111318),
              minimumSize: const Size(42, 42),
            ),
            icon: const Icon(Icons.close_rounded, size: 24),
          ),
        ),
        PositionedDirectional(
          end: StoreSpacing.xs,
          child: IconButton(
            key: const Key('fullscreen-media-toggle'),
            tooltip:
                (Get.locale?.languageCode ??
                            Localizations.localeOf(context).languageCode) ==
                        'ar'
                    ? 'ملء الشاشة'
                    : 'Fullscreen',
            onPressed: onFullscreen,
            color: Colors.white,
            icon: Icon(immersive ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
        ),
      ],
    ),
  );
}

class _GalleryArrow extends StatelessWidget {
  const _GalleryArrow({required this.icon, required this.onPressed, super.key});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: StorePalette.derivedScrim,
      disabledBackgroundColor: Colors.black12,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white38,
    ),
    icon: Icon(icon),
  );
}
