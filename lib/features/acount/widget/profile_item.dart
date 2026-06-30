// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/functions/theme_services.dart';
import '../../../core/theme/light.dart';

class ProfileItem extends StatefulWidget {
  final String icon;
  final String title;
  final bool hasSwitch;
  final void Function()? onTap;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.hasSwitch = false,
  });

  @override
  State<ProfileItem> createState() => _ProfileItemState();
}

class _ProfileItemState extends State<ProfileItem> {
  @override
  Widget build(BuildContext context) {
    bool darkMode = false;
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Icon(widget.icon, size: 24),
            SvgPicture.asset(
              widget.icon,
              width: 24.w,
              height: 24.h,
              color:
                  ThemeServices().loadThemeFromBox()
                      ? Colors.white
                      : Theme.of(context).hoverColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            if (widget.hasSwitch)
              Switch(
                value: darkMode,
                onChanged: (val) {
                  setState(() {});
                  darkMode = val;
                  Get.isDarkMode
                      ? Get.changeTheme(light())
                      : Get.changeTheme(dark());
                },
              ),
          ],
        ),
      ),
    );
  }
}
