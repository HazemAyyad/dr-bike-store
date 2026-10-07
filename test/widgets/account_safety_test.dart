import 'package:doctor_bike/features/acount/account_actions_screen.dart';
import 'package:doctor_bike/features/acount/addresses_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('account actions fails safely when binding is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: AccountActionsScreen()));
    expect(find.textContaining('تعذر تحميل إجراءات الحساب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('addresses fails safely when binding is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: AddressesScreen()));
    expect(find.textContaining('تعذر فتح العناوين'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
