import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/account/account_controller.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/styles.dart';
import '../../core/functions/theme_services.dart';
import '../../core/widget/custom_button.dart';
import '../../core/widget/custom_text_field.dart';
import '../../core/widget/drop_down_list.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<AccountControllerImp>()) return;
      final controller = Get.find<AccountControllerImp>();
      if (controller.userModel == null ||
          controller.emailController.text.isEmpty) {
        controller.getUserById(navigate: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountControllerImp>(
      builder: (accountControllerImp) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Personal Details'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge2,
                color: Theme.of(context).hoverColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Form(
            key: accountControllerImp.formstate,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      "name".tr,
                      "userName",
                      context,
                      controller: accountControllerImp.nameController,
                    ),
                    _buildTextField(
                      "email".tr,
                      "abdullahmohamed@mail.com",
                      context,
                      controller: accountControllerImp.emailController,
                    ),
                    _buildTextField(
                      "Mobile number".tr,
                      "010104246765565",
                      context,
                      // prefixIcon: "+966",
                      controller: accountControllerImp.phoneNumberController,
                    ),
                    _buildTextField(
                      "Alternative mobile number".tr,
                      "010104246765565",
                      context,
                      // prefixIcon: "+966",
                      controller: accountControllerImp.phoneNumber2Controller,
                    ),
                    _buildDropdown("City".tr, accountControllerImp, context),
                    // _buildDropdown(
                    //   "City".tr,
                    //   context,
                    //   accountControllerImp,
                    //   accountControllerImp.cities,
                    //   accountControllerImp.localizationController,
                    // ),
                    _buildTextArea(
                      "address",
                      "Enter the address in detail..",
                      context,
                      controller: accountControllerImp.addressController,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      buttonText: "save".tr,
                      fontSize: Dimensions.fontSizeExtraLarge2,
                      color:
                          ThemeServices().loadThemeFromBox()
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hoverColor,
                      radius: 11.r,
                      textColor: Theme.of(context).scaffoldBackgroundColor,
                      onPressed: () {
                        if (accountControllerImp.formstate.currentState!
                            .validate()) {
                          accountControllerImp.editeUser();
                        }
                      },
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    BuildContext context, {
    String? prefixIcon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          child: CustomTextField(
            inputType:
                label == "Mobile number".tr ||
                        label == "Alternative mobile number".tr
                    ? TextInputType.phone
                    : TextInputType.text,
            controller: controller,
            prefixIcon:
                prefixIcon == null
                    ? null
                    : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        prefixIcon,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
            hintText: hint,
            colorBorder: const Color(0xffD4D4D4),
            height: 50.h,
            borderRadius: 9.r,
            fontSize: 14.sp,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    AccountControllerImp accountControllerImp,
    BuildContext context,
  ) {
    bool isAr =
        accountControllerImp.localizationController.locale.languageCode == 'ar';
    bool isEng =
        accountControllerImp.localizationController.locale.languageCode == 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 5),
        DefaultDropdown(
          value: accountControllerImp.selectedCity,
          items:
              accountControllerImp.cities.map<DropdownMenuItem<String>>((city) {
                return DropdownMenuItem<String>(
                  value:
                      isAr
                          ? city.cityNameAr.toString()
                          : isEng
                          ? city.cityNameEng.toString()
                          : city.cityNameAbree.toString(),
                  child: Text(
                    isAr
                        ? city.cityNameAr.toString()
                        : isEng
                        ? city.cityNameEng.toString()
                        : city.cityNameAbree.toString(),
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                );
              }).toList(),

          onChanged: (value) {
            accountControllerImp.selectedCity = value.toString();
            for (var city in accountControllerImp.cities) {
              if (city.cityNameAr == accountControllerImp.selectedCity ||
                  city.cityNameEng == accountControllerImp.selectedCity ||
                  city.cityNameAbree == accountControllerImp.selectedCity) {
                accountControllerImp.selectedCityId = city.id.toString();
                break;
              }
            }

            accountControllerImp.update();
          },
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTextArea(
    String label,
    String hint,
    BuildContext context, {
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 5),
        CustomTextField(
          controller: controller,
          hintText: hint,
          colorBorder: const Color(0xffeeeeee),
          height: 110.h,
          borderRadius: 9.r,
          fontSize: 14.sp,

          maxLines: 4,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
