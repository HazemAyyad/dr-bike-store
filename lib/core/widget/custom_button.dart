// ignore_for_file: use_super_parameters

import 'package:get/get.dart';

import 'package:flutter/material.dart';

import '../constants/dimensions.dart';
import '../constants/styles.dart';

class CustomButton extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final String? buttonTextAdd;
  final String? image;
  final bool transparent;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final double? sizedBox;
  final double? widthImage;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;
  const CustomButton(
      {Key? key,
      this.onPressed,
      this.buttonTextAdd,
      required this.buttonText,
      this.transparent = false,
      this.margin,
      this.width,
      this.height,
      this.fontSize,
      this.radius = 10,
      this.icon,
      this.color,
      this.textColor,
      this.isLoading = false,
      this.isBold = true,
      this.image,
      this.widthImage,
      this.sizedBox})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      foregroundColor: Theme.of(context).primaryColor,
      backgroundColor: color ?? Theme.of(context).primaryColor,
      minimumSize: Size(width != null ? width! : Dimensions.webMaxWidth,
          height != null ? height! : 50),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Center(
        child: SizedBox(
            width: width ?? Dimensions.webMaxWidth,
            child: Padding(
              padding: margin == null ? const EdgeInsets.all(0) : margin!,
              child: TextButton(
                onPressed: isLoading ? null : onPressed as void Function()?,
                style: flatButtonStyle,
                child: isLoading
                    ? Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              Text('loading'.tr,
                                  style: robotoMedium.copyWith(
                                      color: Colors.white)),
                            ]),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            icon != null
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeDefault),
                                    child: Icon(icon,
                                        size: widthImage,
                                        color: transparent
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).cardColor),
                                  )
                                : const SizedBox(),
                            image != null
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeDefault),
                                    child: Image.asset(
                                      image!,
                                      color: transparent
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).cardColor,
                                      width: widthImage,
                                    ),
                                  )
                                : const SizedBox(),
                            sizedBox != null
                                ? SizedBox(
                                    width: sizedBox,
                                  )
                                : const SizedBox(),
                            Text(buttonText,
                                textAlign: TextAlign.center,
                                style: isBold
                                    ? robotoBold.copyWith(
                                        color: textColor ??
                                            (transparent
                                                ? Theme.of(context).primaryColor
                                                : Colors.white),
                                        fontSize: fontSize ??
                                            Dimensions.fontSizeLarge,
                                      )
                                    : robotoRegular.copyWith(
                                        color: textColor ??
                                            (transparent
                                                ? Theme.of(context).primaryColor
                                                : Colors.white),
                                        fontSize: fontSize ??
                                            Dimensions.fontSizeLarge,
                                      )),
                          ]),
              ),
            )));
  }
}
