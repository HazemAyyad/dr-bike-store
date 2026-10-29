import 'package:get/get.dart';
import '../model/store_address_model.dart';

class StoreAddressBook {
  StoreAddressBook(this.fetch);
  final Future<Response> Function() fetch;

  Future<List<StoreAddress>> load() async {
    final response = await fetch();
    if (response.statusCode != 200 || response.body is! Map) {
      throw const FormatException('store addresses');
    }
    final rows = (response.body as Map)['data'];
    if (rows is! List) throw const FormatException('store addresses data');
    return List.unmodifiable(
      rows
          .whereType<Map>()
          .map((row) => StoreAddress.fromJson(Map<String, dynamic>.from(row)))
          .where((address) => address.id > 0),
    );
  }

  static StoreAddress? preferred(List<StoreAddress> addresses) =>
      addresses.firstWhereOrNull(
        (address) => address.isDefault && address.isDeliveryReady,
      ) ??
      addresses.firstWhereOrNull((address) => address.isDeliveryReady);
}
