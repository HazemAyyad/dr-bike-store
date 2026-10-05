import 'package:flutter/material.dart';

import '../theme/store_tokens.dart';
import '../theme/store_typography.dart';

enum StoreMediaType { image, video, model3d, spin360 }

extension StoreMediaTypeLabel on StoreMediaType {
  String get label => switch (this) {
    StoreMediaType.image => 'صورة',
    StoreMediaType.video => 'فيديو',
    StoreMediaType.model3d => 'ثلاثي الأبعاد',
    StoreMediaType.spin360 => 'عرض 360',
  };

  IconData get icon => switch (this) {
    StoreMediaType.image => Icons.image_outlined,
    StoreMediaType.video => Icons.play_circle_outline,
    StoreMediaType.model3d => Icons.view_in_ar_outlined,
    StoreMediaType.spin360 => Icons.threesixty,
  };
}

class StoreMediaBadge extends StatelessWidget {
  const StoreMediaBadge({required this.type, super.key});

  final StoreMediaType type;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: StoreSpacing.xs,
      vertical: StoreSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: StorePalette.scrim,
      borderRadius: BorderRadius.circular(StoreRadii.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(type.icon, size: StoreIconSizes.small, color: Colors.white),
        const SizedBox(width: StoreSpacing.xxs),
        Text(
          type.label,
          style: StoreTypography.caption.copyWith(color: Colors.white),
        ),
      ],
    ),
  );
}

class StoreMediaPlaceholder extends StatelessWidget {
  const StoreMediaPlaceholder({
    this.message = 'الصورة غير متاحة',
    this.onRetry,
    this.icon = Icons.broken_image_outlined,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: StorePalette.background,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(StoreSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: StoreIconSizes.large,
              color: StorePalette.textSecondary,
            ),
            const SizedBox(height: StoreSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: StoreTypography.caption,
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
          ],
        ),
      ),
    ),
  );
}

class StoreNetworkMedia extends StatelessWidget {
  const StoreNetworkMedia({
    required this.url,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    this.type = StoreMediaType.image,
    this.onRetry,
    super.key,
  });

  final String? url;
  final String semanticLabel;
  final BoxFit fit;
  final StoreMediaType type;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return StoreMediaPlaceholder(onRetry: onRetry);
    }
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url!,
            fit: fit,
            excludeFromSemantics: true,
            frameBuilder: (context, child, frame, synchronous) {
              if (synchronous || frame != null) return child;
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
            errorBuilder: (_, _, _) => StoreMediaPlaceholder(onRetry: onRetry),
          ),
          if (type != StoreMediaType.image)
            PositionedDirectional(
              top: StoreSpacing.xs,
              end: StoreSpacing.xs,
              child: StoreMediaBadge(type: type),
            ),
        ],
      ),
    );
  }
}
