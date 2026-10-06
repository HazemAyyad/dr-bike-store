import 'package:flutter/material.dart';
import '../../core/theme/store_tokens.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('طرق الدفع')),
    body: const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(StoreSpacing.md),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.payments_outlined),
                title: Text('الدفع نقدًا عند الاستلام'),
                subtitle: Text('طريقة الدفع المتاحة حاليًا'),
                trailing: Icon(Icons.check_circle_outline),
              ),
            ),
            SizedBox(height: StoreSpacing.md),
            Text('حفظ بطاقات الدفع الرقمية غير متاح أو غير مهيأ حاليًا.'),
          ],
        ),
      ),
    ),
  );
}
