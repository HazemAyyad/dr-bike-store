import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
    final name = _localizedName(controller);
    final canIncrement =
        line.knownAvailableQuantity == null ||
        line.quantity < line.knownAvailableQuantity!;
    return Container(
      padding: const EdgeInsets.all(10),
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
              width: 76,
              height: 92,
              child: StoreNetworkMedia(
                url: _mediaUrl(line.mediaPath),
                semanticLabel: name,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTypography.bodyMedium.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ),
                    SizedBox.square(
                      dimension: 34,
                      child: IconButton(
                        tooltip: 'حذف',
                        padding: EdgeInsets.zero,
                        color: StorePalette.error,
                        onPressed: () => _confirmRemove(context, controller),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_optionLabel.isNotEmpty)
                  Text(
                    _optionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StoreTypography.caption,
                  ),
                Text(
                  'رمز المنتج: ${line.itemSnapshot.model.trim().isEmpty ? line.productId : line.itemSnapshot.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StoreTypography.caption.copyWith(fontSize: 10.5),
                ),
                if (line.requiresRevalidation)
                  Text(
                    'يتم التحقق من التوفر قبل الطلب',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StoreTypography.caption.copyWith(
                      color: StorePalette.warning,
                      fontSize: 10,
                    ),
                  ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${_price(line.total)} ₪',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StoreTypography.label.copyWith(
                        color: StorePalette.navy,
                        fontSize: 14,
                      ),
                    ),
                    if (line.discountPercent > 0) ...[
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${_price(line.subtotal)} ₪',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StoreTypography.caption.copyWith(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: StorePalette.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_price(line.discountPercent)}%',
                          style: StoreTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _QuantityStepper(
                    quantity: line.quantity,
                    canDecrement: line.quantity > 1,
                    canIncrement: canIncrement,
                    onDecrement: () => controller.decrementLine(line.identity),
                    onIncrement: () => controller.incrementLine(line.identity),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizedName(ShopController controller) {
    final language = controller.localizationController.locale.languageCode;
    return language == 'ar'
        ? line.nameAr
        : language == 'en'
        ? line.nameEng
        : line.nameHe;
  }

  String get _optionLabel => [
    if (line.sizeLabel?.trim().isNotEmpty == true) 'الخيار: ${line.sizeLabel}',
    if (line.colorLabel?.trim().isNotEmpty == true) line.colorLabel!,
  ].join(' • ');

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

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.canDecrement,
    required this.canIncrement,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    decoration: BoxDecoration(
      color: StorePalette.background,
      borderRadius: BorderRadius.circular(StoreRadii.sm),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepButton(
          icon: Icons.remove_rounded,
          enabled: canDecrement,
          onPressed: onDecrement,
          label: 'إنقاص الكمية',
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: StoreTypography.label,
          ),
        ),
        _stepButton(
          icon: Icons.add_rounded,
          enabled: canIncrement,
          onPressed: onIncrement,
          label: 'زيادة الكمية',
        ),
      ],
    ),
  );

  Widget _stepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
    required String label,
  }) => Semantics(
    button: true,
    enabled: enabled,
    label: label,
    child: SizedBox.square(
      dimension: 32,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
        iconSize: 17,
        icon: Icon(icon),
      ),
    ),
  );
}

String _price(num value) => NumberFormat('#,##0.##', 'en_US').format(value);
