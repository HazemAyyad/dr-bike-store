import 'package:doctor_bike/core/constants/dimensions.dart';
import 'package:doctor_bike/core/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../controller/product/product_controller.dart';

class PlusAndMins extends StatelessWidget {
  PlusAndMins({
    super.key,
    required this.controllerScreen,
    this.selectedIndexColors,
    this.selectedIndexSize,
    required this.countController,
  });
  ProductControllerImp controllerScreen;
  int? selectedIndexColors;
  int? selectedIndexSize;
  TextEditingController countController;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            int maxStock =
                (controllerScreen.itemView!.itemSizes.isNotEmpty &&
                        selectedIndexColors != null &&
                        selectedIndexSize != null)
                    ? controllerScreen.itemView!.itemSizeColorsStock!
                    : controllerScreen.itemView!.stock;
            if (controllerScreen.itemView!.count < maxStock) {
              controllerScreen.itemView!.count++;
              countController.text =
                  controllerScreen.itemView!.count.toString();

              controllerScreen.shopController.saveCart();
              controllerScreen.update();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
            ),
            margin: const EdgeInsets.all(2),
            child: Icon(Icons.add, size: 22.w),
          ),
        ),
        SizedBox(
          width: 40.w,
          child: TextFormField(
            controller: countController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).primaryColor,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              int? newCount = int.tryParse(value);
              if (newCount != null && newCount > 1) {
                int maxStock =
                    (controllerScreen.itemView!.itemSizes.isNotEmpty &&
                            selectedIndexColors != null &&
                            selectedIndexSize != null)
                        ? controllerScreen.itemView!.itemSizeColorsStock!
                        : controllerScreen.itemView!.stock;
                if (newCount <= maxStock) {
                  controllerScreen.itemView!.count = newCount;

                  controllerScreen.shopController.saveCart();
                  controllerScreen.update();
                } else {
                  countController.text =
                      controllerScreen.itemView!.count.toString();
                  controllerScreen.update();
                }
              }
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            if (controllerScreen.itemView!.count > 1) {
              controllerScreen.itemView!.count--;
              countController.text =
                  controllerScreen.itemView!.count.toString();

              controllerScreen.shopController.saveCart();
              controllerScreen.update();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
            ),
            margin: const EdgeInsets.all(2),
            child: Icon(Icons.remove, size: 22.w),
          ),
        ),
      ],
    );
  }
}
