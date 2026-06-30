// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controller/categores/categores_controller.dart';
// import '../../../repository/categories/categories_repository.dart';

// class CategoryFilter extends StatefulWidget {
//   const CategoryFilter({super.key});

//   @override
//   State<CategoryFilter> createState() => _CategoryFilterState();
// }

// class _CategoryFilterState extends State<CategoryFilter> {
//   @override
//   Widget build(BuildContext context) {
//     final CategoresControllerImp controller = Get.put(
//       CategoresControllerImp(
//         categoriesRepository: CategoriesRepository(apiClient: Get.find()),
//       ),
//     );
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return CircularProgressIndicator();
//           }
//           return Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       controller.selectedIndex2 = 0.obs;
//                       // controller.filterProductsBySubgroup(
//                       //   0,
//                       //   controller.allProducts.obs,
//                       // );
//                     });

//                     controller.update();
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color:
//                           controller.selectedIndex2 == 0.obs
//                               ? Theme.of(context).primaryColor
//                               : Colors.transparent,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Theme.of(context).primaryColor),
//                     ),
//                     child: Text(
//                       "all".tr,
//                       style: TextStyle(
//                         color:
//                             controller.selectedIndex2 == 0.obs
//                                 ? Colors.white
//                                 : Theme.of(context).primaryColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Row(
//                 children: List.generate(controller.supCategores.length ?? 0, (
//                   index,
//                 ) {
//                   bool isSelected =
//                       controller.selectedIndex2 == (index + 1).obs;
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 8.0),
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           controller.selectedIndex2 = (index + 1).obs;
//                           // controller.filterProductsBySubgroup(
//                           //   controller.supCategores!.rows[index].id,
//                           //   controller.allProducts.obs,
//                           // );
//                         });
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color:
//                               isSelected
//                                   ? Theme.of(context).primaryColor
//                                   : Colors.transparent,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         child: Text(
//                           controller
//                                       .localizationController
//                                       .locale
//                                       .languageCode ==
//                                   'ar'
//                               ? "${controller.supCategores[index].nameAr}"
//                               : controller
//                                       .localizationController
//                                       .locale
//                                       .languageCode ==
//                                   'en'
//                               ? "${controller.supCategores[index].nameEng}"
//                               : "${controller.supCategores[index].nameAbree}",

//                           style: TextStyle(
//                             color:
//                                 isSelected
//                                     ? Colors.white
//                                     : Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
