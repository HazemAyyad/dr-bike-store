import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/store_tokens.dart';
import '../../../core/widget/store_states.dart';

class EmptyCar extends StatelessWidget {
  const EmptyCar({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: StorePalette.background,
    child: StoreMessageState(
      kind: StoreMessageKind.empty,
      icon: Icons.shopping_cart_outlined,
      title: 'Your shopping cart is empty'.tr,
      message: 'أضف المنتجات التي تريد الاحتفاظ بها لإتمام الطلب لاحقًا.',
    ),
  );
}
