// ignore_for_file: prefer_final_fields, unused_field
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/categores/categores_controller.dart';
import 'category_screen.dart';
import 'filter_screen.dart';

class CategoreyPage extends StatefulWidget {
  const CategoreyPage({super.key});
  @override
  State<CategoreyPage> createState() => _CategoreyPageState();
}

class _CategoreyPageState extends State<CategoreyPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoresControllerImp>(
      builder: (categoresControllerImp) {
        return RefreshIndicator(
          onRefresh:
              () => categoresControllerImp.getAllCategores(
                categoresControllerImp.mainCategoresId,
              ),
          child: Center(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: categoresControllerImp.tabViewController,
              children: [CategoryScreen(), FilterPage()],
            ),
          ),
        );
      },
    );
  }
}
