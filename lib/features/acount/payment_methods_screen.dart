import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/theme/store_tokens.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('طرق الدفع'.tr)),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(StoreSpacing.md),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text('الدفع نقدًا عند الاستلام'.tr),
                subtitle: Text('طريقة الدفع المتاحة حاليًا'.tr),
                trailing: const Icon(Icons.check_circle_outline),
              ),
            ),
            const SizedBox(height: StoreSpacing.md),
            Text('حفظ بطاقات الدفع الرقمية غير متاح أو غير مهيأ حاليًا.'.tr),
          ],
        ),
      ),
    ),
  );
}
