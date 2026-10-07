import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/account/account_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/widget/store_states.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});
  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<AccountControllerImp>();
      if (controller.conactUsModel == null && !controller.contactLoading) {
        controller.getConactUs();
      }
    });
  }

  @override
  Widget build(BuildContext context) => GetBuilder<AccountControllerImp>(
    builder: (c) {
      final data = c.conactUsModel?.data;
      return Scaffold(
        appBar: AppBar(title: const Text('المساعدة والدعم')),
        body:
            c.contactLoading && data == null
                ? const StoreSkeletonList(itemCount: 5)
                : c.contactMessage != null && data == null
                ? StoreMessageState(
                  kind: StoreMessageKind.error,
                  message: c.contactMessage!,
                  actionLabel: 'storeRetry'.tr,
                  onAction: c.getConactUs,
                )
                : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(StoreSpacing.md),
                    children: [
                      if (data?.call?.trim().isNotEmpty == true)
                        ListTile(
                          leading: const Icon(Icons.call_outlined),
                          title: Text(data!.call!),
                          onTap: c.openCall,
                        ),
                      if (data?.whatsApp?.trim().isNotEmpty == true)
                        ListTile(
                          leading: const Icon(Icons.chat_outlined),
                          title: const Text('WhatsApp'),
                          onTap: c.openWhatsApp,
                        ),
                      if (data?.instagram?.trim().isNotEmpty == true)
                        ListTile(
                          leading: const Icon(Icons.camera_alt_outlined),
                          title: const Text('Instagram'),
                          onTap: c.openInstagram,
                        ),
                      if (data?.twitter?.trim().isNotEmpty == true)
                        ListTile(
                          leading: const Icon(Icons.alternate_email),
                          title: const Text('Twitter'),
                          onTap: c.openTwitter,
                        ),
                      const Divider(),
                      ListTile(
                        title: Text('Terms and Conditions'.tr),
                        onTap:
                            () => Get.toNamed(RouteHelper.termsConditionsPage),
                      ),
                      ListTile(
                        title: Text('Who are we'.tr),
                        onTap: () => Get.toNamed(RouteHelper.aboutUsScreen),
                      ),
                      ListTile(
                        title: Text('Contact us'.tr),
                        onTap: () => Get.toNamed(RouteHelper.contactUsPage),
                      ),
                    ],
                  ),
                ),
      );
    },
  );
}
