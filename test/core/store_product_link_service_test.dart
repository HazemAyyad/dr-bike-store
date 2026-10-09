import 'dart:async';

import 'package:doctor_bike/core/functions/store_product_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoreProductLinkService.productIdFromUri', () {
    test('accepts deployed and root HTTPS product paths', () {
      expect(
        StoreProductLinkService.productIdFromUri(
          Uri.parse(
            'https://dr-bike.duosparktech.com/public/store/products/42',
          ),
        ),
        42,
      );
      expect(
        StoreProductLinkService.productIdFromUri(
          Uri.parse('https://dr-bike.duosparktech.com/store/products/77'),
        ),
        77,
      );
    });

    test('accepts the custom app fallback scheme', () {
      expect(
        StoreProductLinkService.productIdFromUri(
          Uri.parse('doctorbike-store://products/15?quantity=2'),
        ),
        15,
      );
    });

    test('rejects foreign hosts, unrelated paths, and invalid IDs', () {
      expect(
        StoreProductLinkService.productIdFromUri(
          Uri.parse('https://example.com/public/store/products/42'),
        ),
        isNull,
      );
      expect(
        StoreProductLinkService.productIdFromUri(
          Uri.parse('https://dr-bike.duosparktech.com/public/orders/42'),
        ),
        isNull,
      );
      expect(
        StoreProductLinkService.productIdFromUri(
          Uri.parse('doctorbike-store://products/0'),
        ),
        isNull,
      );
    });
  });

  test('queues a cold-start product until home navigation is ready', () async {
    final opened = <int>[];
    final links = StreamController<Uri>.broadcast();
    final service = StoreProductLinkService(
      linkStream: links.stream,
      initialLink:
          () async => Uri.parse(
            'https://dr-bike.duosparktech.com/public/store/products/91',
          ),
      openProduct: (productId) async => opened.add(productId),
    );

    await service.initialize();

    expect(service.pendingProductId, 91);
    expect(opened, isEmpty);
    expect(await service.markNavigationReady(), isTrue);
    expect(opened, [91]);
    expect(service.pendingProductId, isNull);

    service.onClose();
    await links.close();
  });

  test('opens valid links received while the app is ready', () async {
    final opened = <int>[];
    final links = StreamController<Uri>.broadcast();
    final service = StoreProductLinkService(
      linkStream: links.stream,
      initialLink: () async => null,
      openProduct: (productId) async => opened.add(productId),
    );

    await service.initialize();
    expect(await service.markNavigationReady(), isFalse);
    links.add(Uri.parse('doctorbike-store://products/23'));
    await Future<void>.delayed(Duration.zero);

    expect(opened, [23]);

    service.onClose();
    await links.close();
  });
}
