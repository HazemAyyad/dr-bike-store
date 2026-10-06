import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/store_tokens.dart';

/// Truthful capability gate: the Storefront compatibility catalog currently
/// advertises neither server-side filtering nor sorting.
class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('filtering'.tr)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(StoreSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_alt_off_outlined,
              size: 52,
              color: StorePalette.textSecondary,
            ),
            const SizedBox(height: StoreSpacing.md),
            Text(
              'storeCatalogFiltersUnavailableTitle'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: StoreSpacing.sm),
            Text(
              'storeCatalogFiltersUnavailableBody'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: StorePalette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
