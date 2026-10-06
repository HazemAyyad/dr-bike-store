import 'package:flutter/material.dart';
import '../../core/functions/theme_services.dart';
import '../../core/theme/store_tokens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool dark = ThemeServices().loadThemeFromBox();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الإعدادات')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(StoreSpacing.md),
        children: [
          const Text('إعدادات محلية'),
          SwitchListTile(
            title: const Text('الوضع الداكن'),
            subtitle: const Text('يُحفظ على هذا الجهاز'),
            value: dark,
            onChanged: (_) {
              ThemeServices().switchTheme();
              setState(() => dark = !dark);
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('إعدادات المتجر'),
            subtitle: Text(
              'حالة تشغيل المتجر تُدار من الخادم وليست تفضيلًا للمستخدم.',
            ),
          ),
        ],
      ),
    ),
  );
}
