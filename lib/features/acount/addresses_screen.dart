import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/account/account_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/widget/store_buttons.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<AccountControllerImp>(
    builder:
        (c) => Scaffold(
          appBar: AppBar(title: const Text('العنوان')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(StoreSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('العنوان المستخدم حاليًا في الملف الشخصي'),
                  const SizedBox(height: StoreSpacing.md),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(
                        c.profile?.address?.trim().isNotEmpty == true
                            ? c.profile!.address!
                            : 'لم يتم تحديد عنوان',
                      ),
                      subtitle: Text(c.profile?.city?.cityNameAr ?? ''),
                    ),
                  ),
                  const SizedBox(height: StoreSpacing.md),
                  StoreButton(
                    label: 'تعديل بيانات العنوان',
                    onPressed:
                        () => Get.toNamed(RouteHelper.personalDetailsPage),
                  ),
                  const SizedBox(height: StoreSpacing.sm),
                  const Text('لا تتوفر حاليًا خدمة حفظ عناوين متعددة.'),
                ],
              ),
            ),
          ),
        ),
  );
}
