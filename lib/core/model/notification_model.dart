class NotificationResponse {
  final List<NotificationItem> rows;
  final PaginationInfo paginationInfo;

  NotificationResponse({required this.rows, required this.paginationInfo});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      rows: List<NotificationItem>.from(
        (json["rows"] ?? []).map((x) => NotificationItem.fromJson(x)),
      ),
      paginationInfo: PaginationInfo.fromJson(
        json["paginationInfo"] as Map<String, dynamic>? ??
            {
              "totalRowsCount": json["total"] ?? json["totalNotFiltered"] ?? 0,
              "totalPagesCount": 0,
            },
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "rows": List<dynamic>.from(rows.map((x) => x.toJson())),
      "paginationInfo": paginationInfo.toJson(),
    };
  }
}

class NotificationItem {
  final int id;
  final bool isRead;
  final String title;
  final String content;
  final String toUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationItem({
    required this.id,
    required this.isRead,
    required this.title,
    required this.content,
    required this.toUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: int.tryParse(json["id"]?.toString() ?? '') ?? 0,
      isRead: json["isRead"] == true,
      title: json["title"]?.toString() ?? '',
      content: json["content"]?.toString() ?? '',
      toUser: json["toUser"]?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json["createdAt"]?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json["updatedAt"]?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "isRead": isRead,
      "title": title,
      "content": content,
      "toUser": toUser,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
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
          int.tryParse(json["totalRowsCount"]?.toString() ?? '') ?? 0,
      totalPagesCount:
          int.tryParse(json["totalPagesCount"]?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "totalRowsCount": totalRowsCount,
      "totalPagesCount": totalPagesCount,
    };
  }
}
