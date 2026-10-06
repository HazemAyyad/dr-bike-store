import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/LocalizationController.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/store_tokens.dart';

class LangScreen extends StatelessWidget {
  const LangScreen({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<LocalizationController>(
    builder:
        (controller) => Scaffold(
          appBar: AppBar(title: Text('Select your language'.tr)),
          body: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(StoreSpacing.md),
              itemCount: AppConstants.languages.length,
              separatorBuilder:
                  (_, _) => const SizedBox(height: StoreSpacing.sm),
              itemBuilder: (context, index) {
                final language = AppConstants.languages[index];
                final selected =
                    controller.locale.languageCode == language.languageCode;
                return Card(
                  child: RadioListTile<String>(
                    value: language.languageCode!,
                    groupValue: controller.locale.languageCode,
                    title: Text(
                      language.languageName ?? language.languageCode!,
                    ),
                    secondary:
                        selected
                            ? const Icon(
                              Icons.check_circle,
                              color: StorePalette.purple,
                            )
                            : null,
                    onChanged: (_) {
                      controller.setLanguage(
                        Locale(language.languageCode!, language.countryCode),
                      );
                      controller.setSelectIndex(index);
                    },
                  ),
                );
              },
            ),
          ),
        ),
  );
}
