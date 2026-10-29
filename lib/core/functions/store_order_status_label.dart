import 'package:get/get.dart';

String storeOrderStatusLabel(String status) => switch (status.toLowerCase()) {
  'new' => 'قيد التجهيز'.tr,
  'unconfirmed' => 'بانتظار التأكيد'.tr,
  'confirmed' => 'تم تأكيد الطلب'.tr,
  'ready' => 'جاهز للتوصيل'.tr,
  'postponed' => 'مؤجل'.tr,
  'with_delivery' => 'مع شركة التوصيل'.tr,
  'delivered' => 'تم التسليم'.tr,
  'done' => 'مكتمل'.tr,
  'archived' => 'مكتمل ومؤرشف'.tr,
  'review' => 'قيد المراجعة'.tr,
  'stuck' => 'معلق'.tr,
  'returned' => 'مرتجعة'.tr,
  'partial_delivered' => 'تم التسليم جزئيًا'.tr,
  'partial_return' => 'مرتجع جزئي'.tr,
  'alternative_return' => 'مرتجع استبدال'.tr,
  'canceled' => 'ملغى'.tr,
  _ => status.isEmpty ? 'غير معروف'.tr : status,
};
