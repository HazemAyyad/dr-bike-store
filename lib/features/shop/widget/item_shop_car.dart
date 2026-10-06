import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/shop/shop_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/model/cart_line_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_media.dart';

class ItemShopCar extends StatelessWidget {
  const ItemShopCar({required this.line, super.key});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShopController>();
    final language = controller.localizationController.locale.languageCode;
    final name =
        language == 'ar'
            ? line.nameAr
            : language == 'en'
            ? line.nameEng
            : line.nameHe;
    return Container(
      padding: const EdgeInsets.all(StoreSpacing.sm),
      decoration: BoxDecoration(
        color: StorePalette.surface,
        border: Border.all(color: StorePalette.border),
        borderRadius: BorderRadius.circular(StoreRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(StoreRadii.md),
            child: SizedBox(
              width: 84,
              height: 96,
              child: StoreNetworkMedia(
                url: _mediaUrl(line.mediaPath),
                semanticLabel: name,
              ),
            ),
          ),
          const SizedBox(width: StoreSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTypography.bodyMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'حذف',
                      color: StorePalette.error,
                      onPressed: () => _confirmRemove(context, controller),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                if (line.sizeLabel != null || line.colorLabel != null)
                  Text(
                    [line.sizeLabel, line.colorLabel]
                        .whereType<String>()
                        .where((value) => value.isNotEmpty)
                        .join(' • '),
                    style: StoreTypography.caption,
                  ),
                if (line.requiresRevalidation)
                  Text(
                    'سيتم التحقق من التوفر قبل إتمام الطلب',
                    style: StoreTypography.caption.copyWith(
                      color: StorePalette.warning,
                    ),
                  ),
                const SizedBox(height: StoreSpacing.xs),
                Row(
                  children: [
                    Text(
                      '${line.unitPriceAfterDiscount.toStringAsFixed(2)} ₪',
                      style: StoreTypography.label,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => controller.decrementLine(line.identity),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${line.quantity}', style: StoreTypography.label),
                    IconButton(
                      onPressed: () => controller.incrementLine(line.identity),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _mediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${AppConstants.appBaseUrl}/${path.replaceFirst(RegExp(r'^/+'), '')}';
  }

  Future<void> _confirmRemove(
    BuildContext context,
    ShopController controller,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف المنتج؟'),
            content: const Text('سيتم حذف هذا الخيار فقط من السلة.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
    if (accepted == true) controller.removeLine(line.identity);
  }
}
