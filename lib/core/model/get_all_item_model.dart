class ItemsResponse {
  final List<Item> rows;

  ItemsResponse({required this.rows});

  factory ItemsResponse.fromJson(Map<String, dynamic> json) {
    return ItemsResponse(
      rows: List<Item>.from(json['rows'].map((x) => Item.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    'rows': List<dynamic>.from(rows.map((x) => x.toJson())),
  };
}

class Item {
  final int id;
  final int? listingId;
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
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      listingId: int.tryParse(json['listingId']?.toString() ?? ''),
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
    'listingId': listingId,
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
