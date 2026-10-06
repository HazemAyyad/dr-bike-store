import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/account/account_controller.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/widget/store_buttons.dart';
import '../../core/widget/store_fields.dart';
import '../../core/widget/store_states.dart';

class PersonalDetailsPage extends StatelessWidget {
  const PersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<AccountControllerImp>(
    builder:
        (controller) => Scaffold(
          appBar: AppBar(title: Text('Personal Details'.tr)),
          body: SafeArea(child: _body(controller)),
        ),
  );

  Widget _body(AccountControllerImp controller) {
    if (controller.profileStatus == AccountViewStatus.loading) {
      return const StoreSkeletonList(itemCount: 6);
    }
    if (controller.profile == null) {
      return StoreMessageState(
        kind:
            controller.profileStatus == AccountViewStatus.offline
                ? StoreMessageKind.offline
                : StoreMessageKind.error,
        message: controller.message ?? 'تعذر تحميل البيانات',
        actionLabel: 'storeRetry'.tr,
        onAction: () => controller.getUserById(navigate: false),
      );
    }
    return Form(
      key: controller.formstate,
      child: ListView(
        padding: const EdgeInsets.all(StoreSpacing.md),
        children: [
          StoreTextField(
            label: 'name'.tr,
            controller: controller.nameController,
          ),
          StoreTextField(
            label: 'email'.tr,
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          StoreTextField(
            label: 'Mobile number'.tr,
            controller: controller.phoneNumberController,
            keyboardType: TextInputType.phone,
          ),
          StoreTextField(
            label: 'Alternative mobile number'.tr,
            controller: controller.phoneNumber2Controller,
            keyboardType: TextInputType.phone,
          ),
          DropdownButtonFormField<String>(
            value: controller.selectedCityId,
            decoration: InputDecoration(labelText: 'City'.tr),
            items:
                controller.cities
                    .map(
                      (city) => DropdownMenuItem(
                        value: city.id.toString(),
                        child: Text(
                          controller
                                      .localizationController
                                      .locale
                                      .languageCode ==
                                  'ar'
                              ? city.cityNameAr
                              : controller
                                      .localizationController
                                      .locale
                                      .languageCode ==
                                  'he'
                              ? city.cityNameAbree
                              : city.cityNameEng,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => controller.selectedCityId = value,
          ),
          const SizedBox(height: StoreSpacing.sm),
          StoreTextField(
            label: 'address'.tr,
            controller: controller.addressController,
            maxLines: 3,
          ),
          if (controller.message != null) ...[
            const SizedBox(height: StoreSpacing.sm),
            Text(controller.message!, textAlign: TextAlign.center),
          ],
          const SizedBox(height: StoreSpacing.md),
          StoreButton(
            label:
                controller.mutationStatus == AccountMutationStatus.submitting
                    ? 'جارٍ الحفظ…'
                    : 'save'.tr,
            onPressed:
                controller.mutationStatus == AccountMutationStatus.submitting
                    ? null
                    : () {
                      if (controller.formstate.currentState?.validate() ??
                          false) {
                        controller.editeUser();
                      }
                    },
          ),
        ],
      ),
    );
  }
}
