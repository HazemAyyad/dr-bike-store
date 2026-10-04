import 'package:get/get.dart';

String? upgradeRequiredMessage(Response response) {
  if (response.statusCode != 426) return null;
  final backendMessage =
      response.body is Map ? response.body['message']?.toString() : null;
  return backendMessage?.isNotEmpty == true
      ? backendMessage
      : 'يجب تحديث التطبيق إلى أحدث إصدار لمتابعة استعادة كلمة المرور.';
}
