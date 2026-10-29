import 'package:get/get.dart';

abstract interface class StoreCatalogSource {
  Future<Response> catalogPage({
    String? query,
    int? categoryId,
    int page = 1,
    Map<String, String> filters = const {},
  });
}
