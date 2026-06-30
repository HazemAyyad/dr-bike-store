class ReviewResponse {
  final List<Review> rows;
  final PaginationInfo paginationInfo;

  ReviewResponse({required this.rows, required this.paginationInfo});

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      rows: List<Review>.from(json['rows'].map((x) => Review.fromJson(x))),
      paginationInfo: PaginationInfo.fromJson(json['paginationInfo']),
    );
  }

  Map<String, dynamic> toJson() => {
    'rows': List<dynamic>.from(rows.map((x) => x.toJson())),
    'paginationInfo': paginationInfo.toJson(),
  };
}

class Review {
  final int id;
  final String comment;
  final int productId;
  final String productName;
  final int rate;
  final String userName;
  final String userAddId;
  final bool isShow;
  final String dateAdd;

  Review({
    required this.id,
    required this.comment,
    required this.productId,
    required this.productName,
    required this.rate,
    required this.userName,
    required this.userAddId,
    required this.isShow,
    required this.dateAdd,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    comment: json['comment'],
    productId: json['productId'],
    productName: json['productName'],
    rate: json['rate'],
    userName: json['userName'],
    userAddId: json['userAddId'],
    isShow: json['isShow'],
    dateAdd: json['dateAdd'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'comment': comment,
    'productId': productId,
    'productName': productName,
    'rate': rate,
    'userName': userName,
    'userAddId': userAddId,
    'isShow': isShow,
    'dateAdd': dateAdd,
  };
}

class PaginationInfo {
  final int totalRowsCount;
  final int totalPagesCount;

  PaginationInfo({required this.totalRowsCount, required this.totalPagesCount});

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    totalRowsCount: json['totalRowsCount'],
    totalPagesCount: json['totalPagesCount'],
  );

  Map<String, dynamic> toJson() => {
    'totalRowsCount': totalRowsCount,
    'totalPagesCount': totalPagesCount,
  };
}
