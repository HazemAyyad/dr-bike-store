import 'package:doctor_bike/core/model/store_address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('address is delivery ready only with complete Shiply identity', () {
    const complete = StoreAddress(
      id: 1,
      label: 'المنزل',
      streetAddress: 'شارع الإرسال',
      isDefault: true,
      shiplyCityId: 10,
      shiplyVillageId: 20,
      shiplyCityName: 'رام الله',
      shiplyVillageName: 'الماصيون',
    );
    const incomplete = StoreAddress(
      id: 2,
      label: 'العمل',
      streetAddress: 'وسط البلد',
      isDefault: false,
      shiplyCityId: 10,
      shiplyCityName: 'رام الله',
    );

    expect(complete.isDeliveryReady, isTrue);
    expect(complete.locationLabel, 'الماصيون، رام الله');
    expect(incomplete.isDeliveryReady, isFalse);
  });
}
