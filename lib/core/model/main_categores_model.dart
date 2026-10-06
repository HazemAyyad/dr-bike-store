import 'dart:convert';

class OnlineStoreCategoriesResponse {
  final List<OnlineStoreCategory> rows;
  final PaginationInfo paginationInfo;

  OnlineStoreCategoriesResponse({
    required this.rows,
    required this.paginationInfo,
  });

  factory OnlineStoreCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'];
    if (rows is! List) {
      throw const FormatException('categories.rows must be a list');
    }
    return OnlineStoreCategoriesResponse(
      rows: rows
          .map((x) {
            if (x is! Map<String, dynamic>) {
              throw const FormatException('category must be an object');
            }
            return OnlineStoreCategory.fromJson(x);
          })
          .toList(growable: false),
      paginationInfo: PaginationInfo.fromJson(
        json['paginationInfo'] as Map<String, dynamic>? ??
            {
              'totalRowsCount': json['total'] ?? json['totalNotFiltered'] ?? 0,
              'totalPagesCount': 0,
            },
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rows': List<dynamic>.from(rows.map((x) => x.toJson())),
      'paginationInfo': paginationInfo.toJson(),
    };
  }
}

class OnlineStoreCategory {
  int id;
  String nameAr;
  String nameEng;
  String nameAbree;
  String? descriptionAr;
  String? descriptionEng;
  String? descriptionAbree;
  String imageUrl;
  bool isShow;
  String userAdd;
  String dateAdd;
  String userEdit;
  String dateEdit;
  List<OnlineStoreCategory> children;

  OnlineStoreCategory({
    required this.id,
    required this.nameAr,
    required this.nameEng,
    required this.nameAbree,
    this.descriptionAr,
    this.descriptionEng,
    this.descriptionAbree,
    required this.imageUrl,
    required this.isShow,
    required this.userAdd,
    required this.dateAdd,
    required this.userEdit,
    required this.dateEdit,
    required this.children,
  });

  factory OnlineStoreCategory.fromJson(Map<String, dynamic> json) {
    final id = json['categoryId'] ?? json['id'];
    if (id is! int || id <= 0) {
      throw const FormatException('categoryId must be a positive integer');
    }
    if (json.containsKey('store_section_id')) {
      throw const FormatException('store_section_id is not a catalog identity');
    }
    if (json['isShow'] is! bool) {
      throw const FormatException('category visibility must be boolean');
    }
    final rawChildren = json['children'] ?? json['supCategories'] ?? const [];
    if (rawChildren is! List) {
      throw const FormatException('category children must be a list');
    }
    return OnlineStoreCategory(
      id: id,
      nameAr: json['nameAr']?.toString() ?? '',
      nameEng: json['nameEng']?.toString() ?? '',
      nameAbree: json['nameAbree']?.toString() ?? '',
      descriptionAr: json['descriptionAr']?.toString(),
      descriptionEng: json['descriptionEng']?.toString(),
      descriptionAbree: json['descriptionAbree']?.toString(),
      imageUrl: json['imageUrl'] is String ? json['imageUrl'] as String : '',
      isShow: json['isShow'] as bool,
      userAdd: json['userAdd']?.toString() ?? '',
      dateAdd: json['dateAdd']?.toString() ?? '',
      userEdit: json['userEdit']?.toString() ?? '',
      dateEdit: json['dateEdit']?.toString() ?? '',
      children: rawChildren
          .map((child) {
            if (child is! Map<String, dynamic>) {
              throw const FormatException('category child must be an object');
            }
            return OnlineStoreCategory.fromJson(child);
          })
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEng': nameEng,
      'nameAbree': nameAbree,
      'descriptionAr': descriptionAr,
      'descriptionEng': descriptionEng,
      'descriptionAbree': descriptionAbree,
      'imageUrl': imageUrl,
      'isShow': isShow,
      'userAdd': userAdd,
      'dateAdd': dateAdd,
      'userEdit': userEdit,
      'dateEdit': dateEdit,
      'children': children.map((child) => child.toJson()).toList(),
      'supCategories': children.map((child) => child.toJson()).toList(),
    };
  }
}

class PaginationInfo {
  final int totalRowsCount;
  final int totalPagesCount;

  PaginationInfo({required this.totalRowsCount, required this.totalPagesCount});

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      totalRowsCount:
          int.tryParse(json['totalRowsCount']?.toString() ?? '') ?? 0,
      totalPagesCount:
          int.tryParse(json['totalPagesCount']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRowsCount': totalRowsCount,
      'totalPagesCount': totalPagesCount,
    };
  }
}

// Convert JSON string to CategoriesResponse object
typedef MainCategoresModel = OnlineStoreCategoriesResponse;
typedef Category = OnlineStoreCategory;

OnlineStoreCategoriesResponse categoriesResponseFromJson(String str) =>
    OnlineStoreCategoriesResponse.fromJson(json.decode(str));

// Convert CategoriesResponse object to JSON string
String categoriesResponseToJson(OnlineStoreCategoriesResponse data) =>
    json.encode(data.toJson());
