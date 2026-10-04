import 'package:get/get.dart';

String? upgradeRequiredMessage(Response response) {
  if (response.statusCode != 426) return null;
  return 'يجب تحديث التطبيق إلى أحدث إصدار لمتابعة استعادة كلمة المرور.';
}

String? missingResetProofMessage(String? resetProof) {
  if (resetProof != null && resetProof.isNotEmpty) return null;
  return 'تعذر التحقق من طلب استعادة كلمة المرور. يرجى إعادة المحاولة.';
}
