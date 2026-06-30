// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/shop/shop_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/styles.dart';
import '../../core/model/city_model.dart';
import '../../core/widget/dialog.dart';
import 'widget/bill_details.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  static const Color _surface = Color(0xFFF7F8FA);
  static const Color _card = Colors.white;
  static const Color _border = Color(0xFFE6E8EE);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _text = Color(0xFF111827);

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  late final FocusNode _nameFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _phone2Focus;
  late final FocusNode _addressFocus;
  late final FocusNode _discountFocus;

  @override
  void initState() {
    super.initState();
    _nameFocus = FocusNode(debugLabel: 'checkout_name');
    _phoneFocus = FocusNode(debugLabel: 'checkout_phone');
    _phone2Focus = FocusNode(debugLabel: 'checkout_phone2');
    _addressFocus = FocusNode(debugLabel: 'checkout_address');
    _discountFocus = FocusNode(debugLabel: 'checkout_discount');
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _phone2Focus.dispose();
    _addressFocus.dispose();
    _discountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(
      builder: (controller) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: CheckOutScreen._surface,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: CheckOutScreen._surface,
            centerTitle: true,
            leading: IconButton(
              tooltip: "Back".tr,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.hoverColor,
              ),
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Get.back();
              },
            ),
            title: Text(
              "Payment".tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: theme.hoverColor,
              ),
            ),
          ),
          body: Form(
            key: controller.formstate,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 110.h),
              children: [
                _SectionCard(
                  title: "Personal Details".tr,
                  child: Column(
                    children: [
                      _AppField(
                        label: "Full name".tr,
                        controller: controller.nameController,
                        focusNode: _nameFocus,
                        nextFocusNode: _phoneFocus,
                        textInputAction: TextInputAction.next,
                        requiredMessage: "nameRequired".tr,
                      ),
                      SizedBox(height: 10.h),
                      _AppField(
                        label: "Mobile number".tr,
                        controller: controller.phoneNumberController,
                        focusNode: _phoneFocus,
                        nextFocusNode: _phone2Focus,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        requiredMessage: "phoneRequired".tr,
                      ),
                      SizedBox(height: 10.h),
                      _AppField(
                        label: "Alternative mobile number".tr,
                        controller: controller.phoneNumber2Controller,
                        focusNode: _phone2Focus,
                        nextFocusNode: _addressFocus,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        requiredMessage: null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                _SectionCard(
                  title: "Delivery".tr,
                  child: Column(
                    children: [
                      _LabeledSelector(
                        label: "City".tr,
                        requiredMark: true,
                        child: _buildCitySelector(controller),
                      ),
                      SizedBox(height: 10.h),
                      _LabeledSelector(
                        label: "Village".tr,
                        requiredMark: true,
                        child: _buildVillageSelector(controller),
                      ),
                      if (controller.isDeliveryLoading) ...[
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.primaryColor,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "${"Delivery price".tr}...",
                                style: robotoBold.copyWith(
                                  color: theme.primaryColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (controller.selectedVillageId != null) ...[
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "${"Delivery price".tr}: ${controller.selectedCityPrice}₪",
                            style: robotoBold.copyWith(
                              color: theme.primaryColor,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 10.h),
                      _AppField(
                        label: "address".tr,
                        controller: controller.addressController,
                        focusNode: _addressFocus,
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.done,
                        maxLines: 3,
                        requiredMessage: "addressRequired".tr,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                _SectionCard(
                  title: "Discount code".tr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _AppField(
                          label: "Discount code".tr,
                          controller: controller.discountCodeController,
                          focusNode: _discountFocus,
                          requiredMessage: null,
                          showLabel: false,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        height: 48.h,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.hoverColor,
                            foregroundColor: theme.scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          onPressed:
                              controller.isLoading
                                  ? null
                                  : () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    await controller.checkCode();
                                  },
                          child:
                              controller.isLoading
                                  ? SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text("check".tr),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                _SectionCard(
                  title: "Invoice details".tr,
                  trailing: IconButton(
                    tooltip: "Invoice details".tr,
                    visualDensity: VisualDensity.compact,
                    color: theme.primaryColor,
                    onPressed: () => _showInvoice(context),
                    icon: const Icon(Icons.receipt_long_rounded, size: 22),
                  ),
                  child: _TotalsPreview(controller: controller),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
              decoration: BoxDecoration(
                color: CheckOutScreen._card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(52.h),
                  backgroundColor: theme.hoverColor,
                  foregroundColor: theme.scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (controller.formstate.currentState!.validate()) {
                    if (controller.discountCodeController.text
                        .trim()
                        .isNotEmpty) {
                      await controller.checkCode();
                      if (controller.couponModel?.isActive == true) {
                        await controller.createOrderWithCode();
                      }
                    } else {
                      await controller.createOrder();
                    }
                  }
                },
                child: Text(
                  "Confirm the order".tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void _showInvoice(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.grey.withOpacity(0.5),
      builder: (context) {
        return DefaultDialog(
          radius: 10.r,
          paddingHorizontal: 0,
          paddingVerrtical: 10,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          Child: const BillDetails(),
        );
      },
    );
  }

  Widget _buildCitySelector(ShopController shopController) {
    bool isAr =
        shopController.localizationController.locale.languageCode == 'ar';
    bool isEng =
        shopController.localizationController.locale.languageCode == 'en';
    return _SearchableSelector<Citys>(
      hint: "City".tr,
      value: shopController.selectedCity,
      items: shopController.cities,
      itemLabel:
          (city) =>
              isAr
                  ? city.cityNameAr
                  : isEng
                  ? city.cityNameEng
                  : city.cityNameAbree,
      onSelected: (city) async => shopController.onCitySelected(city),
    );
  }

  Widget _buildVillageSelector(ShopController shopController) {
    return _SearchableSelector<ShiplyVillage>(
      hint: "Village".tr,
      value: shopController.selectedVillage,
      items: shopController.villages,
      enabled:
          shopController.selectedCityId != null &&
          !shopController.isVillagesLoading,
      loading: shopController.isVillagesLoading,
      itemLabel: (village) => village.name,
      onSelected: (village) async => shopController.onVillageSelected(village),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: CheckOutScreen._card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: CheckOutScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: CheckOutScreen._text,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _TotalsPreview extends StatelessWidget {
  final ShopController controller;

  const _TotalsPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final total = controller.totalPrice + controller.selectedCityPrice;
    return Row(
      children: [
        Expanded(
          child: _MiniTotal(
            label: "Delivery price".tr,
            value: "${controller.selectedCityPrice}₪",
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(child: _MiniTotal(label: "Total".tr, value: "$total₪")),
      ],
    );
  }
}

class _MiniTotal extends StatelessWidget {
  final String label;
  final String value;

  const _MiniTotal({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: CheckOutScreen._surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(
              color: CheckOutScreen._muted,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(
              color: CheckOutScreen._text,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledSelector extends StatelessWidget {
  final String label;
  final bool requiredMark;
  final Widget child;

  const _LabeledSelector({
    required this.label,
    required this.child,
    this.requiredMark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, requiredMark: requiredMark),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}

class _AppField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final String? requiredMessage;
  final bool showLabel;

  const _AppField({
    required this.label,
    required this.controller,
    this.focusNode,
    this.nextFocusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.requiredMessage,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          _FieldLabel(label: label, requiredMark: requiredMessage != null),
          SizedBox(height: 6.h),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          stylusHandwritingEnabled: false,
          enableIMEPersonalizedLearning: false,
          autocorrect: false,
          enableSuggestions: false,
          cursorColor: Theme.of(context).primaryColor,
          onEditingComplete: () {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          style: robotoRegular.copyWith(
            color: CheckOutScreen._text,
            fontSize: Dimensions.fontSizeDefault,
          ),
          validator: (value) {
            if (requiredMessage == null) return null;
            return value == null || value.trim().isEmpty
                ? requiredMessage
                : null;
          },
          decoration: InputDecoration(
            hintText: label,
            hintStyle: robotoRegular.copyWith(
              color: CheckOutScreen._muted,
              fontSize: Dimensions.fontSizeDefault,
            ),
            filled: true,
            fillColor: CheckOutScreen._surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: maxLines > 1 ? 12.h : 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: CheckOutScreen._border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: CheckOutScreen._border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.3,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool requiredMark;

  const _FieldLabel({required this.label, this.requiredMark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: CheckOutScreen._muted,
            ),
          ),
        ),
        if (requiredMark)
          const Text(" *", style: TextStyle(color: Colors.redAccent)),
      ],
    );
  }
}

class _SearchableSelector<T> extends StatelessWidget {
  final String hint;
  final String? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final Future<void> Function(T item) onSelected;
  final bool enabled;
  final bool loading;

  const _SearchableSelector({
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: enabled ? () => _openSheet(context) : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: CheckOutScreen._surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: CheckOutScreen._border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color:
                      hasValue ? CheckOutScreen._text : CheckOutScreen._muted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (loading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? CheckOutScreen._muted : CheckOutScreen._border,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final selected = await Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (_) => _SearchableSelectorPage<T>(
              hint: hint,
              value: value,
              items: items,
              itemLabel: itemLabel,
            ),
      ),
    );

    if (selected != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await onSelected(selected);
    }
  }
}

class _SearchableSelectorPage<T> extends StatefulWidget {
  final String hint;
  final String? value;
  final List<T> items;
  final String Function(T item) itemLabel;

  const _SearchableSelectorPage({
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
  });

  @override
  State<_SearchableSelectorPage<T>> createState() =>
      _SearchableSelectorPageState<T>();
}

class _SearchableSelectorPageState<T>
    extends State<_SearchableSelectorPage<T>> {
  late final TextEditingController _searchController;
  late List<T> _filteredItems;
  Timer? _filterDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = List<T>.from(widget.items);
  }

  @override
  void dispose() {
    _filterDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      final needle = query.trim().toLowerCase();
      setState(() {
        _filteredItems =
            needle.isEmpty
                ? List<T>.from(widget.items)
                : widget.items
                    .where(
                      (item) =>
                          widget.itemLabel(item).toLowerCase().contains(needle),
                    )
                    .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CheckOutScreen._surface,
      appBar: AppBar(
        backgroundColor: CheckOutScreen._surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.hint,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: CheckOutScreen._text,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: CheckOutScreen._text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                autofocus: false,
                stylusHandwritingEnabled: false,
                enableIMEPersonalizedLearning: false,
                autocorrect: false,
                enableSuggestions: false,
                style: robotoRegular.copyWith(color: CheckOutScreen._text),
                decoration: InputDecoration(
                  hintText: "search".tr,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: CheckOutScreen._muted,
                  ),
                  filled: true,
                  fillColor: CheckOutScreen._card,
                  hintStyle: robotoRegular.copyWith(
                    color: CheckOutScreen._muted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: CheckOutScreen._border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: CheckOutScreen._border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: CheckOutScreen._text),
                  ),
                ),
                onChanged: _filter,
              ),
              SizedBox(height: 12.h),
              Expanded(
                child:
                    _filteredItems.isEmpty
                        ? Center(
                          child: Text(
                            "No data".tr,
                            style: robotoRegular.copyWith(
                              color: CheckOutScreen._muted,
                            ),
                          ),
                        )
                        : ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: _filteredItems.length,
                          separatorBuilder:
                              (_, __) => const Divider(
                                height: 1,
                                color: CheckOutScreen._border,
                              ),
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final label = widget.itemLabel(item);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                label,
                                style: robotoRegular.copyWith(
                                  color: CheckOutScreen._text,
                                ),
                              ),
                              trailing:
                                  label == widget.value
                                      ? Icon(
                                        Icons.check_circle,
                                        color: Theme.of(context).primaryColor,
                                      )
                                      : null,
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
