import 'package:flutter/material.dart';

import '../../../core/widget/store_cards.dart';
import '../../../core/widget/store_media.dart';

class MainCategorys extends StatelessWidget {
  const MainCategorys({
    required this.image,
    required this.title,
    this.onTap,
    this.itemCount,
    super.key,
  });

  final String image;
  final String title;
  final VoidCallback? onTap;
  final int? itemCount;

  @override
  Widget build(BuildContext context) => StoreCategoryCard(
    title: title,
    itemCount: itemCount,
    onTap: onTap ?? () {},
    media: StoreNetworkMedia(
      url: image,
      semanticLabel: title,
      fit: BoxFit.contain,
    ),
  );
}
