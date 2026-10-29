import 'package:get/get.dart';
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
    appBar: AppBar(title: Text('الإعدادات'.tr)),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(StoreSpacing.md),
        children: [
          Text('إعدادات محلية'.tr),
          SwitchListTile(
            title: Text('الوضع الداكن'.tr),
            subtitle: Text('يُحفظ على هذا الجهاز'.tr),
            value: dark,
            onChanged: (_) {
              ThemeServices().switchTheme();
              setState(() => dark = !dark);
            },
          ),
        ],
      ),
    ),
  );
}
