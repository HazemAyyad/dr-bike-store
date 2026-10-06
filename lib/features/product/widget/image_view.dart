import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_media.dart';

class ImageView extends StatefulWidget {
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
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const Scaffold(body: StoreMediaPlaceholder());
    }
    final multiple = widget.images.length > 1;
    return Scaffold(
      backgroundColor: StorePalette.navy,
      appBar: AppBar(
        backgroundColor: StorePalette.navy,
        foregroundColor: Colors.white,
        title: Text(
          '${_index + 1} / ${widget.images.length}',
          style: StoreTypography.label.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    reverse: Directionality.of(context) == TextDirection.rtl,
                    itemCount: widget.images.length,
                    onPageChanged: _select,
                    itemBuilder:
                        (context, index) => InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: StoreNetworkMedia(
                            url: _mediaUrl(widget.images[index].path),
                            semanticLabel: _alt(widget.images[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                  ),
                  if (multiple) ...[
                    PositionedDirectional(
                      start: StoreSpacing.sm,
                      child: _GalleryArrow(
                        icon:
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_right
                                : Icons.chevron_left,
                        onPressed:
                            _index > 0
                                ? () => _pageController.previousPage(
                                  duration: StoreMotion.standard,
                                  curve: Curves.easeOut,
                                )
                                : null,
                      ),
                    ),
                    PositionedDirectional(
                      end: StoreSpacing.sm,
                      child: _GalleryArrow(
                        icon:
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                        onPressed:
                            _index < widget.images.length - 1
                                ? () => _pageController.nextPage(
                                  duration: StoreMotion.standard,
                                  curve: Curves.easeOut,
                                )
                                : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (multiple)
              SizedBox(
                height: 82,
                child: ListView.separated(
                  padding: const EdgeInsets.all(StoreSpacing.xs),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  separatorBuilder:
                      (_, _) => const SizedBox(width: StoreSpacing.xs),
                  itemBuilder:
                      (context, index) => InkWell(
                        onTap:
                            () => _pageController.animateToPage(
                              index,
                              duration: StoreMotion.standard,
                              curve: Curves.easeOut,
                            ),
                        child: Container(
                          width: 64,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(StoreRadii.sm),
                            border: Border.all(
                              color:
                                  index == _index
                                      ? StorePalette.purple
                                      : Colors.white24,
                              width: index == _index ? 2 : 1,
                            ),
                          ),
                          child: StoreNetworkMedia(
                            url: _mediaUrl(widget.images[index].path),
                            semanticLabel: _alt(widget.images[index]),
                          ),
                        ),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _select(int index) {
    setState(() => _index = index);
    widget.onIndexChanged?.call(index);
  }

  String _alt(ProductMedia media) {
    final language = Localizations.localeOf(context).languageCode;
    return media.altTranslations[language] ??
        media.altTranslations['ar'] ??
        'Product image';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _GalleryArrow extends StatelessWidget {
  const _GalleryArrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    onPressed: onPressed,
    style: IconButton.styleFrom(backgroundColor: StorePalette.derivedScrim),
    icon: Icon(icon),
  );
}

String _mediaUrl(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;
  return '${AppConstants.appBaseUrl}${path.startsWith('/') ? '' : '/'}$path';
}
