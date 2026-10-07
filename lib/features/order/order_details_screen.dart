import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

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
      final trackingKey = GlobalKey();
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: StorePalette.background,
          appBar: AppBar(
            title: Text('تفاصيل الطلب', style: StoreTypography.title),
            centerTitle: true,
            elevation: 0,
          ),
          body: ListView(
            key: const PageStorageKey<String>('order-details-scroll'),
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 24),
            children: [
              _OrderHeader(order: order),
              const SizedBox(height: 10),
              _section(
                icon: Icons.shopping_bag_outlined,
                title: 'منتجات الطلب (${order.details.length})',
                children: [
                  if (order.details.isEmpty)
                    Text(
                      'تفاصيل المنتجات غير متاحة.',
                      style: StoreTypography.body,
                    )
                  else
                    ...order.details.indexed.map(
                      (entry) => Column(
                        children: [
                          _OrderLine(line: entry.$2),
                          if (entry.$1 != order.details.length - 1)
                            const Divider(
                              height: 18,
                              color: StorePalette.border,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              _section(
                icon: Icons.payments_outlined,
                title: 'ملخص الدفع',
                children: [_PaymentSummary(order: order)],
              ),
              _section(
                icon: Icons.location_on_outlined,
                title: 'عنوان التوصيل',
                children: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    value:
                        order.customerName.isEmpty
                            ? 'غير متاح'
                            : order.customerName,
                  ),
                  if (order.phoneNum1.isNotEmpty)
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      value: order.phoneNum1,
                    ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    value: order.address.isEmpty ? 'غير متاح' : order.address,
                  ),
                ],
              ),
              if (order.latestHandover case final handover?)
                _section(
                  icon: Icons.local_shipping_outlined,
                  title: 'بيانات الشحنة',
                  children: [
                    if (handover.deliveryCompanyName.isNotEmpty)
                      _labelValueRow(
                        'شركة التوصيل',
                        handover.deliveryCompanyName,
                      ),
                    if (handover.trackingNumber.isNotEmpty)
                      _labelValueRow('رقم التتبع', handover.trackingNumber),
                    if (handover.shiplyParcelCode.isNotEmpty)
                      _labelValueRow('رمز Shiply', handover.shiplyParcelCode),
                    if (handover.carrierContactName.isNotEmpty)
                      _labelValueRow(
                        'جهة الاتصال',
                        handover.carrierContactName,
                      ),
                    if (handover.carrierContactPhone.isNotEmpty)
                      _labelValueRow(
                        'هاتف الناقل',
                        handover.carrierContactPhone,
                      ),
                  ],
                ),
              if (order.hasTracking || order.statusLogs.isNotEmpty)
                _section(
                  key: trackingKey,
                  icon: Icons.route_outlined,
                  title: 'تتبع الشحنة',
                  children: [OrderTrackingTimeline(order: order)],
                ),
              if (controller.mutationStatus == OrderMutationStatus.failure)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StorePalette.derivedErrorSurface,
                    borderRadius: BorderRadius.circular(StoreRadii.md),
                  ),
                  child: Text(
                    controller.message ?? 'تعذر الإلغاء.',
                    style: StoreTypography.body.copyWith(
                      color: StorePalette.error,
                    ),
                  ),
                ),
              OrderActions(
                order: order,
                controller: controller,
                onTrack:
                    order.hasTracking
                        ? () {
                          final trackingContext = trackingKey.currentContext;
                          if (trackingContext != null) {
                            Scrollable.ensureVisible(
                              trackingContext,
                              duration: StoreMotion.standard,
                              curve: Curves.easeOut,
                            );
                          }
                        }
                        : null,
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _section({
    Key? key,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) => Container(
    key: key,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      border: Border.all(color: StorePalette.border),
      borderRadius: BorderRadius.circular(StoreRadii.lg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: StorePalette.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: StorePalette.purple, size: 19),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: StoreTypography.title.copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    ),
  );
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(order);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StorePalette.navy, StorePalette.purple],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(StoreRadii.lg),
        border: Border.all(color: StorePalette.border),
        boxShadow: const [StoreElevation.lowShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: StoreTypography.title.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _displayDate(order.dateAdd),
                      style: StoreTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(StoreRadii.pill),
                ),
                child: Text(
                  status.label,
                  style: StoreTypography.caption.copyWith(
                    color: status.foreground,
                    fontWeight: StoreTypography.semiBold,
                  ),
                ),
              ),
            ],
          ),
          if (order.shiplyTracking != null) ...[
            const Divider(height: 22, color: Colors.white24),
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _shiplyStatusLabel(order.shiplyTracking!),
                    style: StoreTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _HeaderMetric(label: 'المنتجات', value: '${order.itemCount}'),
              const SizedBox(width: 8),
              _HeaderMetric(
                label: 'الإجمالي',
                value: '${_price(order.grandTotal)} ₪',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(StoreRadii.md),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: StoreTypography.caption.copyWith(color: Colors.white70),
          ),
          Text(
            value,
            style: StoreTypography.label.copyWith(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

class _OrderLine extends StatelessWidget {
  const _OrderLine({required this.line});

  final OrderDetail line;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: StorePalette.background,
          borderRadius: BorderRadius.circular(StoreRadii.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: StoreNetworkMedia(
          url: line.item.primaryImageUrl,
          semanticLabel:
              line.item.nameAr.isEmpty
                  ? 'منتج ${line.itemId}'
                  : line.item.nameAr,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              line.item.nameAr.isEmpty
                  ? 'منتج #${line.itemId}'
                  : line.item.nameAr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
            Text('الكمية: ${line.quantity}', style: StoreTypography.caption),
            if (line.item.model.trim().isNotEmpty)
              Text(
                'رمز المنتج: ${line.item.model}',
                style: StoreTypography.caption.copyWith(fontSize: 10.5),
              ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${_price(line.totalPriceWithDiscound)} ₪',
            style: StoreTypography.label.copyWith(color: StorePalette.navy),
          ),
          Text(
            '${_price(line.itemPrice)} ₪ للوحدة',
            style: StoreTypography.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    ],
  );
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _valueRow('المجموع الفرعي', order.totalPriceWithOutDiscound),
      if (order.discountTotal > 0)
        _valueRow(
          order.discoundCode?.isNotEmpty == true ? 'خصم الكوبون' : 'الخصم',
          -order.discountTotal,
          color: StorePalette.error,
        ),
      if (order.discoundCode?.isNotEmpty == true)
        _textValueRow('كود الخصم', order.discoundCode!),
      _valueRow('الشحن', order.priceDelivery),
      const Divider(height: 22, color: StorePalette.border),
      _valueRow('المجموع الكلي', order.grandTotal, strong: true),
    ],
  );
}

Widget _valueRow(
  String label,
  double value, {
  Color? color,
  bool strong = false,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: strong ? StoreTypography.bodyMedium : StoreTypography.body,
        ),
      ),
      Text(
        '${value < 0 ? '-' : ''}${_price(value.abs())} ₪',
        style: (strong ? StoreTypography.title : StoreTypography.label)
            .copyWith(
              color: color ?? (strong ? StorePalette.navy : null),
              fontSize: strong ? 17 : null,
            ),
      ),
    ],
  ),
);

Widget _textValueRow(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Row(
    children: [
      Expanded(child: Text(label, style: StoreTypography.body)),
      Text(value, style: StoreTypography.label),
    ],
  ),
);

Widget _labelValueRow(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(label, style: StoreTypography.caption)),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: StoreTypography.bodyMedium,
        ),
      ),
    ],
  ),
);

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: StorePalette.purple),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: StoreTypography.body)),
      ],
    ),
  );
}

({String label, Color foreground, Color background}) _statusPresentation(
  Order order,
) => switch (order.statusKind) {
  StoreOrderStatusKind.current => (
    label: 'قيد التجهيز',
    foreground: StorePalette.purple,
    background: StorePalette.lightPurple,
  ),
  StoreOrderStatusKind.completed => (
    label: 'مكتمل',
    foreground: StorePalette.success,
    background: StorePalette.derivedSuccessSurface,
  ),
  StoreOrderStatusKind.canceled => (
    label: 'ملغى',
    foreground: StorePalette.error,
    background: StorePalette.derivedErrorSurface,
  ),
  StoreOrderStatusKind.unknown => (
    label: order.rawStatus.isEmpty ? 'غير معروف' : order.rawStatus,
    foreground: StorePalette.textSecondary,
    background: StorePalette.background,
  ),
};

String _price(num value) => NumberFormat('#,##0.##', 'en_US').format(value);

String _displayDate(String raw) {
  final date = DateTime.tryParse(raw);
  return date == null
      ? raw
      : DateFormat('yyyy-MM-dd  HH:mm').format(date.toLocal());
}

String _shiplyStatusLabel(OrderShiplyTracking tracking) => switch (tracking
    .currentStatusId) {
  1 => 'تم إنشاء الشحنة',
  2 => 'تم إرسالها لشركة الشحن',
  3 => 'في الطريق',
  4 => 'محاولة تسليم',
  5 => 'معلقة',
  6 => 'تم التسليم',
  7 => 'مرتجعة',
  _ =>
    tracking.currentStatusLabel.isEmpty
        ? 'حالة الشحنة'
        : tracking.currentStatusLabel,
};
