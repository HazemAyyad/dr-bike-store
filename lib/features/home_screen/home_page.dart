// ignore_for_file: prefer_final_fields, unused_field, deprecated_member_use

import 'package:doctor_bike/core/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controller/home/home_controller.dart';
import '../../core/constants/images.dart';
import '../../core/functions/app_usage_service.dart';
import '../../repository/home/home_repository.dart';
import '../acount/profile_screen.dart';
import '../shop/shop_car_screen.dart';
import 'home_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeControllerImp homeControllerImp = Get.put(
    HomeControllerImp(
      homeRepository: HomeRepository(
        apiClient: ApiClient(sharedPreferences: Get.find()),
      ),
    ),
  );
  int selectedIndex = 0;
  static List<Widget> _widgetOption = [
    const HomeScreen(),
    const ShopCarScreen(),
    ProfileScreen(),
  ];
  loading() async {
    if (await AppUsageService.getToken() != null) {
      await homeControllerImp.getNotifications();
    }
    await homeControllerImp.getOnlineAds();
    await homeControllerImp.getAllItemIsMoreSales();
    await homeControllerImp.getMainCategores();
  }

  @override
  void initState() {
    loading();
    super.initState();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      if (index == 0) {
        loading();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(child: _widgetOption.elementAt(selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).hoverColor,
        unselectedItemColor: const Color(0xff7f7f7f),
        onTap: onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Images.iconHomeSvg,
              width: 29.w,
              color:
                  selectedIndex == 0
                      ? Theme.of(context).hoverColor
                      : const Color(0xff7f7f7f),
            ),
            label: "Home".tr,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Images.shopCarSvg,
              width: 29.w,
              color:
                  selectedIndex == 1
                      ? Theme.of(context).hoverColor
                      : const Color(0xff7f7f7f),
            ),
            label: "cart".tr,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Images.iconProfileSvg,
              width: 29.w,
              color:
                  selectedIndex == 2
                      ? Theme.of(context).hoverColor
                      : const Color(0xff7f7f7f),
            ),
            label: "Profile".tr,
          ),
        ],
      ),
    );
  }
}
