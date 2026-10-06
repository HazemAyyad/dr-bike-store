import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/order/order_controller.dart';
import '../../core/model/orders_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_media.dart';
import 'widget/order_actions.dart';
import 'widget/order_tracking_timeline.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<OrderController>(
    builder: (controller) {
      final argument = Get.arguments;
      final order =
          controller.selectedOrder ?? (argument is Order ? argument : null);
      if (order == null) {
        return const Scaffold(body: Center(child: Text('الطلب غير متاح.')));
      }
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: StorePalette.background,
          appBar: AppBar(
            title: Text(
              'طلب #${order.orderNumber}',
              style: StoreTypography.title,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(StoreSpacing.md),
            children: [
              _section('ملخص الطلب', [
                _row(
                  'الحالة',
                  order.rawStatus.isEmpty ? 'غير معروفة' : order.rawStatus,
                ),
                _row('التاريخ', order.dateAdd),
              ]),
              _section('المنتجات', order.details.map(_line).toList()),
              _section('القيم التاريخية', [
                _money('قبل الخصم', order.totalPriceWithOutDiscound),
                _money('بعد الخصم', order.totalPriceWithDiscound),
                if (order.discoundCode?.isNotEmpty == true)
                  _row('كود الخصم', order.discoundCode!),
                if (order.totalPriceWithDiscoundCode != null)
                  _money('بعد الكوبون', order.totalPriceWithDiscoundCode!),
                _money('رسوم التوصيل', order.priceDelivery),
              ]),
              _section('عنوان الطلب', [
                _row('الاسم', order.customerName),
                _row('الهاتف', order.phoneNum1),
                _row('العنوان', order.address),
              ]),
              if (order.latestHandover case final handover?)
                _section('التسليم', [
                  _row('شركة التوصيل', handover.deliveryCompanyName),
                  if (handover.trackingNumber.isNotEmpty)
                    _row('رقم التتبع', handover.trackingNumber),
                  if (handover.shiplyParcelCode.isNotEmpty)
                    _row('رمز Shiply', handover.shiplyParcelCode),
                  if (handover.carrierContactName.isNotEmpty)
                    _row('جهة الاتصال', handover.carrierContactName),
                  if (handover.carrierContactPhone.isNotEmpty)
                    _row('هاتف الناقل', handover.carrierContactPhone),
                ]),
              _section('التتبع', [OrderTrackingTimeline(order: order)]),
              if (controller.mutationStatus == OrderMutationStatus.failure)
                Padding(
                  padding: const EdgeInsets.only(bottom: StoreSpacing.md),
                  child: Text(
                    controller.message ?? 'تعذر الإلغاء.',
                    style: StoreTypography.body.copyWith(
                      color: StorePalette.error,
                    ),
                  ),
                ),
              OrderActions(order: order, controller: controller),
            ],
          ),
        ),
      );
    },
  );

  Widget _line(OrderDetail line) => Padding(
    padding: const EdgeInsets.only(bottom: StoreSpacing.sm),
    child: Row(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: StoreNetworkMedia(
            url: line.item.viewImagesItems.firstOrNull?.imageUrl,
            semanticLabel: line.item.nameAr,
          ),
        ),
        const SizedBox(width: StoreSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.item.nameAr.isEmpty
                    ? 'منتج #${line.itemId}'
                    : line.item.nameAr,
                style: StoreTypography.bodyMedium,
              ),
              if (line.itemSize != null || line.itemSizeColor != null)
                Text(
                  [
                    line.itemSize?.size,
                    line.itemSizeColor?.colorAr,
                  ].whereType<String>().where((v) => v.isNotEmpty).join(' • '),
                  style: StoreTypography.caption,
                ),
              Text(
                '${line.quantity} × ${line.itemPrice.toStringAsFixed(2)} ₪',
                style: StoreTypography.caption,
              ),
            ],
          ),
        ),
        Text(
          '${line.totalPriceWithDiscound.toStringAsFixed(2)} ₪',
          style: StoreTypography.label,
        ),
      ],
    ),
  );

  Widget _section(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: StoreSpacing.sm),
    padding: const EdgeInsets.all(StoreSpacing.md),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      border: Border.all(color: StorePalette.border),
      borderRadius: BorderRadius.circular(StoreRadii.lg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: StoreTypography.title),
        const SizedBox(height: StoreSpacing.sm),
        ...children,
      ],
    ),
  );

  Widget _money(String label, double value) =>
      _row(label, '${value.toStringAsFixed(2)} ₪');
  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: StoreSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: StoreTypography.caption)),
        Expanded(
          child: Text(
            value,
            style: StoreTypography.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}
