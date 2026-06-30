import 'dart:convert';

class SupCategoriesResponse {
  final List<Category> rows;
  final PaginationInfo paginationInfo;

  SupCategoriesResponse({required this.rows, required this.paginationInfo});

  factory SupCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return SupCategoriesResponse(
      rows: List<Category>.from(json['rows'].map((x) => Category.fromJson(x))),
      paginationInfo: PaginationInfo.fromJson(json['paginationInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rows': List<dynamic>.from(rows.map((x) => x.toJson())),
      'paginationInfo': paginationInfo.toJson(),
    };
  }
}

class Category {
  final int id;
  final String nameAr;
  final String nameEng;
  final String nameAbree;
  final String descriptionAr;
  final String descriptionEng;
  final String descriptionAbree;
  final String imageUrl;
  final bool isShow;
  final int mainCategoryId;
  final String? userAdd;
  final String? dateAdd;
  final String? userEdit;
  final String? dateEdit;

  Category({
    required this.id,
    required this.nameAr,
    required this.nameEng,
    required this.nameAbree,
    required this.descriptionAr,
    required this.descriptionEng,
    required this.descriptionAbree,
    required this.imageUrl,
    required this.isShow,
    required this.mainCategoryId,
    this.userAdd,
    this.dateAdd,
    this.userEdit,
    this.dateEdit,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nameAr: json['nameAr'] ?? '',
      nameEng: json['nameEng'] ?? '',
      nameAbree: json['nameAbree'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      descriptionEng: json['descriptionEng'] ?? '',
      descriptionAbree: json['descriptionAbree'] ?? '',
      imageUrl: json['imageUrl'],
      isShow: json['isShow'] ?? true,
      mainCategoryId: json['mainCategoryId'],
      userAdd: json['userAdd'],
      dateAdd: json['dateAdd'],
      userEdit: json['userEdit'],
      dateEdit: json['dateEdit'],
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
      'mainCategoryId': mainCategoryId,
      'userAdd': userAdd,
      'dateAdd': dateAdd,
      'userEdit': userEdit,
      'dateEdit': dateEdit,
    };
  }
}

class PaginationInfo {
  final int totalRowsCount;
  final int totalPagesCount;

  PaginationInfo({required this.totalRowsCount, required this.totalPagesCount});

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      totalRowsCount: json['totalRowsCount'],
      totalPagesCount: json['totalPagesCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRowsCount': totalRowsCount,
      'totalPagesCount': totalPagesCount,
    };
  }
}

SupCategoriesResponse categoriesResponseFromJson(String str) =>
    SupCategoriesResponse.fromJson(json.decode(str));

String categoriesResponseToJson(SupCategoriesResponse data) =>
    json.encode(data.toJson());
