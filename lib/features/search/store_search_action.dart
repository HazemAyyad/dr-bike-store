import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'search_screen.dart';

class StoreSearchAction extends StatelessWidget {
  const StoreSearchAction({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    key: const ValueKey('store-search-action'),
    tooltip: 'storeOpenSearch'.tr,
    onPressed: () => Get.to(() => const SearchScreen()),
    icon: const Icon(Icons.search_rounded),
  );
}
