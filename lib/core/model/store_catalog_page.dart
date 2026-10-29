import 'get_all_item_model.dart';

class StoreCatalogPage {
  const StoreCatalogPage({
    required this.items,
    this.page = 1,
    this.total = 0,
    this.hasMore = false,
  });
  final List<Item> items;
  final int page;
  final int total;
  final bool hasMore;

  factory StoreCatalogPage.fromJson(Map<String, dynamic> json) {
    final items = ItemsResponse.fromJson(json).rows;
    final pagination = json['paginationInfo'];
    if (pagination == null) {
      return StoreCatalogPage(items: items, total: items.length);
    }
    if (pagination is! Map) {
      throw const FormatException('catalog pagination must be an object');
    }
    final page = pagination['page'] ?? 1;
    final total = pagination['totalRowsCount'] ?? items.length;
    final more = pagination['hasMore'] ?? false;
    if (page is! int ||
        page < 1 ||
        total is! int ||
        total < 0 ||
        more is! bool) {
      throw const FormatException('catalog pagination is incompatible');
    }
    return StoreCatalogPage(
      items: items,
      page: page,
      total: total,
      hasMore: more,
    );
  }
}
