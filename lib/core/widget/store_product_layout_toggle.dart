import 'package:flutter/material.dart';

import '../theme/store_tokens.dart';

class StoreProductLayoutToggle extends StatelessWidget {
  const StoreProductLayoutToggle({
    required this.isGrid,
    required this.onChanged,
    super.key,
  });

  final bool isGrid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: StorePalette.surface,
      border: Border.all(color: StorePalette.border),
      borderRadius: BorderRadius.circular(StoreRadii.sm),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(
          icon: Icons.view_list_rounded,
          label: 'عرض قائمة',
          selected: !isGrid,
          onTap: () => onChanged(false),
        ),
        _button(
          icon: Icons.grid_view_rounded,
          label: 'عرض شبكة',
          selected: isGrid,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );

  Widget _button({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) => Tooltip(
    message: label,
    child: IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor:
            selected ? StorePalette.lightPurple : Colors.transparent,
        foregroundColor:
            selected ? StorePalette.purple : StorePalette.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoreRadii.sm),
        ),
      ),
      icon: Icon(icon, size: 20),
    ),
  );
}
