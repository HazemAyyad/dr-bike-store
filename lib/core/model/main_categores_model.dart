import 'dart:convert';

class MainCategoresModel {
  final List<Category> rows;
  final PaginationInfo paginationInfo;

  MainCategoresModel({required this.rows, required this.paginationInfo});

  factory MainCategoresModel.fromJson(Map<String, dynamic> json) {
    return MainCategoresModel(
      rows: List<Category>.from(
        (json['rows'] ?? []).map((x) => Category.fromJson(x)),
      ),
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

class Category {
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
  List<dynamic> supCategories;

  Category({
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
    required this.supCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nameAr: json['nameAr']?.toString() ?? '',
      nameEng: json['nameEng']?.toString() ?? '',
      nameAbree: json['nameAbree']?.toString() ?? '',
      descriptionAr: json['descriptionAr']?.toString(),
      descriptionEng: json['descriptionEng']?.toString(),
      descriptionAbree: json['descriptionAbree']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      isShow: json['isShow'] != false,
      userAdd: json['userAdd']?.toString() ?? '',
      dateAdd: json['dateAdd']?.toString() ?? '',
      userEdit: json['userEdit']?.toString() ?? '',
      dateEdit: json['dateEdit']?.toString() ?? '',
      supCategories: json['supCategories'] ?? [],
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
      'supCategories': supCategories,
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
MainCategoresModel categoriesResponseFromJson(String str) =>
    MainCategoresModel.fromJson(json.decode(str));

// Convert CategoriesResponse object to JSON string
String categoriesResponseToJson(MainCategoresModel data) =>
    json.encode(data.toJson());
