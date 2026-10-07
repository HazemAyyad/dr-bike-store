import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/model/get_all_item_model.dart';

class FavoriteSnapshot {
  const FavoriteSnapshot({required this.listingIds, required this.items});

  final Set<int> listingIds;
  final List<Item> items;
}

class FavoriteToggleResult {
  const FavoriteToggleResult({
    required this.listingId,
    required this.isFavorite,
  });

  final int listingId;
  final bool isFavorite;
}

abstract interface class FavoritesGateway {
  Future<FavoriteSnapshot> load();

  Future<FavoriteToggleResult> toggle(int listingId);
}

class FavoritesRepository implements FavoritesGateway {
  const FavoritesRepository({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<FavoriteSnapshot> load() async {
    final response = await apiClient.getData(
      '/OnlineStore/Favorites',
      headers: await _headers(),
    );
    if (response.statusCode != 200 || response.body is! Map) {
      throw StateError(response.statusText ?? 'favorites load failed');
    }
    final data = (response.body as Map)['data'];
    if (data is! Map ||
        data['listing_ids'] is! List ||
        data['items'] is! List) {
      throw const FormatException('favorites response is malformed');
    }
    final ids =
        (data['listing_ids'] as List)
            .map((value) => int.tryParse('$value'))
            .whereType<int>()
            .where((value) => value > 0)
            .toSet();
    final items = (data['items'] as List)
        .whereType<Map>()
        .map((row) => Item.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
    return FavoriteSnapshot(listingIds: ids, items: items);
  }

  @override
  Future<FavoriteToggleResult> toggle(int listingId) async {
    if (listingId <= 0) {
      throw const FormatException('favorite listing identity is invalid');
    }
    final response = await apiClient.postData(
      '/OnlineStore/Favorites/Toggle',
      headers: await _headers(),
      body: {'listing_id': listingId},
    );
    if (response.statusCode != 200 || response.body is! Map) {
      throw StateError(response.statusText ?? 'favorite mutation failed');
    }
    final data = (response.body as Map)['data'];
    if (data is! Map || data['is_favorite'] is! bool) {
      throw const FormatException('favorite mutation response is malformed');
    }
    return FavoriteToggleResult(
      listingId: int.tryParse('${data['listing_id']}') ?? listingId,
      isFavorite: data['is_favorite'] as bool,
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await AppUsageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'authorization': 'Bearer $token',
    };
  }
}
