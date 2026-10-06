enum ReviewStatus { pending, published, rejected, unknown }

class ReviewResponse {
  const ReviewResponse({required this.rows, required this.paginationInfo});
  final List<Review> rows;
  final ReviewPaginationInfo paginationInfo;

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['rows'];
    if (raw is! List) throw const FormatException('reviews.rows');
    return ReviewResponse(
      rows:
          raw
              .whereType<Map>()
              .map(
                (row) => Review.fromPublicJson(Map<String, dynamic>.from(row)),
              )
              .toList(),
      paginationInfo: ReviewPaginationInfo.fromJson(
        json['paginationInfo'] is Map
            ? Map<String, dynamic>.from(json['paginationInfo'])
            : const {},
      ),
    );
  }
}

class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.status,
    required this.isVerifiedPurchase,
    this.userName = '',
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int productId;
  final int rating;
  final String? comment;
  final ReviewStatus status;
  final bool isVerifiedPurchase;
  final String userName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get rate => rating;
  bool get isShow => status == ReviewStatus.published;
  String get dateAdd => createdAt?.toIso8601String() ?? '';
  bool get canEdit => status == ReviewStatus.pending;

  factory Review.fromPublicJson(Map<String, dynamic> json) =>
      _parse(json, isPublic: true);
  factory Review.fromOwnJson(Map<String, dynamic> json) =>
      _parse(json, isPublic: false);
  factory Review.fromJson(Map<String, dynamic> json) =>
      Review.fromPublicJson(json);

  static Review _parse(Map<String, dynamic> json, {required bool isPublic}) {
    final id = int.tryParse(json['id']?.toString() ?? '');
    final productId = int.tryParse(
      (json['product_id'] ?? json['productId'])?.toString() ?? '',
    );
    final rating = int.tryParse(
      (json['rating'] ?? json['rate'])?.toString() ?? '',
    );
    if (id == null ||
        id <= 0 ||
        productId == null ||
        productId <= 0 ||
        rating == null ||
        rating < 1 ||
        rating > 5) {
      throw const FormatException('review identity/rating');
    }
    final rawStatus = json['status']?.toString().toLowerCase();
    final status =
        isPublic
            ? ReviewStatus.published
            : switch (rawStatus) {
              'pending' => ReviewStatus.pending,
              'published' => ReviewStatus.published,
              'rejected' => ReviewStatus.rejected,
              _ => ReviewStatus.unknown,
            };
    return Review(
      id: id,
      productId: productId,
      rating: rating,
      comment: json['comment']?.toString(),
      status: status,
      isVerifiedPurchase: json['is_verified_purchase'] == true,
      userName: json['userName']?.toString() ?? '',
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['dateAdd'])?.toString() ?? '',
      ),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class ReviewPaginationInfo {
  const ReviewPaginationInfo({
    required this.totalRowsCount,
    required this.totalPagesCount,
  });
  final int totalRowsCount;
  final int totalPagesCount;
  factory ReviewPaginationInfo.fromJson(Map<String, dynamic> json) =>
      ReviewPaginationInfo(
        totalRowsCount:
            int.tryParse(json['totalRowsCount']?.toString() ?? '') ?? 0,
        totalPagesCount:
            int.tryParse(json['totalPagesCount']?.toString() ?? '') ?? 0,
      );
}
