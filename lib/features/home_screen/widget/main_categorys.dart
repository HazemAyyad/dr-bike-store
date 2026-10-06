import 'package:flutter/material.dart';

import '../../../core/widget/store_cards.dart';
import '../../../core/widget/store_media.dart';

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
    media: StoreNetworkMedia(
      url: image,
      semanticLabel: title,
      fit: BoxFit.contain,
    ),
  );
}
