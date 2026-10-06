import 'package:flutter/material.dart';

import '../../../core/model/orders_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';

class OrderTrackingTimeline extends StatelessWidget {
  const OrderTrackingTimeline({required this.order, super.key});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final entries = <({String label, String time, String note})>[
      ...order.statusLogs.map(
        (log) => (label: log.toStatus, time: log.createdAt, note: log.note),
      ),
      ...?order.shiplyTracking?.events.map(
        (event) => (
          label:
              event.statusLabel.isEmpty ? event.statusKey : event.statusLabel,
          time: event.occurredAt,
          note: event.note,
        ),
      ),
    ]..sort((a, b) => _date(a.time).compareTo(_date(b.time)));
    if (entries.isEmpty) {
      return Text(
        'لا توجد بيانات تتبع مسجلة لهذا الطلب.',
        style: StoreTypography.body,
      );
    }
    return Column(
      children:
          entries
              .map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.radio_button_checked,
                    color: StorePalette.purple,
                  ),
                  title: Text(
                    entry.label.isEmpty ? 'حالة غير معروفة' : entry.label,
                    style: StoreTypography.bodyMedium,
                  ),
                  subtitle: Text(
                    [
                      entry.time,
                      entry.note,
                    ].where((v) => v.isNotEmpty).join('\n'),
                    style: StoreTypography.caption,
                  ),
                ),
              )
              .toList(),
    );
  }

  DateTime _date(String value) => DateTime.tryParse(value) ?? DateTime(9999);
}
