import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/categores/categores_controller.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoresControllerImp>();
    final content = _FilterContent(
      controller: controller,
      onClose: () => Navigator.maybePop(context),
    );
    if (embedded) return content;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: StorePalette.surface,
        body: SafeArea(child: content),
      ),
    );
  }
}

Future<void> showProductFilterSheet(
  BuildContext context,
  CategoresControllerImp controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: StorePalette.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder:
      (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: FractionallySizedBox(
          heightFactor: 0.76,
          child: _FilterContent(
            controller: controller,
            onClose: () => Navigator.pop(context),
          ),
        ),
      ),
);

class _FilterContent extends StatefulWidget {
  const _FilterContent({required this.controller, required this.onClose});

  final CategoresControllerImp controller;
  final VoidCallback onClose;

  @override
  State<_FilterContent> createState() => _FilterContentState();
}

class _FilterContentState extends State<_FilterContent> {
  late final TextEditingController minimum;
  late final TextEditingController maximum;
  late bool availableOnly;
  late bool onSale;

  @override
  void initState() {
    super.initState();
    final current = widget.controller.filters.value;
    minimum = TextEditingController(text: _number(current.minimumPrice));
    maximum = TextEditingController(text: _number(current.maximumPrice));
    availableOnly = current.availableOnly;
    onSale = current.onSale;
  }

  String _number(double? value) =>
      value == null ? '' : value.toStringAsFixed(value % 1 == 0 ? 0 : 2);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 4),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              IconButton(
                tooltip: 'إغلاق',
                onPressed: widget.onClose,
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Text(
                  'تصفية المنتجات',
                  textAlign: TextAlign.center,
                  style: StoreTypography.title,
                ),
              ),
              TextButton(onPressed: _reset, child: const Text('إعادة')),
            ],
          ),
        ),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
          children: [
            Text('السعر', style: StoreTypography.label),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _priceField(minimum, 'من')),
                const SizedBox(width: 10),
                Expanded(child: _priceField(maximum, 'إلى')),
              ],
            ),
            const Divider(height: 30, color: StorePalette.border),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: availableOnly,
              activeColor: StorePalette.purple,
              title: const Text('المنتجات المتاحة للشراء فقط'),
              secondary: const Icon(Icons.inventory_2_outlined),
              onChanged: (value) => setState(() => availableOnly = value),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: onSale,
              activeColor: StorePalette.purple,
              title: const Text('العروض والخصومات فقط'),
              secondary: const Icon(Icons.local_offer_outlined),
              onChanged: (value) => setState(() => onSale = value),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(StoreSpacing.sm),
              decoration: BoxDecoration(
                color: StorePalette.lightPurple,
                borderRadius: BorderRadius.circular(StoreRadii.md),
              ),
              child: Text(
                'يتم تطبيق التصفية من الخادم على جميع منتجات التصنيف.',
                style: StoreTypography.caption.copyWith(
                  color: StorePalette.navy,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton(
            onPressed: _apply,
            style: FilledButton.styleFrom(
              backgroundColor: StorePalette.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StoreRadii.md),
              ),
            ),
            child: const Text('تطبيق الفلاتر'),
          ),
        ),
      ),
    ],
  );

  Widget _priceField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: '₪',
          filled: true,
          fillColor: StorePalette.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(StoreRadii.md),
            borderSide: const BorderSide(color: StorePalette.border),
          ),
        ),
      );

  Future<void> _apply() async {
    final min = double.tryParse(minimum.text.trim());
    final max = double.tryParse(maximum.text.trim());
    if ((min != null && min < 0) ||
        (max != null && max < 0) ||
        (min != null && max != null && min > max)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تحقق من نطاق السعر المدخل.')),
      );
      return;
    }
    widget.onClose();
    await widget.controller.applyCatalogFilters(
      CatalogFilters(
        minimumPrice: min,
        maximumPrice: max,
        availableOnly: availableOnly,
        onSale: onSale,
        sort: widget.controller.filters.value.sort,
      ),
    );
  }

  Future<void> _reset() async {
    minimum.clear();
    maximum.clear();
    setState(() {
      availableOnly = false;
      onSale = false;
    });
    widget.onClose();
    await widget.controller.clearCatalogFilters();
  }

  @override
  void dispose() {
    minimum.dispose();
    maximum.dispose();
    super.dispose();
  }
}
