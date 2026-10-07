import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/account/account_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';
import '../../core/widget/store_states.dart';
import '../../core/widget/store_navigation_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AccountControllerImp>()) {
        Get.find<AccountControllerImp>().getUserById(navigate: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) => GetBuilder<AccountControllerImp>(
    builder:
        (controller) => Scaffold(
          appBar: AppBar(title: Text('Profile'.tr)),
          body: SafeArea(child: _body(controller)),
        ),
  );

  Widget _body(AccountControllerImp controller) {
    if (controller.profileStatus == AccountViewStatus.loading ||
        controller.profileStatus == AccountViewStatus.initial) {
      return const StoreSkeletonList(itemCount: 6);
    }
    if (controller.profileStatus == AccountViewStatus.offline) {
      return StoreMessageState(
        kind: StoreMessageKind.offline,
        message: controller.message ?? 'Check the internet connection'.tr,
        actionLabel: 'storeRetry'.tr,
        onAction: () => controller.getUserById(navigate: false),
      );
    }
    if (controller.profileStatus == AccountViewStatus.error) {
      return StoreMessageState(
        kind: StoreMessageKind.error,
        message: controller.message ?? 'تعذر تحميل الحساب',
        actionLabel: 'storeRetry'.tr,
        onAction: () => controller.getUserById(navigate: false),
      );
    }
    final guest = controller.profileStatus == AccountViewStatus.guest;
    return ListView(
      padding: const EdgeInsets.all(StoreSpacing.md),
      children: [
        _header(controller, guest),
        const SizedBox(height: StoreSpacing.md),
        if (!guest) ...[
          _tile(
            Icons.person_outline,
            'Personal Details'.tr,
            () => Get.toNamed(RouteHelper.personalDetailsPage),
          ),
          _tile(
            Icons.receipt_long_outlined,
            'My orders'.tr,
            controller.getAllOrders,
          ),
          _tile(
            Icons.location_on_outlined,
            'العناوين',
            () => Get.toNamed(RouteHelper.addresses),
          ),
          _tile(
            Icons.payments_outlined,
            'طرق الدفع',
            () => Get.toNamed(RouteHelper.paymentMethods),
          ),
        ],
        _tile(Icons.language, 'اللغة', () => Get.toNamed(RouteHelper.lang)),
        _tile(
          Icons.settings_outlined,
          'الإعدادات',
          () => Get.toNamed(RouteHelper.settings),
        ),
        _tile(
          Icons.help_outline,
          'المساعدة والدعم',
          () => Get.toNamed(RouteHelper.helpSupport),
        ),
        if (!guest)
          _tile(
            Icons.manage_accounts_outlined,
            'إجراءات الحساب',
            () => Get.toNamed(RouteHelper.accountActions),
          ),
      ],
    );
  }

  Widget _header(AccountControllerImp controller, bool guest) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StoreSpacing.md),
      child:
          guest
              ? Column(
                children: [
                  Text('تصفح كضيف', style: StoreTypography.title),
                  const SizedBox(height: StoreSpacing.sm),
                  StoreButton(
                    label: 'register/log in.'.tr,
                    onPressed: () => Get.toNamed(RouteHelper.intoLog),
                  ),
                ],
              )
              : ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(
                  controller.profile?.fullName ?? '',
                  style: StoreTypography.title,
                ),
                subtitle: Text(
                  controller.profile?.email ??
                      controller.profile?.phoneNumber ??
                      '',
                ),
              ),
    ),
  );

  Widget _tile(IconData icon, String title, VoidCallback onTap) => Card(
    child: ListTile(
      leading: Icon(icon, color: StorePalette.purple),
      title: Text(title),
      trailing: Icon(storeForwardIcon(context)),
      onTap: onTap,
    ),
  );
}
