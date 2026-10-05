import 'package:flutter/material.dart';

import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';
import '../../../core/widget/store_media.dart';

class PromoCard extends StatelessWidget {
  const PromoCard({
    required this.imageUrl,
    required this.title,
    required this.buttonText,
    required this.onPressed,
    this.description,
    super.key,
  });

  final String imageUrl;
  final String title;
  final String? description;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: title,
    child: Material(
      color: StorePalette.lightPurple,
      borderRadius: BorderRadius.circular(StoreRadii.pill),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: 170,
              child: StoreNetworkMedia(
                url: imageUrl,
                semanticLabel: title,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FractionallySizedBox(
                widthFactor: 0.58,
                child: Padding(
                  padding: const EdgeInsets.all(StoreSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTypography.headline,
                      ),
                      if (description?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: StoreSpacing.xxs),
                        Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: StoreTypography.caption,
                        ),
                      ],
                      const SizedBox(height: StoreSpacing.sm),
                      StoreButton(
                        label: buttonText,
                        onPressed: onPressed,
                        expand: false,
                        variant: StoreButtonVariant.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
