class ItemsResponse {
  final List<Item> rows;

  ItemsResponse({required this.rows});

  factory ItemsResponse.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'];
    if (rows is! List) {
      throw const FormatException('catalog.rows must be a list');
    }
    return ItemsResponse(
      rows: rows
          .map((x) {
            if (x is! Map<String, dynamic>) {
              throw const FormatException('catalog row must be an object');
            }
            return Item.fromJson(x);
          })
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'rows': List<dynamic>.from(rows.map((x) => x.toJson())),
  };
}

class Item {
  final int id;
  final int? listingId;
  final int productId;
  final String listingStatus;
  final String readinessState;
  final bool available;
  final bool purchasable;
  final List<StorefrontMedia> storefrontMedia;
  final String nameAr;
  final String nameEng;
  final String nameAbree;
  final bool isShow;
  final String descriptionAr;
  final String descriptionEng;
  final String descriptionAbree;
  final String? videoUrl;
  final double normailPrice;
  final double wholesalePrice;
  final int stock;
  final String model;
  final bool isNewItem;
  final bool isMoreSales;
  final double rate;
  final int? manufactureYear;
  final double discount;
  final String? userIdAdd;
  final DateTime? dateAdd;
  final String? userIdUpdate;
  final DateTime? dateUpdate;
  final List<SupCategory> supCategory;
  final List<NormalImageItem>? normalImagesItems;
  final List<NormalImageItem>? images3DItems;
  final List<NormalImageItem> viewImagesItems;
  final List<ItemSize> itemSizes;
  int count = 1;
  bool isSize = false;
  int? itemSizeId;
  int? itemSizeColorsStock;
  double? itemSizediscount;
  double? itemSizeColorsprice;
  int? itemSizeColorId;
  String? itemSizeColorSelect;
  String? itemSizeSelect;

  Item({
    required this.id,
    this.listingId,
    int? productId,
    this.listingStatus = 'legacy',
    this.readinessState = 'legacy',
    this.available = true,
    this.purchasable = true,
    this.storefrontMedia = const <StorefrontMedia>[],
    required this.nameAr,
    required this.nameEng,
    required this.nameAbree,
    required this.isShow,
    required this.descriptionAr,
    required this.descriptionEng,
    required this.descriptionAbree,
    this.videoUrl,
    required this.normailPrice,
    required this.wholesalePrice,
    required this.stock,
    required this.model,
    required this.isNewItem,
    required this.isMoreSales,
    required this.rate,
    this.manufactureYear,
    required this.discount,
    this.userIdAdd,
    this.dateAdd,
    this.userIdUpdate,
    this.dateUpdate,
    required this.supCategory,
    this.normalImagesItems,
    this.images3DItems,
    required this.viewImagesItems,
    required this.itemSizes,
    this.count = 1,
    this.isSize = false,
    this.itemSizeId,
    this.itemSizeColorsStock,
    this.itemSizediscount,
    this.itemSizeColorsprice,
    this.itemSizeColorId,
    this.itemSizeColorSelect,
    this.itemSizeSelect,
  }) : productId = productId ?? id;

  factory Item.fromJson(Map<String, dynamic> json) {
    final id = _requiredPositiveInt(json, 'id');
    final storefront = json.containsKey('listingStatus');
    final productId = storefront ? _requiredPositiveInt(json, 'productId') : id;
    final listingId =
        storefront
            ? _requiredPositiveInt(json, 'listingId')
            : int.tryParse(json['listingId']?.toString() ?? '');
    if (storefront && id != productId) {
      throw const FormatException('id must be the product identity');
    }
    final status =
        storefront ? _requiredString(json, 'listingStatus') : 'legacy';
    final readiness =
        storefront ? _requiredString(json, 'readinessState') : 'legacy';
    if (storefront && (status != 'published' || readiness != 'complete')) {
      throw const FormatException('listing is not storefront eligible');
    }
    final available = storefront ? _requiredBool(json, 'available') : true;
    final purchasable = storefront ? _requiredBool(json, 'purchasable') : true;
    final media = _mediaList(json['storefrontMedia'] ?? const <dynamic>[]);
    if (storefront && media.where((item) => item.isMain).length != 1) {
      throw const FormatException('storefront media requires one main item');
    }
    return Item(
      id: id,
      productId: productId,
      listingId: listingId,
      listingStatus: status,
      readinessState: readiness,
      available: available,
      purchasable: purchasable,
      storefrontMedia: media,
      nameAr: json['nameAr'] ?? "",
      nameEng: json['nameEng'] ?? "",
      nameAbree: json['nameAbree'] ?? "",
      isShow:
          storefront ? _requiredBool(json, 'isShow') : json['isShow'] == true,
      descriptionAr: json['descriptionAr'] ?? "",
      descriptionEng: json['descriptionEng'] ?? "",
      descriptionAbree: json['descriptionAbree'] ?? "",
      videoUrl: json['videoUrl'],
      normailPrice:
          storefront
              ? _requiredNumber(json, 'normailPrice').toDouble()
              : (json['normailPrice'] ?? 0).toDouble(),
      wholesalePrice: (json['wholesalePrice'] ?? 0).toDouble(),
      stock: storefront ? _requiredInt(json, 'stock') : json['stock'] ?? 0,
      model: json['model'] ?? "",
      isNewItem:
          storefront
              ? _requiredBool(json, 'isNewItem')
              : json['isNewItem'] == true,
      isMoreSales:
          storefront
              ? _requiredBool(json, 'isMoreSales')
              : json['isMoreSales'] == true,
      rate: (json['rate'] ?? 0.0).toDouble(),
      manufactureYear: json['manufactureYear'],
      discount: (json['discount'] ?? 0.0).toDouble(),
      userIdAdd: json['userIdAdd'],
      dateAdd: DateTime.tryParse(json['dateAdd']?.toString() ?? ''),
      userIdUpdate: json['userIdUpdate'],
      dateUpdate: DateTime.tryParse(json['dateUpdate']?.toString() ?? ''),

      supCategory: List<SupCategory>.from(
        json['supCategory'].map((x) => SupCategory.fromJson(x)),
      ),
      normalImagesItems:
          (json['normalImagesItems'] as List<dynamic>)
              .map((e) => NormalImageItem.fromJson(e))
              .toList(),
      images3DItems:
          (json['_3DImagesItems'] as List<dynamic>)
              .map((e) => NormalImageItem.fromJson(e))
              .toList(),
      viewImagesItems:
          (json['viewImagesItems'] as List<dynamic>)
              .map((e) => NormalImageItem.fromJson(e))
              .toList(),
      itemSizes:
          (json['itemSizes'] as List<dynamic>)
              .map((e) => ItemSize.fromJson(e))
              .toList(),
    );
  }
  factory Item.fromJson2(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      listingId: int.tryParse(json['listingId']?.toString() ?? ''),
      productId:
          int.tryParse(json['productId']?.toString() ?? '') ?? json['id'],
      listingStatus: json['listingStatus']?.toString() ?? 'published',
      readinessState: json['readinessState']?.toString() ?? 'complete',
      available: json['available'] == true,
      purchasable: json['purchasable'] == true,
      storefrontMedia: _mediaList(json['storefrontMedia'] ?? []),
      nameAr: json['nameAr'] ?? "",
      nameEng: json['nameEng'] ?? "",
      nameAbree: json['nameAbree'] ?? "",
      isShow: json['isShow'],
      descriptionAr: json['descriptionAr'] ?? "",
      descriptionEng: json['descriptionEng'] ?? "",
      descriptionAbree: json['descriptionAbree'] ?? "",
      videoUrl: json['videoUrl'],
      normailPrice: (json['normailPrice'] ?? 0).toDouble(),
      wholesalePrice: (json['wholesalePrice'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      model: json['model'] ?? "",
      isNewItem: json['isNewItem'],
      isMoreSales: json['isMoreSales'],
      rate: (json['rate'] ?? 0.0).toDouble(),
      manufactureYear: json['manufactureYear'],
      discount: (json['discount'] ?? 0.0).toDouble(),
      userIdAdd: json['userIdAdd'],
      dateAdd: DateTime.parse(json['dateAdd']),
      userIdUpdate: json['userIdUpdate'],
      dateUpdate: DateTime.parse(json['dateUpdate']),
      count: json['count'],
      isSize: json['isSize'],
      itemSizeId: json['itemSizeId'],
      itemSizeColorsStock: json['itemSizeColorsStock'],
      itemSizediscount: json['itemSizediscount'],
      itemSizeColorsprice: json['itemSizeColorsprice'],
      itemSizeColorId: json['itemSizeColorId'],
      itemSizeColorSelect: json['itemSizeColorSelect'],
      itemSizeSelect: json['itemSizeSelect'],
      supCategory: List<SupCategory>.from(
        json['supCategory'].map((x) => SupCategory.fromJson(x)),
      ),
      normalImagesItems:
          (json['normalImagesItems'] as List<dynamic>)
              .map((e) => NormalImageItem.fromJson(e))
              .toList(),
      images3DItems:
          (json['_3DImagesItems'] as List<dynamic>)
              .map((e) => NormalImageItem.fromJson(e))
              .toList(),
      viewImagesItems:
          (json['viewImagesItems'] as List<dynamic>)
              .map((e) => NormalImageItem.fromJson(e))
              .toList(),
      itemSizes:
          (json['itemSizes'] as List<dynamic>)
              .map((e) => ItemSize.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'listingId': listingId,
    'listingStatus': listingStatus,
    'readinessState': readinessState,
    'available': available,
    'purchasable': purchasable,
    'storefrontMedia': storefrontMedia.map((item) => item.toJson()).toList(),
    'nameAr': nameAr,
    'nameEng': nameEng,
    'nameAbree': nameAbree,
    'isShow': isShow,
    'descriptionAr': descriptionAr,
    'descriptionEng': descriptionEng,
    'descriptionAbree': descriptionAbree,
    'videoUrl': videoUrl,
    'normailPrice': normailPrice,
    'wholesalePrice': wholesalePrice,
    'stock': stock,
    'model': model,
    'isNewItem': isNewItem,
    'isMoreSales': isMoreSales,
    'rate': rate,
    'manufactureYear': manufactureYear,
    'discount': discount,
    'userIdAdd': userIdAdd ?? '',
    'dateAdd': dateAdd?.toIso8601String(),
    'userIdUpdate': userIdUpdate ?? '',
    'dateUpdate': dateUpdate?.toIso8601String(),
    'supCategory': List<dynamic>.from(supCategory.map((x) => x.toJson())),
    'normalImagesItems': List<dynamic>.from(
      normalImagesItems!.map((x) => x.toJson()),
    ),
    '_3DImagesItems': List<dynamic>.from(images3DItems!.map((x) => x.toJson())),
    'viewImagesItems': List<dynamic>.from(
      viewImagesItems.map((x) => x.toJson()),
    ),
    'itemSizes': (List<dynamic>.from(itemSizes.map((x) => x.toJson()))),
    "count": count,
    "isSize": isSize,
    "itemSizeId": itemSizeId,
    "itemSizeColorsStock": itemSizeColorsStock,
    "itemSizediscount": itemSizediscount,
    "itemSizeColorsprice": itemSizeColorsprice,
    "itemSizeColorId": itemSizeColorId,
    "itemSizeColorSelect": itemSizeColorSelect,
    "itemSizeSelect": itemSizeSelect,
  };
}

class StorefrontMedia {
  const StorefrontMedia({
    required this.id,
    required this.path,
    required this.sourceType,
    required this.isMain,
    required this.sortOrder,
    this.mediaMetadata,
  });

  final int id;
  final String path;
  final String sourceType;
  final bool isMain;
  final int sortOrder;
  final Map<String, dynamic>? mediaMetadata;

  factory StorefrontMedia.fromJson(Map<String, dynamic> json) {
    final path = _requiredString(json, 'path');
    final sourceType = _requiredString(json, 'source_type');
    return StorefrontMedia(
      id: _requiredPositiveInt(json, 'id'),
      path: path,
      sourceType: sourceType,
      isMain: _requiredBool(json, 'is_main'),
      sortOrder: _requiredInt(json, 'sort_order'),
      mediaMetadata:
          json['media_metadata'] is Map<String, dynamic>
              ? json['media_metadata'] as Map<String, dynamic>
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'source_type': sourceType,
    'is_main': isMain,
    'sort_order': sortOrder,
    'media_metadata': mediaMetadata,
  };
}

List<StorefrontMedia> _mediaList(dynamic value) {
  if (value is! List) {
    throw const FormatException('storefrontMedia must be a list');
  }
  final result = value
      .map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('media item must be an object');
        }
        return StorefrontMedia.fromJson(item);
      })
      .toList(growable: false)
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return result;
}

int _requiredPositiveInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int || value <= 0) {
    throw FormatException('$key must be a positive integer');
  }
  return value;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) throw FormatException('$key must be an integer');
  return value;
}

num _requiredNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num) throw FormatException('$key must be numeric');
  return value;
}

bool _requiredBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) throw FormatException('$key must be boolean');
  return value;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string');
  }
  return value;
}

class SupCategory {
  final int id;
  final String nameAr;
  final String nameEng;
  final String nameAbree;
  final String descriptionAr;
  final String descriptionEng;
  final String descriptionAbree;
  final String imageUrl;
  final bool isShow;
  final int? mainCategoryId;
  final String? userAdd;
  final DateTime? dateAdd;
  final String? userEdit;
  final DateTime? dateEdit;

  SupCategory({
    required this.id,
    required this.nameAr,
    required this.nameEng,
    required this.nameAbree,
    required this.descriptionAr,
    required this.descriptionEng,
    required this.descriptionAbree,
    required this.imageUrl,
    required this.isShow,
    this.mainCategoryId,
    required this.userAdd,
    required this.dateAdd,
    required this.userEdit,
    required this.dateEdit,
  });

  factory SupCategory.fromJson(Map<String, dynamic> json) {
    return SupCategory(
      id: json['id'],
      nameAr: json['nameAr'] ?? "",
      nameEng: json['nameEng'] ?? "",
      nameAbree: json['nameAbree'] ?? "",
      descriptionAr: json['descriptionAr'] ?? "",
      descriptionEng: json['descriptionEng'] ?? "",
      descriptionAbree: json['descriptionAbree'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
      isShow: json['isShow'],
      mainCategoryId: json['mainCategoryId'] ?? '',
      userAdd: json['userAdd'],
      dateAdd: DateTime.parse(json['dateAdd'] ?? ''),
      userEdit: json['userEdit'] ?? '',
      dateEdit: DateTime.parse(json['dateEdit'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEng': nameEng,
    'nameAbree': nameAbree,
    'descriptionAr': descriptionAr,
    'descriptionEng': descriptionEng,
    'descriptionAbree': descriptionAbree,
    'imageUrl': imageUrl,
    'isShow': isShow,
    'mainCategoryId': mainCategoryId,
    'userAdd': userAdd ?? '',
    'dateAdd': dateAdd!.toIso8601String(),
    'userEdit': userEdit ?? '',
    'dateEdit': dateEdit!.toIso8601String(),
  };
}

class NormalImageItem {
  final int id;
  final String imageUrl;
  final int itemId;

  NormalImageItem({
    required this.id,
    required this.imageUrl,
    required this.itemId,
  });

  factory NormalImageItem.fromJson(Map<String, dynamic> json) {
    return NormalImageItem(
      id: json['id'],
      imageUrl: json['imageUrl'],
      itemId: json['itemId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'itemId': itemId,
  };
}

class ItemSize {
  final int? id;
  final int? itemId;
  final String size;
  final double? discount;
  final String? description;
  final List<ItemSizeColor> itemSizeColor;

  ItemSize({
    this.id,
    this.itemId,
    required this.size,
    this.discount,
    this.description,
    required this.itemSizeColor,
  });

  factory ItemSize.fromJson(Map<String, dynamic> json) {
    return ItemSize(
      id: json['id'],
      itemId: json['itemId'],
      size: json['size'] ?? "",
      discount:
          json['discount'] != null
              ? (json['discount'] as num).toDouble()
              : null,
      description: json['description'] ?? '',
      itemSizeColor: List<ItemSizeColor>.from(
        json['itemSizeColor'].map((x) => ItemSizeColor.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'size': size,
    'discount': discount,
    'description': description,
    'itemSizeColor': List<dynamic>.from(itemSizeColor.map((x) => x.toJson())),
  };
}

class ItemSizeColor {
  final int? id;
  final int? sizeId;
  final String colorAr;
  final String? colorEn;
  final String? colorAbbr;
  final double? normailPrice;
  final double? wholesalePrice;
  final double? discount;
  final int? stock;

  ItemSizeColor({
    this.id,
    this.sizeId,
    required this.colorAr,
    this.colorEn,
    this.colorAbbr,
    this.normailPrice,
    this.wholesalePrice,
    this.discount,
    this.stock,
  });

  factory ItemSizeColor.fromJson(Map<String, dynamic> json) {
    return ItemSizeColor(
      id: json['id'],
      sizeId: json['sizeId'],
      colorAr: json['colorAr'] ?? "",
      colorEn: json['colorEn'] ?? "",
      colorAbbr: json['colorAbbr'] ?? "",
      normailPrice:
          json['normailPrice'] != null
              ? (json['normailPrice'] as num).toDouble()
              : null,
      wholesalePrice:
          json['wholesalePrice'] != null
              ? (json['wholesalePrice'] as num).toDouble()
              : null,
      discount:
          json['discount'] != null
              ? (json['discount'] as num).toDouble()
              : null,
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sizeId': sizeId,
    'colorAr': colorAr,
    'colorEn': colorEn,
    'colorAbbr': colorAbbr,
    'normailPrice': normailPrice,
    'wholesalePrice': wholesalePrice,
    'discount': discount,
    'stock': stock,
  };
}
