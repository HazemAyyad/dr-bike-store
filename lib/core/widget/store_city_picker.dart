import 'package:doctor_bike/core/theme/store_colors.dart';
import 'package:flutter/material.dart';

import '../model/city_model.dart';
import '../theme/store_tokens.dart';

class StoreCityPicker extends StatelessWidget {
  const StoreCityPicker({
    required this.cities,
    required this.value,
    required this.onChanged,
    required this.decoration,
    super.key,
  });

  final List<Citys> cities;
  final Citys? value;
  final ValueChanged<Citys> onChanged;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(StoreRadii.md),
    onTap: cities.isEmpty ? null : () => _selectCity(context),
    child: InputDecorator(
      isEmpty: value == null,
      decoration: decoration.copyWith(
        enabled: cities.isNotEmpty,
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      child: Text(value?.cityNameAr ?? '', overflow: TextOverflow.ellipsis),
    ),
  );

  Future<void> _selectCity(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final selected = await showDialog<Citys>(
      context: context,
      builder: (_) => _CitySearchDialog(cities: cities, selectedId: value?.id),
    );
    if (context.mounted && selected != null && selected.id != value?.id) {
      onChanged(selected);
    }
  }
}

class _CitySearchDialog extends StatefulWidget {
  const _CitySearchDialog({required this.cities, required this.selectedId});

  final List<Citys> cities;
  final int? selectedId;

  @override
  State<_CitySearchDialog> createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends State<_CitySearchDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = widget.cities
        .where(
          (city) => [
            city.cityNameAr,
            city.cityNameEng,
            city.cityNameAbree,
          ].any((name) => name.toLowerCase().contains(_query)),
        )
        .toList(growable: false);

    return Dialog(
      backgroundColor: StoreColors.resolve(context, StorePalette.background),
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 440),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'اختر المدينة',
                      style: TextStyle(
                        color: StoreColors.resolve(
                          context,
                          StorePalette.textPrimary,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: StoreColors.resolve(
                      context,
                      StorePalette.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                autofocus: true,
                style: TextStyle(
                  color: StoreColors.resolve(context, StorePalette.textPrimary),
                ),
                decoration: const InputDecoration(
                  hintText: 'ابحث عن مدينة',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged:
                    (text) =>
                        setState(() => _query = text.trim().toLowerCase()),
              ),
              const SizedBox(height: 8),
              Flexible(
                child:
                    results.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'لا توجد مدن مطابقة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: StoreColors.resolve(
                                context,
                                StorePalette.textSecondary,
                              ),
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final city = results[index];
                            return ListTile(
                              title: Text(
                                city.cityNameAr,
                                style: TextStyle(
                                  color: StoreColors.resolve(
                                    context,
                                    StorePalette.textPrimary,
                                  ),
                                ),
                              ),
                              trailing:
                                  city.id == widget.selectedId
                                      ? const Icon(
                                        Icons.check,
                                        color: StorePalette.purple,
                                      )
                                      : null,
                              onTap: () => Navigator.pop(context, city),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
