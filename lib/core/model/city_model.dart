class CitiesResponse {
  List<Citys> rows;
  PaginationInfo paginationInfo;

  CitiesResponse({required this.rows, required this.paginationInfo});

  factory CitiesResponse.fromJson(Map<String, dynamic> json) => CitiesResponse(
    rows:
        List<Citys>.from((json["rows"] ?? []).map((x) => Citys.fromJson(x)))
            .where((city) => city.isShow)
            .toList(), // Filtering cities where isShow == true
    paginationInfo: PaginationInfo.fromJson(
      json["paginationInfo"] as Map<String, dynamic>? ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
    "paginationInfo": paginationInfo.toJson(),
  };
}

class Citys {
  int id;
  String cityNameAr;
  String cityNameEng;
  String cityNameAbree;
  double deliver;
  bool isShow;
  String? userIdAdd;
  String dateAdd;
  String? userUpdate;
  String dateUpdate;

  Citys({
    required this.id,
    required this.cityNameAr,
    required this.cityNameEng,
    required this.cityNameAbree,
    required this.deliver,
    required this.isShow,
    this.userIdAdd,
    required this.dateAdd,
    this.userUpdate,
    required this.dateUpdate,
  });

  factory Citys.fromJson(Map<String, dynamic> json) => Citys(
    id: int.tryParse(json["id"]?.toString() ?? '') ?? 0,
    cityNameAr: json["cityNameAr"]?.toString() ?? '',
    cityNameEng: json["cityNameEng"]?.toString() ?? '',
    cityNameAbree: json["cityNameAbree"]?.toString() ?? '',
    deliver: (json["deliver"] as num?)?.toDouble() ?? 0.0,
    isShow: json["isShow"] != false,
    userIdAdd: json["userIdAdd"],
    dateAdd: json["dateAdd"]?.toString() ?? '',
    userUpdate: json["userUpdate"],
    dateUpdate: json["dateUpdate"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cityNameAr": cityNameAr,
    "cityNameEng": cityNameEng,
    "cityNameAbree": cityNameAbree,
    "deliver": deliver,
    "isShow": isShow,
    "userIdAdd": userIdAdd,
    "dateAdd": dateAdd,
    "userUpdate": userUpdate,
    "dateUpdate": dateUpdate,
  };
}

class PaginationInfo {
  int totalRowsCount;
  int totalPagesCount;

  PaginationInfo({required this.totalRowsCount, required this.totalPagesCount});

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    totalRowsCount: int.tryParse(json["totalRowsCount"]?.toString() ?? '') ?? 0,
    totalPagesCount:
        int.tryParse(json["totalPagesCount"]?.toString() ?? '') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "totalRowsCount": totalRowsCount,
    "totalPagesCount": totalPagesCount,
  };
}

class VillagesResponse {
  List<ShiplyVillage> rows;

  VillagesResponse({required this.rows});

  factory VillagesResponse.fromJson(Map<String, dynamic> json) =>
      VillagesResponse(
        rows: List<ShiplyVillage>.from(
          (json["rows"] ?? []).map((x) => ShiplyVillage.fromJson(x)),
        ),
      );
}

class ShiplyVillage {
  int id;
  String name;
  String? note;
  bool isClosed;

  ShiplyVillage({
    required this.id,
    required this.name,
    this.note,
    required this.isClosed,
  });

  factory ShiplyVillage.fromJson(Map<String, dynamic> json) => ShiplyVillage(
    id: json["id"],
    name: json["name"]?.toString() ?? '',
    note: json["note"]?.toString(),
    isClosed: json["isClosed"] == true,
  );
}
