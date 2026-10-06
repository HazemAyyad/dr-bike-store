import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/account/account_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';

class AccountActionsScreen extends StatelessWidget {
  const AccountActionsScreen({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<AccountControllerImp>(
    builder:
        (c) => Scaffold(
          appBar: AppBar(title: const Text('إجراءات الحساب')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(StoreSpacing.md),
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('تسجيل الخروج'),
                  onTap: () async {
                    final confirmed = await _confirm(
                      context,
                      'تسجيل الخروج',
                      'هل تريد إنهاء الجلسة على هذا الجهاز؟',
                    );
                    await c.logout(confirmed: confirmed);
                    if (confirmed) Get.offAllNamed(RouteHelper.homePage);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_off_outlined,
                    color: StorePalette.error,
                  ),
                  title: const Text('حذف/تعطيل الحساب'),
                  onTap: () async {
                    final confirmed = await _confirm(
                      context,
                      'حذف/تعطيل الحساب',
                      'سيُرسل الطلب إلى الخادم أولًا، ولن تُحذف جلستك إذا فشل الطلب.',
                    );
                    if (await c.deactivateAccount(confirmed: confirmed)) {
                      Get.offAllNamed(RouteHelper.homePage);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
  );
  Future<bool> _confirm(
    BuildContext context,
    String title,
    String body,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('تأكيد'),
                ),
              ],
            ),
      ) ??
      false;
}
