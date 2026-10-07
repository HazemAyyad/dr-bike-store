import 'package:flutter/material.dart';

import '../../../core/model/orders_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';

enum OrderTimelineState { completed, current, pending }

class OrderTrackingTimeline extends StatelessWidget {
  const OrderTrackingTimeline({required this.order, super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final tracking = order.shiplyTracking;
    if (tracking != null && tracking.statusSequence.isNotEmpty) {
      return _ShiplyTimeline(tracking: tracking);
    }
    if (order.statusLogs.isNotEmpty) {
      return _OrderStatusTimeline(logs: order.statusLogs);
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StorePalette.background,
        borderRadius: BorderRadius.circular(StoreRadii.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.route_outlined, color: StorePalette.textSecondary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'لا توجد بيانات تتبع مسجلة لهذا الطلب.',
              style: StoreTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiplyTimeline extends StatelessWidget {
  const _ShiplyTimeline({required this.tracking});

  final OrderShiplyTracking tracking;

  @override
  Widget build(BuildContext context) {
    var currentIndex = tracking.statusSequence.indexOf(
      tracking.currentStatusId,
    );
    if (currentIndex < 0 && tracking.events.isNotEmpty) {
      currentIndex = tracking.statusSequence.indexOf(
        tracking.events.last.parcelStatusId,
      );
    }
    return Column(
      children: List.generate(tracking.statusSequence.length, (index) {
        final id = tracking.statusSequence[index];
        final event = tracking.events.lastWhereOrNull(
          (candidate) => candidate.parcelStatusId == id,
        );
        final state =
            currentIndex < 0 || index > currentIndex
                ? OrderTimelineState.pending
                : index == currentIndex
                ? OrderTimelineState.current
                : OrderTimelineState.completed;
        return _TimelineEntry(
          label: _shiplyLabel(id, event?.statusLabel ?? ''),
          timestamp: event?.occurredAt ?? '',
          note: event?.note ?? '',
          state: state,
          last: index == tracking.statusSequence.length - 1,
        );
      }),
    );
  }
}

class _OrderStatusTimeline extends StatelessWidget {
  const _OrderStatusTimeline({required this.logs});

  final List<OrderStatusLog> logs;

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(logs.length, (index) {
      final log = logs[index];
      return _TimelineEntry(
        label: _orderStatusLabel(log.toStatus),
        timestamp: log.createdAt,
        note: log.note,
        state:
            index == logs.length - 1
                ? OrderTimelineState.current
                : OrderTimelineState.completed,
        last: index == logs.length - 1,
      );
    }),
  );
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.label,
    required this.timestamp,
    required this.note,
    required this.state,
    required this.last,
  });

  final String label;
  final String timestamp;
  final String note;
  final OrderTimelineState state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final active = state != OrderTimelineState.pending;
    final color = active ? StorePalette.purple : StorePalette.textDisabled;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        state == OrderTimelineState.current
                            ? StorePalette.purple
                            : StorePalette.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Icon(
                    state == OrderTimelineState.completed
                        ? Icons.check_rounded
                        : state == OrderTimelineState.current
                        ? Icons.circle
                        : Icons.more_horiz_rounded,
                    size: state == OrderTimelineState.current ? 8 : 13,
                    color:
                        state == OrderTimelineState.current
                            ? Colors.white
                            : color,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: active ? StorePalette.purple : StorePalette.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.isEmpty ? 'حالة غير معروفة' : label,
                    style: StoreTypography.bodyMedium.copyWith(
                      color:
                          state == OrderTimelineState.pending
                              ? StorePalette.textSecondary
                              : StorePalette.textPrimary,
                    ),
                  ),
                  if (timestamp.isNotEmpty)
                    Text(timestamp, style: StoreTypography.caption),
                  if (note.isNotEmpty)
                    Text(note, style: StoreTypography.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _shiplyLabel(int id, String fallback) => switch (id) {
  1 => 'تم إنشاء الشحنة',
  2 => 'تم إرسالها لشركة الشحن',
  3 => 'في الطريق',
  4 => 'محاولة تسليم',
  5 => 'معلقة',
  6 => 'تم التسليم',
  7 => 'مرتجعة',
  _ => fallback.isEmpty ? 'حالة الشحنة' : fallback,
};

String _orderStatusLabel(String raw) => switch (raw) {
  'New' => 'تم استلام الطلب',
  'Done' => 'اكتمل الطلب',
  'Canceled' => 'ألغي الطلب',
  _ => raw,
};

extension _LastWhereOrNull<T> on Iterable<T> {
  T? lastWhereOrNull(bool Function(T value) test) {
    T? result;
    for (final value in this) {
      if (test(value)) result = value;
    }
    return result;
  }
}
