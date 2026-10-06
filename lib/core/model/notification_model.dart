enum NotificationCategory { order, promotion, unknown }

enum NotificationDestinationType { order, product, unknown }

class NotificationDestination {
  const NotificationDestination({required this.type, required this.id});

  final NotificationDestinationType type;
  final int id;

  static NotificationDestination? fromJson(Map<String, dynamic> json) {
    final rawType =
        (json['destination_type'] ?? json['destinationType'])
            ?.toString()
            .trim()
            .toLowerCase();
    final type = switch (rawType) {
      'order' => NotificationDestinationType.order,
      'product' => NotificationDestinationType.product,
      _ => NotificationDestinationType.unknown,
    };
    if (type == NotificationDestinationType.unknown) return null;
    final rawId =
        json['destination_id'] ??
        json['destinationId'] ??
        (type == NotificationDestinationType.order
            ? json['order_id']
            : json['product_id']);
    final id = int.tryParse(rawId?.toString() ?? '');
    return id != null && id > 0
        ? NotificationDestination(type: type, id: id)
        : null;
  }
}

class NotificationResponse {
  const NotificationResponse({
    required this.rows,
    required this.paginationInfo,
  });

  final List<NotificationItem> rows;
  final PaginationInfo paginationInfo;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'];
    if (rawRows is! List) throw const FormatException('notifications.rows');
    return NotificationResponse(
      rows: rawRows
          .whereType<Map>()
          .map(
            (row) => NotificationItem.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false),
      paginationInfo: PaginationInfo.fromJson(
        json['paginationInfo'] is Map
            ? Map<String, dynamic>.from(json['paginationInfo'] as Map)
            : <String, dynamic>{
              'totalRowsCount': json['total'] ?? rawRows.length,
            },
      ),
    );
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.isRead,
    required this.title,
    required this.content,
    required this.toUser,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.destination,
  });

  final int id;
  final bool isRead;
  final String title;
  final String content;
  final String toUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final NotificationCategory category;
  final NotificationDestination? destination;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse(json['id']?.toString() ?? '');
    if (id == null || id <= 0) throw const FormatException('notification.id');
    final rawCategory =
        (json['category'] ?? json['type'])?.toString().toLowerCase();
    final category = switch (rawCategory) {
      'order' || 'order_status' => NotificationCategory.order,
      'promotion' || 'offer' => NotificationCategory.promotion,
      _ => NotificationCategory.unknown,
    };
    return NotificationItem(
      id: id,
      isRead: json['isRead'] == true || json['is_read'] == true,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      toUser: json['toUser']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      category: category,
      destination: NotificationDestination.fromJson(json),
    );
  }

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
    id: id,
    isRead: isRead ?? this.isRead,
    title: title,
    content: content,
    toUser: toUser,
    createdAt: createdAt,
    updatedAt: updatedAt,
    category: category,
    destination: destination,
  );
}

class PaginationInfo {
  const PaginationInfo({
    required this.totalRowsCount,
    required this.totalPagesCount,
  });
  final int totalRowsCount;
  final int totalPagesCount;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    totalRowsCount: int.tryParse(json['totalRowsCount']?.toString() ?? '') ?? 0,
    totalPagesCount:
        int.tryParse(json['totalPagesCount']?.toString() ?? '') ?? 0,
  );
}
