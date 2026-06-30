// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/dimensions.dart';
import '../constants/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final bool? titleCentre;
  final Function? onBackPressed;
  final bool showCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  final double? elevation;
  const CustomAppBar(
      {Key? key,
      required this.title,
      this.backButton = true,
      this.onBackPressed,
      this.showCart = false,
      this.leadingIcon,
      this.onVegFilterTap,
      this.type,
      this.titleCentre,
      this.elevation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: titleCentre ?? true,
      leading: backButton
          ? IconButton(
              icon: leadingIcon != null
                  ? Image.asset(leadingIcon!, height: 22, width: 22)
                  : const Icon(Icons.arrow_back),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () => onBackPressed != null
                  ? onBackPressed!()
                  : Navigator.pop(context),
            )
          : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      elevation: elevation ?? 0,
      // actions: showCart || onVegFilterTap != null ? [
      //   showCart ? IconButton(
      //     onPressed: () {},
      //     icon: ,
      //   ) : const SizedBox(),
      //
      //   // onVegFilterTap != null ? VegFilterWidget(
      //   //   type: type,
      //   //   onSelected: onVegFilterTap,
      //   //   fromAppBar: true,
      //   // ) : const SizedBox(),
      //
      // ] : [const SizedBox()],
    );
  }

  @override
  Size get preferredSize => Size(Get.width, GetPlatform.isDesktop ? 100 : 50);
}
