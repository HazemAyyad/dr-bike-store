import 'get_all_item_model.dart';
import 'main_categores_model.dart';

class OnlineStorePopupCampaign {
  const OnlineStorePopupCampaign({
    required this.id,
    required this.imagePath,
    required this.titles,
    required this.contents,
    required this.buttons,
    required this.theme,
    required this.actionType,
    this.actionTargetId,
    this.actionProductId,
    this.actionUrl,
    this.couponCode,
  });

  final int id;
  final String imagePath;
  final Map<String, String> titles;
  final Map<String, String> contents;
  final Map<String, String> buttons;
  final String theme;
  final String actionType;
  final int? actionTargetId;
  final int? actionProductId;
  final String? actionUrl;
  final String? couponCode;

  factory OnlineStorePopupCampaign.fromJson(Map<String, dynamic> json) =>
      OnlineStorePopupCampaign(
        id: int.tryParse('${json['id']}') ?? 0,
        imagePath: json['image_path']?.toString() ?? '',
        titles: _strings(json['title_translations']),
        contents: _strings(json['content_translations']),
        buttons: _strings(json['button_translations']),
        theme: json['theme']?.toString() ?? 'brand',
        actionType: json['action_type']?.toString() ?? 'none',
        actionTargetId: int.tryParse('${json['action_target_id'] ?? ''}'),
        actionProductId: int.tryParse('${json['action_product_id'] ?? ''}'),
        actionUrl: json['action_url']?.toString(),
        couponCode: json['coupon_code']?.toString(),
      );

  String _localized(Map<String, String> values, String languageCode) =>
      values[languageCode]?.trim().isNotEmpty == true
          ? values[languageCode]!
          : values['ar'] ?? values['en'] ?? values['he'] ?? '';

  String title(String languageCode) => _localized(titles, languageCode);
  String content(String languageCode) => _localized(contents, languageCode);
  String button(String languageCode) {
    final value = _localized(buttons, languageCode);
    return value.isEmpty
        ? (languageCode == 'en' ? 'Explore now' : 'اكتشف الآن')
        : value;
  }
}

class OnlineStoreHomeSection {
  const OnlineStoreHomeSection({
    required this.id,
    required this.key,
    required this.type,
    required this.titles,
    required this.items,
    required this.config,
  });

  final int id;
  final String key;
  final String type;
  final Map<String, String> titles;
  final List<OnlineStoreHomeItem> items;
  final Map<String, dynamic> config;

  factory OnlineStoreHomeSection.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) throw const FormatException('home items');
    return OnlineStoreHomeSection(
      id: int.tryParse('${json['id']}') ?? 0,
      key: json['key']?.toString() ?? '',
      type: json['section_type']?.toString() ?? '',
      titles: _strings(json['title_translations']),
      config:
          json['selection_config'] is Map
              ? Map<String, dynamic>.from(json['selection_config'] as Map)
              : const <String, dynamic>{},
      items: rawItems
          .whereType<Map>()
          .map(
            (item) =>
                OnlineStoreHomeItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }

  String title(String languageCode) =>
      titles[languageCode]?.trim().isNotEmpty == true
          ? titles[languageCode]!
          : titles['ar'] ?? titles['en'] ?? key;

  List<Category> get categories =>
      items.map((item) => item.category).whereType<Category>().toList();

  Set<int> get categoryTargetIds =>
      items
          .where((item) => item.targetType == 'category')
          .map((item) => item.targetId)
          .whereType<int>()
          .toSet();

  List<Item> get products =>
      items.map((item) => item.product).whereType<Item>().toList();

  List<OnlineStoreHomeBanner> get banners =>
      items
          .map((item) => item.banner)
          .whereType<OnlineStoreHomeBanner>()
          .toList();
}

class OnlineStoreHomeItem {
  const OnlineStoreHomeItem({
    this.targetType,
    this.targetId,
    this.category,
    this.product,
    this.banner,
  });

  final String? targetType;
  final int? targetId;
  final Category? category;
  final Item? product;
  final OnlineStoreHomeBanner? banner;

  factory OnlineStoreHomeItem.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('image_path')) {
      return OnlineStoreHomeItem(banner: OnlineStoreHomeBanner.fromJson(json));
    }
    final targetType = json['target_type']?.toString();
    final targetId = int.tryParse('${json['target_id'] ?? ''}');
    final category = json['category'];
    if (category is Map) {
      return OnlineStoreHomeItem(
        targetType: targetType,
        targetId: targetId,
        category: Category.fromJson(Map<String, dynamic>.from(category)),
      );
    }
    final listing = json['listing'];
    if (listing is Map) {
      return OnlineStoreHomeItem(
        targetType: targetType,
        targetId: targetId,
        product: _listing(Map<String, dynamic>.from(listing)),
      );
    }
    return OnlineStoreHomeItem(targetType: targetType, targetId: targetId);
  }
}

class OnlineStoreHomeBanner {
  const OnlineStoreHomeBanner({
    required this.id,
    required this.imagePath,
    required this.titles,
    required this.contents,
    required this.actionType,
    this.actionTargetId,
    this.actionProductId,
    this.actionUrl,
  });

  final int id;
  final String imagePath;
  final Map<String, String> titles;
  final Map<String, String> contents;
  final String actionType;
  final int? actionTargetId;
  final int? actionProductId;
  final String? actionUrl;

  factory OnlineStoreHomeBanner.fromJson(Map<String, dynamic> json) =>
      OnlineStoreHomeBanner(
        id: int.tryParse('${json['id']}') ?? 0,
        imagePath: json['image_path']?.toString() ?? '',
        titles: _strings(json['title_translations']),
        contents: _strings(json['content_translations']),
        actionType: json['action_type']?.toString() ?? 'none',
        actionTargetId: int.tryParse('${json['action_target_id'] ?? ''}'),
        actionProductId: int.tryParse('${json['action_product_id'] ?? ''}'),
        actionUrl: json['action_url']?.toString(),
      );

  bool get hasSupportedDestination => switch (actionType) {
    'url' => _isSafeHttpUrl(actionUrl),
    'listing' => (actionProductId ?? 0) > 0,
    'category' => (actionTargetId ?? 0) > 0,
    _ => false,
  };

  String title(String languageCode) =>
      titles[languageCode] ?? titles['ar'] ?? titles['en'] ?? '';
  String content(String languageCode) =>
      contents[languageCode] ?? contents['ar'] ?? contents['en'] ?? '';
}

bool _isSafeHttpUrl(String? value) {
  final uri = Uri.tryParse(value?.trim() ?? '');
  return uri != null &&
      uri.hasAuthority &&
      (uri.scheme == 'http' || uri.scheme == 'https');
}

Map<String, String> _strings(dynamic value) {
  if (value is! Map) return const <String, String>{};
  return value.map((key, value) => MapEntry('$key', value?.toString() ?? ''));
}

Item _listing(Map<String, dynamic> json) {
  if (json.containsKey('listingStatus')) return Item.fromJson(json);
  final media = (json['media'] as List? ?? const <dynamic>[])
      .whereType<Map>()
      .map((value) => Map<String, dynamic>.from(value))
      .toList(growable: false);
  final translations = _strings(json['name_translations']);
  final descriptions = _strings(json['description_translations']);
  final display =
      json['display'] is Map
          ? Map<String, dynamic>.from(json['display'] as Map)
          : const <String, dynamic>{};
  final prices =
      json['store_prices'] is Map
          ? Map<String, dynamic>.from(json['store_prices'] as Map)
          : const <String, dynamic>{};
  final retail = prices['retail'];
  final wholesale = prices['wholesale'];
  final availability =
      json['availability'] is Map
          ? Map<String, dynamic>.from(json['availability'] as Map)
          : const <String, dynamic>{};
  final productId = int.tryParse('${json['product_id']}') ?? 0;
  final legacyMedia = media
      .map(
        (item) => <String, dynamic>{
          'id': item['id'],
          'imageUrl': item['path']?.toString() ?? '',
          'itemId': productId,
        },
      )
      .toList(growable: false);
  return Item.fromJson(<String, dynamic>{
    'id': productId,
    'productId': productId,
    'listingId': json['id'],
    'listingStatus': json['status'],
    'readinessState': json['readiness_state'],
    'available': availability['visible'] == true,
    'purchasable': availability['purchasable'] == true,
    'storefrontMedia': media,
    'nameAr': translations['ar'] ?? display['name']?.toString() ?? '',
    'nameEng': translations['en'] ?? display['name']?.toString() ?? '',
    'nameAbree': translations['he'] ?? display['name']?.toString() ?? '',
    'isShow': true,
    'descriptionAr':
        descriptions['ar'] ?? display['description']?.toString() ?? '',
    'descriptionEng':
        descriptions['en'] ?? display['description']?.toString() ?? '',
    'descriptionAbree':
        descriptions['he'] ?? display['description']?.toString() ?? '',
    'normailPrice': _price(retail),
    'wholesalePrice': _price(wholesale),
    'stock': int.tryParse('${availability['available_qty'] ?? 0}') ?? 0,
    'availability': availability,
    'model': '',
    'isNewItem': json['is_new'] == true,
    'isMoreSales': false,
    'rate': 0.0,
    'discount': _discount(retail),
    'supCategory': const <dynamic>[],
    'normalImagesItems': legacyMedia,
    '_3DImagesItems': const <dynamic>[],
    'viewImagesItems': const <dynamic>[],
    'itemSizes': const <dynamic>[],
  });
}

num _price(dynamic value) {
  if (value is num) return value;
  if (value is Map) {
    return num.tryParse('${value['final'] ?? value['base'] ?? 0}') ?? 0;
  }
  return 0;
}

num _discount(dynamic value) {
  if (value is! Map) return 0;
  return num.tryParse('${value['discount'] ?? 0}') ?? 0;
}
