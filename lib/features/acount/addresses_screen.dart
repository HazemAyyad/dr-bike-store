import 'package:doctor_bike/core/theme/store_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/account/account_controller.dart';
import '../../core/model/city_model.dart';
import '../../core/model/store_address_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../core/widget/store_buttons.dart';
import '../../core/widget/store_city_picker.dart';
import '../../core/widget/store_skeletons.dart';
import '../../core/widget/store_states.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AccountControllerImp>()) {
        Get.find<AccountControllerImp>().loadAddresses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AccountControllerImp>()) {
      return Scaffold(
        body: StoreMessageState(
          kind: StoreMessageKind.error,
          message: 'تعذر فتح العناوين. أعد تشغيل التطبيق وحاول مجددًا.'.tr,
        ),
      );
    }
    return GetBuilder<AccountControllerImp>(
      builder:
          (controller) => Scaffold(
            backgroundColor: StoreColors.resolve(
              context,
              StorePalette.background,
            ),
            appBar: AppBar(
              title: Text(
                'العناوين الشخصية'.tr,
                style: StoreColors.text(context, StoreTypography.title),
              ),
              centerTitle: true,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed:
                  controller.addressesLoading
                      ? null
                      : () => _openEditor(context, controller),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text('إضافة عنوان'.tr),
            ),
            body: SafeArea(child: _body(context, controller)),
          ),
    );
  }

  Widget _body(BuildContext context, AccountControllerImp controller) {
    if (controller.addressesLoading && controller.addresses.isEmpty) {
      return const StoreAddressesSkeleton(itemCount: 3);
    }
    if (controller.addressesMessage != null && controller.addresses.isEmpty) {
      return StoreMessageState(
        kind: StoreMessageKind.error,
        message: controller.addressesMessage!,
        actionLabel: 'إعادة المحاولة'.tr,
        onAction: controller.loadAddresses,
      );
    }
    if (controller.addresses.isEmpty) {
      return StoreMessageState(
        kind: StoreMessageKind.empty,
        title: 'لا توجد عناوين محفوظة'.tr,
        message: 'أضف عنوان المنزل أو العمل لاستخدامه لاحقًا.'.tr,
        actionLabel: 'إضافة عنوان'.tr,
        onAction: () => _openEditor(context, controller),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadAddresses,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 96),
        itemCount: controller.addresses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 9),
        itemBuilder:
            (_, index) => _AddressCard(
              address: controller.addresses[index],
              onEdit:
                  () => _openEditor(
                    context,
                    controller,
                    current: controller.addresses[index],
                  ),
              onDefault:
                  () => controller.makeDefaultAddress(
                    controller.addresses[index],
                  ),
              onDelete:
                  () => _confirmDelete(
                    context,
                    controller,
                    controller.addresses[index],
                  ),
            ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    AccountControllerImp controller, {
    StoreAddress? current,
  }) async {
    await controller.prepareAddressOptions(current: current);
    if (!context.mounted) return;
    final label = TextEditingController(text: current?.label ?? 'المنزل'.tr);
    final street = TextEditingController(
      text: current?.streetAddress ?? controller.profile?.address ?? '',
    );
    final phone = TextEditingController(
      text: current?.phone ?? controller.profile?.phoneNumber ?? '',
    );
    final initialCityId = current?.shiplyCityId;
    Citys? selectedCity = controller.cities.firstWhereOrNull(
      (city) => city.id == initialCityId,
    );
    ShiplyVillage? selectedVillage = controller.addressVillages
        .firstWhereOrNull((village) => village.id == current?.shiplyVillageId);
    var isDefault = current?.isDefault ?? controller.addresses.isEmpty;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: StoreColors.resolve(context, StorePalette.surface),
      builder:
          (sheetContext) => StatefulBuilder(
            builder:
                (context, setSheetState) => Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    16,
                    14,
                    16,
                    MediaQuery.viewInsetsOf(context).bottom + 18,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: StoreColors.resolve(
                                context,
                                StorePalette.border,
                              ),
                              borderRadius: BorderRadius.circular(
                                StoreRadii.pill,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          current == null
                              ? 'إضافة عنوان جديد'.tr
                              : 'تعديل العنوان'.tr,
                          style: StoreColors.text(
                            context,
                            StoreTypography.title,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: label,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'اسم العنوان'.tr,
                            hintText: 'المنزل، العمل…'.tr,
                            prefixIcon: const Icon(
                              Icons.bookmark_border_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        StoreCityPicker(
                          cities: controller.cities,
                          value: selectedCity,
                          decoration: InputDecoration(
                            labelText: 'المدينة'.tr,
                            prefixIcon: const Icon(
                              Icons.location_city_outlined,
                            ),
                          ),
                          onChanged: (city) async {
                            setSheetState(() {
                              selectedCity = city;
                              selectedVillage = null;
                            });
                            await controller.loadAddressVillages(city.id);
                            if (sheetContext.mounted) setSheetState(() {});
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<ShiplyVillage>(
                          value:
                              controller.addressVillages.contains(
                                    selectedVillage,
                                  )
                                  ? selectedVillage
                                  : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'القرية أو منطقة التوصيل'.tr,
                            prefixIcon: const Icon(Icons.map_outlined),
                            suffixIcon:
                                controller.addressOptionsLoading
                                    ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                    : null,
                          ),
                          items: controller.addressVillages
                              .map(
                                (village) => DropdownMenuItem(
                                  value: village,
                                  child: Text(village.name),
                                ),
                              )
                              .toList(growable: false),
                          onChanged:
                              selectedCity == null
                                  ? null
                                  : (village) => setSheetState(
                                    () => selectedVillage = village,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: street,
                          minLines: 2,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'العنوان بالتفصيل'.tr,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف'.tr,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        CheckboxListTile(
                          value: isDefault,
                          contentPadding: EdgeInsets.zero,
                          title: Text('استخدامه كعنوان افتراضي'.tr),
                          onChanged:
                              (value) => setSheetState(
                                () => isDefault = value ?? false,
                              ),
                        ),
                        StoreButton(
                          label:
                              current == null
                                  ? 'حفظ العنوان'.tr
                                  : 'حفظ التعديلات'.tr,
                          onPressed: () async {
                            if (selectedCity == null ||
                                selectedVillage == null) {
                              showCustomSnackBar(
                                'حدد المدينة ومنطقة التوصيل.'.tr,
                                isError: true,
                              );
                              return;
                            }
                            final ok = await controller.saveAddress(
                              current: current,
                              label: label.text,
                              streetAddress: street.text,
                              city: selectedCity!,
                              village: selectedVillage!,
                              phone: phone.text,
                              isDefault: isDefault,
                            );
                            if (ok && sheetContext.mounted) {
                              Navigator.pop(sheetContext, true);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
    label.dispose();
    street.dispose();
    phone.dispose();
    if (saved == true && mounted) setState(() {});
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AccountControllerImp controller,
    StoreAddress address,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('حذف العنوان'.tr),
            content: Text(
              'storeDeleteAddressConfirm'.trParams({'label': address.label}),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text('إلغاء'.tr),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text('حذف'.tr),
              ),
            ],
          ),
    );
    if (accepted == true) await controller.deleteAddress(address);
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDefault,
    required this.onDelete,
  });

  final StoreAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: StoreColors.resolve(context, StorePalette.surface),
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      border: Border.all(
        color:
            address.isDefault
                ? StorePalette.purple
                : StoreColors.resolve(context, StorePalette.border),
      ),
      boxShadow: const [StoreElevation.lowShadow],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: StoreColors.resolve(context, StorePalette.background),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: StorePalette.purple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.label,
                      style: StoreColors.text(context, StoreTypography.label),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: StoreColors.resolve(
                          context,
                          StorePalette.derivedSuccessSurface,
                        ),
                        borderRadius: BorderRadius.circular(StoreRadii.pill),
                      ),
                      child: Text(
                        'افتراضي'.tr,
                        style: StoreColors.text(
                          context,
                          StoreTypography.caption,
                        ).copyWith(color: StorePalette.success, fontSize: 10),
                      ),
                    ),
                  if (!address.isDeliveryReady)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: StoreColors.resolve(
                          context,
                          StorePalette.derivedWarningSurface,
                        ),
                        borderRadius: BorderRadius.circular(StoreRadii.pill),
                      ),
                      child: Text(
                        'غير مكتمل للشحن'.tr,
                        style: StoreColors.text(
                          context,
                          StoreTypography.caption,
                        ).copyWith(color: StorePalette.warning, fontSize: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                address.streetAddress,
                style: StoreColors.text(context, StoreTypography.body),
              ),
              if (address.locationLabel.isNotEmpty)
                Text(
                  address.locationLabel,
                  style: StoreColors.text(context, StoreTypography.caption),
                ),
              if (address.phone?.trim().isNotEmpty == true)
                Text(
                  address.phone!,
                  style: StoreColors.text(context, StoreTypography.caption),
                ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: Text('تعديل'.tr),
                  ),
                  if (!address.isDefault)
                    TextButton.icon(
                      onPressed: onDefault,
                      icon: const Icon(Icons.check_circle_outline, size: 17),
                      label: Text('افتراضي'.tr),
                    ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 17),
                    label: Text('حذف'.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: StorePalette.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
