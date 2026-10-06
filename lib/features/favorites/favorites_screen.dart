import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/favorites/favorites_controller.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/widget/store_states.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    return ColoredBox(
      color: StorePalette.background,
      child: Obx(
        () => StoreMessageState(
          kind:
              controller.status.value == FavoritesStatus.error
                  ? StoreMessageKind.error
                  : StoreMessageKind.empty,
          icon: Icons.favorite_border,
          title: 'storeFavoritesUnavailableTitle'.tr,
          message: 'storeFavoritesUnavailableMessage'.tr,
        ),
      ),
    );
  }
}
