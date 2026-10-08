import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/widget/store_cards.dart';
import '../../../core/widget/store_media.dart';
import '../../../core/widget/store_states.dart';

class MainCategorys extends StatelessWidget {
  const MainCategorys({
    required this.image,
    required this.title,
    this.onTap,
    this.itemCount,
    this.compact = false,
    super.key,
  });

  final String image;
  final String title;
  final VoidCallback? onTap;
  final int? itemCount;
  final bool compact;

  @override
  Widget build(BuildContext context) => StoreCategoryCard(
    title: title,
    itemCount: itemCount,
    compact: compact,
    onTap: onTap ?? () {},
    media:
        _isSvgCategoryImage(image)
            ? SvgPicture.network(
              _resolveCategoryImageUrl(image),
              fit: BoxFit.contain,
              semanticsLabel: title,
              placeholderBuilder:
                  (_) => const Center(
                    child: StoreSkeletonBox(
                      width: 52,
                      height: 52,
                      borderRadius: StoreRadii.md,
                    ),
                  ),
              errorBuilder:
                  (_, _, _) => const StoreMediaPlaceholder(
                    icon: Icons.category_outlined,
                  ),
            )
            : StoreNetworkMedia(
              url: image,
              semanticLabel: title,
              fit: BoxFit.contain,
            ),
  );
}

bool _isSvgCategoryImage(String value) {
  final normalized = value.trim().replaceAll('\\', '/');
  final uri = Uri.tryParse(normalized);
  return (uri?.path ?? normalized).toLowerCase().endsWith('.svg');
}

String _resolveCategoryImageUrl(String value) {
  var path = value.trim().replaceAll('\\', '/');
  final uri = Uri.tryParse(path);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return path;
  }
  while (path.toLowerCase().startsWith('public/')) {
    path = path.substring('public/'.length);
  }
  while (path.toLowerCase().startsWith('/public/')) {
    path = path.substring('/public/'.length);
  }
  final base = AppConstants.appBaseUrl.replaceFirst(RegExp(r'/+$'), '');
  return '$base/${path.replaceFirst(RegExp(r'^/+'), '')}';
}
