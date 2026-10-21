import 'package:doctor_bike/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('product share URL uses productId and the deployed backend base', () {
    expect(
      AppConstants.productShareUrl(42),
      'https://dr-bike.shop/store/products/42',
    );
  });

  test('product share URL rejects invalid product identity', () {
    expect(() => AppConstants.productShareUrl(0), throwsArgumentError);
  });
}
