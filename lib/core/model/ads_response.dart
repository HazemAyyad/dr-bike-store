import 'dart:convert';

class AdsResponse {
  final List<Ad> rows;
  final PaginationInfo paginationInfo;

  AdsResponse({required this.rows, required this.paginationInfo});

  factory AdsResponse.fromJson(Map<String, dynamic> json) {
    return AdsResponse(
      rows: List<Ad>.from(json['rows'].map((x) => Ad.fromJson(x))),
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

class Ad {
  final int id;
  final String title;
  final String description;
  final String urlAds;
  final String imgUrl;
  final bool isShow;
  final String addDate;
  final String userAddId;
  final String updateDate;
  final String userUpdateId;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.urlAds,
    required this.imgUrl,
    required this.isShow,
    required this.addDate,
    required this.userAddId,
    required this.updateDate,
    required this.userUpdateId,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      urlAds: json['urlAds'],
      imgUrl: json['imgUrl'],
      isShow: json['isShow'],
      addDate: json['addDate'],
      userAddId: json['userAddId'],
      updateDate: json['updateDate'],
      userUpdateId: json['userUpdateId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'urlAds': urlAds,
      'imgUrl': imgUrl,
      'isShow': isShow,
      'addDate': addDate,
      'userAddId': userAddId,
      'updateDate': updateDate,
      'userUpdateId': userUpdateId,
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

// Convert JSON string to AdsResponse object
AdsResponse adsResponseFromJson(String str) =>
    AdsResponse.fromJson(json.decode(str));

// Convert AdsResponse object to JSON string
String adsResponseToJson(AdsResponse data) => json.encode(data.toJson());
