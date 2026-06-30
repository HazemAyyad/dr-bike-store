import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/LocalizationController.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/styles.dart';
import '../../core/model/orders_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  static const _surface = Color(0xFFF7F8FA);
  static const _card = Colors.white;
  static const _border = Color(0xFFE5E7EB);
  static const _muted = Color(0xFF6B7280);
  static const _text = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as Order;
    final theme = Theme.of(context);
    final localization = Get.find<LocalizationController>();
    final isAr = localization.locale.languageCode == 'ar';
    final isEng = localization.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _surface,
        title: Text(
          "${"Order Details".tr} #${order.orderNumber}",
          style: robotoBold.copyWith(color: theme.hoverColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.hoverColor),
          onPressed: Get.back,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          _Section(
            title: "Order Status".tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusChip(status: order.status),
                SizedBox(height: 10.h),
                _InfoRow(label: "Order number".tr, value: order.orderNumber),
                _InfoRow(label: "Date".tr, value: order.dateUpdate),
                _InfoRow(label: "address".tr, value: order.address),
                _InfoRow(label: "Mobile number".tr, value: order.phoneNum1),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _Section(title: "Delivery".tr, child: _DeliveryDetails(order: order)),
          SizedBox(height: 12.h),
          _Section(
            title: "Products".tr,
            child: Column(
              children:
                  order.details.map((detail) {
                    final item = detail.item;
                    final name =
                        isAr
                            ? item.nameAr
                            : isEng
                            ? item.nameEng
                            : item.nameAbree;
                    return _ProductRow(
                      name: name,
                      quantity: detail.quantity,
                      price: detail.itemPrice,
                    );
                  }).toList(),
            ),
          ),
          SizedBox(height: 12.h),
          _Section(title: "Activity log".tr, child: _StatusLogs(order: order)),
        ],
      ),
    );
  }
}

class _DeliveryDetails extends StatelessWidget {
  const _DeliveryDetails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final handover = order.latestHandover;
    final tracking = order.shiplyTracking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          label: "Delivery price".tr,
          value: "${order.priceDelivery.toStringAsFixed(2)}₪",
        ),
        if (handover == null && tracking == null)
          Text(
            "لم يتم تسليم الطلب لشركة التوصيل بعد",
            style: robotoRegular.copyWith(color: OrderDetailsScreen._muted),
          )
        else ...[
          if (handover != null) ...[
            _InfoRow(
              label: "Delivery company".tr,
              value:
                  handover.deliveryCompanyName.isNotEmpty
                      ? handover.deliveryCompanyName
                      : "Shiply",
            ),
            _InfoRow(
              label: "Tracking number".tr,
              value:
                  handover.shiplyParcelCode.isNotEmpty
                      ? handover.shiplyParcelCode
                      : handover.trackingNumber,
            ),
            _InfoRow(label: "Handed over".tr, value: handover.handedOverAt),
            _InfoRow(label: "Delivered".tr, value: handover.deliveredAt),
          ],
          if (tracking != null) ...[
            SizedBox(height: 8.h),
            Text(
              "Shiply tracking".tr,
              style: robotoBold.copyWith(color: OrderDetailsScreen._text),
            ),
            SizedBox(height: 8.h),
            _ShiplyTimeline(tracking: tracking),
          ],
        ],
      ],
    );
  }
}

class _ShiplyTimeline extends StatelessWidget {
  const _ShiplyTimeline({required this.tracking});

  final OrderShiplyTracking tracking;

  @override
  Widget build(BuildContext context) {
    final eventsByStatus = {
      for (final event in tracking.events) event.parcelStatusId: event,
    };
    final sequence =
        tracking.statusSequence.isNotEmpty
            ? tracking.statusSequence
            : const [1, 2, 3, 4, 5, 6, 7];

    return Column(
      children:
          sequence.map((statusId) {
            final event = eventsByStatus[statusId];
            final isDone =
                event != null ||
                (tracking.currentStatusId > 0 &&
                    statusId <= tracking.currentStatusId);
            return _TimelineRow(
              active: isDone,
              title: event?.statusLabel ?? _shiplyStatusLabel(statusId),
              subtitle: event?.occurredAt ?? event?.note ?? '',
            );
          }).toList(),
    );
  }

  String _shiplyStatusLabel(int statusId) {
    switch (statusId) {
      case 1:
        return "Draft";
      case 2:
        return "Submitted to Shiply";
      case 3:
        return "On the way";
      case 4:
        return "Delivery attempt";
      case 5:
        return "Pending";
      case 6:
        return "Delivered";
      case 7:
        return "Returned";
      default:
        return "Pending";
    }
  }
}

class _StatusLogs extends StatelessWidget {
  const _StatusLogs({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final logs = order.statusLogs;
    if (logs.isEmpty) {
      return _TimelineRow(
        active: true,
        title: order.status.tr,
        subtitle: order.dateAdd,
      );
    }

    return Column(
      children:
          logs.map((log) {
            return _TimelineRow(
              active: true,
              title: log.toStatus.tr,
              subtitle: [
                log.createdAt,
                if (log.note.isNotEmpty) log.note,
                if (log.userName.isNotEmpty) log.userName,
              ].where((e) => e.isNotEmpty).join(" • "),
            );
          }).toList(),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.active,
    required this.title,
    required this.subtitle,
  });

  final bool active;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).primaryColor : Colors.grey;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: color,
            size: 20.w,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: robotoBold.copyWith(
                    color: OrderDetailsScreen._text,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: robotoRegular.copyWith(
                      color: OrderDetailsScreen._muted,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: OrderDetailsScreen._surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: robotoBold.copyWith(color: OrderDetailsScreen._text),
            ),
          ),
          Text(
            "x$quantity",
            style: robotoRegular.copyWith(color: OrderDetailsScreen._muted),
          ),
          SizedBox(width: 12.w),
          Text(
            "${price.toStringAsFixed(2)}₪",
            style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: OrderDetailsScreen._card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: OrderDetailsScreen._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: robotoBold.copyWith(
              color: OrderDetailsScreen._text,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: robotoRegular.copyWith(color: OrderDetailsScreen._muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: robotoBold.copyWith(color: OrderDetailsScreen._text),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final color =
        lower.contains('cancel')
            ? Colors.red
            : lower.contains('done') || lower.contains('complete')
            ? Colors.green
            : const Color(0xffc1a100);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(status.tr, style: robotoBold.copyWith(color: color)),
    );
  }
}
