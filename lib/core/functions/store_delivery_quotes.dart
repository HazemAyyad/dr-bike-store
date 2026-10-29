import 'package:get/get.dart';

typedef FetchStoreDeliveryQuote =
    Future<Response> Function({
      required String villageId,
      required double price,
    });

/// Coordinates attempts without retaining an earlier successful price on error.
class StoreDeliveryQuotes {
  StoreDeliveryQuotes(this.fetch);
  final FetchStoreDeliveryQuote fetch;
  int _generation = 0;

  int begin() => ++_generation;
  void invalidate() => _generation++;
  bool isCurrent(int request) => request == _generation;

  Future<double?> quote({
    required String villageId,
    required double price,
  }) async {
    try {
      final response = await fetch(villageId: villageId, price: price);
      if (response.statusCode != 200 || response.body is! Map) return null;
      final body = response.body as Map;
      final fees = body['fees'];
      final amount =
          body['deliveryCost'] ??
          body['priceDelivery'] ??
          (fees is Map ? fees['delivery_cost'] : null);
      if (amount is! num || !amount.isFinite || amount < 0) return null;
      return amount.toDouble();
    } catch (_) {
      return null;
    }
  }
}
