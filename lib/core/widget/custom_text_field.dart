// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable, deprecated_member_use
// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/dimensions.dart';
import '../constants/styles.dart';

class CustomTextField extends StatefulWidget {
  final String titleText;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final bool isChange;
  final Function? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final Function? onSubmit;
  final void Function()? onPressedChange;
  bool isEnabled;
  final int maxLines;
  final double? height;
  final double? width;
  final Color? colorFill;
  final Color? colorBorder;
  final TextCapitalization capitalization;
  final String? prefixImage;
  final Color? prefixImagecolor;
  final Widget? prefixIcon;
  final IconData? suffixIcon;
  final double prefixSize;
  final TextAlign textAlign;
  final bool isAmount;
  final bool isNumber;
  final bool showTitle;
  final bool showBorder;
  final double iconSize;
  final bool isPhone;
  final String? countryDialCode;
  final double? fontSize;
  final double? borderRadius;
  // final Function(CountryCode countryCode)? onCountryChanged;
  final Function()? function;
  final bool? readOnly;
  final void Function()? onTap;
  final bool isRequired;

  CustomTextField({
    super.key,
    // this.onCountryChanged,
    this.titleText = 'Write something...',
    required this.hintText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.isPassword = false,
    this.isChange = false,
    this.onChanged,
    this.contentPadding,
    this.onSubmit,
    this.onPressedChange,
    this.isEnabled = false,
    this.maxLines = 1,
    this.height,
    this.width,
    this.colorFill,
    this.colorBorder,
    this.capitalization = TextCapitalization.none,
    this.prefixImage,
    this.prefixImagecolor,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixSize = Dimensions.paddingSizeSmall,
    this.textAlign = TextAlign.start,
    this.isAmount = false,
    this.isNumber = false,
    this.showTitle = false,
    this.showBorder = true,
    this.iconSize = 18,
    this.isPhone = false,
    this.countryDialCode,
    this.fontSize,
    this.borderRadius,
    this.function,
    this.readOnly,
    this.onTap,
    this.isRequired = true,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _change = true;
  String? errorMessage(String str) {
    if (widget.hintText == "serialNumberHint".tr) {
      return "serialNumberRequired".tr;
    } else if (widget.hintText == "password".tr) {
      return "passwordRequired".tr;
    } else if (widget.hintText == "ConfirmPassword".tr) {
      return "passwordRequired".tr;
    } else if (widget.hintText == "name".tr) {
      return "nameRequired".tr;
    } else if (widget.hintText == "phone".tr ||
        widget.hintText == "phoneNumber".tr ||
        widget.hintText == '+970 2458712556') {
      return "phoneRequired".tr;
    } else if (widget.hintText == "address".tr ||
        widget.hintText == "Enter the address in detail.".tr) {
      return "addressRequired".tr;
    } else if (widget.hintText == "trade_name".tr) {
      return "commercial_registerRequired".tr;
    } else if (widget.hintText == "tax_number".tr) {
      return "Tax_registerRequired".tr;
    } else if (widget.hintText == "region".tr) {
      return "regionRequired".tr;
    } else if (widget.hintText == "current_user".tr) {
      return "Enter_name".tr;
    } else if (widget.hintText == "20-3-2023".tr) {
      return "Enter_date".tr;
    } else if (widget.hintText == "email".tr) {
      return "emailRequired".tr;
    } else if (widget.hintText == "title_message".tr) {
      return "title_messageRequired".tr;
    } else if (widget.hintText == "message".tr) {
      return "messageRequired".tr;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showTitle
            ? Text(
              widget.titleText,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            )
            : const SizedBox(),
        SizedBox(
          height: widget.showTitle ? Dimensions.paddingSizeExtraSmall : 0,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? Dimensions.paddingSizeSmall,
            ),
            border: Border.all(
              style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
              width: 1,
              color:
                  widget.isChange
                      ? const Color(0xff878787)
                      : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                // height: widget.height ?? 50,
                width:
                    widget.isChange
                        ? MediaQuery.of(context).size.width * 0.7
                        : widget.width ??
                            MediaQuery.of(context).size.width * 0.88,
                child: TextFormField(
                  validator: (value) {
                    if (!widget.isRequired) {
                      return null;
                    }

                    if (value!.isEmpty) {
                      return errorMessage(widget.hintText);
                    }

                    if (widget.titleText == "password".tr && value.length < 8) {
                      return 'Password must be at least 8 characters'.tr;
                    } else if (widget.hintText == "ConfirmPassword".tr &&
                        value.trim().length < 8) {}
                    if ((widget.titleText == "password".tr ||
                            widget.hintText == "ConfirmPassword".tr) &&
                        value.trim().length >= 8) {
                      String pattern =
                          r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return 'Password must contain letters, numbers, and a special character'
                            .tr;
                      }
                    }

                    if (widget.hintText == "email".tr) {
                      if (!GetUtils.isEmail(value)) {
                        return "invalidEmail".tr;
                      }
                    }

                    return null;
                  },
                  readOnly: widget.readOnly ?? false,
                  onTap: widget.onTap,
                  maxLines: widget.maxLines,
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  textAlign: widget.textAlign,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).hintColor,
                  ),
                  textInputAction: widget.inputAction,
                  keyboardType:
                      widget.isAmount ? TextInputType.number : widget.inputType,
                  cursorColor: Theme.of(context).primaryColor,
                  textCapitalization: widget.capitalization,
                  enabled: _change,
                  autofocus: false,
                  obscureText: widget.isPassword ? _obscureText : false,
                  inputFormatters:
                      widget.inputType == TextInputType.phone
                          ? <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                          ]
                          : widget.isAmount
                          ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))]
                          : widget.isNumber
                          ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))]
                          : null,
                  decoration: InputDecoration(
                    contentPadding: widget.contentPadding,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? Dimensions.paddingSizeSmall,
                      ),
                      borderSide: BorderSide(
                        style:
                            widget.showBorder
                                ? BorderStyle.solid
                                : BorderStyle.none,
                        width: 1,
                        color:
                            widget.isChange
                                ? Colors.transparent
                                : widget.colorBorder ?? const Color(0xff878787),
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? Dimensions.paddingSizeSmall,
                      ),
                      borderSide: BorderSide(
                        style:
                            widget.showBorder
                                ? BorderStyle.solid
                                : BorderStyle.none,
                        width: 1,
                        color:
                            widget.isChange
                                ? Colors.transparent
                                : const Color(0xff878787),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? Dimensions.paddingSizeSmall,
                      ),
                      borderSide: BorderSide(
                        style:
                            widget.showBorder
                                ? BorderStyle.solid
                                : BorderStyle.none,
                        width: 1.5,
                        color:
                            widget.isChange
                                ? Colors.transparent
                                : Theme.of(context).primaryColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.paddingSizeSmall,
                      ),
                      borderSide: BorderSide(
                        style:
                            widget.showBorder
                                ? BorderStyle.solid
                                : BorderStyle.none,
                        width: 1,
                        color:
                            widget.isChange
                                ? Colors.transparent
                                : Theme.of(context).primaryColor,
                      ),
                    ),
                    isDense: true,
                    hintText: widget.hintText,
                    fillColor: widget.colorFill ?? Theme.of(context).cardColor,
                    hintStyle: robotoRegular.copyWith(
                      fontSize: widget.fontSize ?? Dimensions.fontSizeLarge,
                      color: Theme.of(context).hintColor,
                    ),
                    filled: true,
                    prefixIcon:
                        widget.isPhone
                            ? SizedBox(
                              width: 95,
                              child: Row(
                                children: [
                                  Container(
                                    width: 85,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        bottomLeft: Radius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                      ),
                                    ),
                                    margin: const EdgeInsets.only(right: 0),
                                    padding: const EdgeInsets.only(left: 5),
                                    child: const Center(
                                      // child: CodePickerWidget(
                                      //   boxDecoration: BoxDecoration(color: Theme.of(context).cardColor),
                                      //   flagWidth: 25,
                                      //   padding: EdgeInsets.zero,
                                      //   onChanged: widget.onCountryChanged,
                                      //   initialSelection: widget.countryDialCode,
                                      //   favorite: [widget.countryDialCode!],
                                      //   textStyle: robotoRegular.copyWith(
                                      //     fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyMedium!.color,
                                      //   ),
                                      // ),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 2,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ],
                              ),
                            )
                            : widget.prefixImage != null &&
                                widget.prefixIcon == null
                            ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.prefixSize,
                              ),
                              child: Image.asset(
                                widget.prefixImage!,
                                height: 20,
                                width: 20,
                                color: widget.prefixImagecolor,
                              ),
                            )
                            : widget.prefixImage == null &&
                                widget.prefixIcon != null
                            ? widget.prefixIcon
                            : null,
                    suffixIcon:
                        widget.isPassword
                            ? IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Theme.of(
                                  context,
                                ).hintColor.withOpacity(0.3),
                              ),
                              onPressed: widget.function ?? _toggle,
                            )
                            : (widget.suffixIcon != null)
                            ? Icon(
                              widget.suffixIcon,
                              color: Theme.of(context).primaryColor,
                            )
                            : null,
                  ),
                  onChanged: widget.onChanged as void Function(String)?,
                ),
              ),
              widget.isChange
                  ? TextButton(
                    onPressed: _toggleChange,
                    child: Text("change".tr),
                  )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleChange() {
    setState(() {
      _change = !_change;
    });
  }
}
