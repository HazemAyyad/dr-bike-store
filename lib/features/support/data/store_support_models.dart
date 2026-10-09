enum StoreSupportDelivery { sent, sending, failed }

class StoreSupportProductContext {
  const StoreSupportProductContext({
    required this.listingId,
    required this.productId,
    required this.name,
    this.imageUrl,
    this.model,
  });

  final int listingId;
  final int productId;
  final String name;
  final String? imageUrl;
  final String? model;

  factory StoreSupportProductContext.fromJson(Map<String, dynamic> json) =>
      StoreSupportProductContext(
        listingId: _asInt(json['listing_id']),
        productId: _asInt(json['product_id']),
        name:
            (json['name_ar'] ?? json['name_en'] ?? json['name_he'] ?? '')
                .toString(),
        imageUrl: json['primary_image']?.toString(),
        model: json['model']?.toString(),
      );
}

class StoreSupportConversation {
  const StoreSupportConversation({
    required this.id,
    required this.subject,
    required this.status,
    required this.contextType,
    required this.lastMessage,
    required this.unreadCount,
    required this.messagesCount,
    this.product,
    this.lastMessageAt,
  });

  final int id;
  final String subject;
  final String status;
  final String contextType;
  final String lastMessage;
  final int unreadCount;
  final int messagesCount;
  final StoreSupportProductContext? product;
  final DateTime? lastMessageAt;

  bool get isClosed => status == 'closed';

  factory StoreSupportConversation.fromJson(Map<String, dynamic> json) {
    final productJson = json['product_context'];
    return StoreSupportConversation(
      id: _asInt(json['id']),
      subject: (json['subject'] ?? 'محادثة دعم').toString(),
      status: (json['status'] ?? 'open').toString(),
      contextType: (json['context_type'] ?? 'general').toString(),
      lastMessage: (json['last_message'] ?? '').toString(),
      unreadCount: _asInt(json['requester_unread_count']),
      messagesCount: _asInt(json['messages_count']),
      product:
          productJson is Map
              ? StoreSupportProductContext.fromJson(
                Map<String, dynamic>.from(productJson),
              )
              : null,
      lastMessageAt: DateTime.tryParse(
        (json['last_message_at'] ?? '').toString(),
      ),
    );
  }
}

class StoreSupportAttachment {
  const StoreSupportAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.name,
  });

  final int id;
  final String type;
  final String url;
  final String? name;

  factory StoreSupportAttachment.fromJson(Map<String, dynamic> json) =>
      StoreSupportAttachment(
        id: _asInt(json['id']),
        type: (json['type'] ?? 'document').toString(),
        url: (json['url'] ?? '').toString(),
        name: json['original_name']?.toString(),
      );
}

class StoreSupportMessage {
  const StoreSupportMessage({
    required this.id,
    required this.conversationId,
    required this.clientMessageId,
    required this.senderType,
    required this.body,
    required this.attachments,
    required this.delivery,
    this.createdAt,
    this.localImagePath,
  });

  final int id;
  final int conversationId;
  final String clientMessageId;
  final String senderType;
  final String body;
  final List<StoreSupportAttachment> attachments;
  final StoreSupportDelivery delivery;
  final DateTime? createdAt;
  final String? localImagePath;

  bool get isMine => senderType == 'store_customer';

  StoreSupportMessage copyWith({
    int? id,
    StoreSupportDelivery? delivery,
    List<StoreSupportAttachment>? attachments,
  }) => StoreSupportMessage(
    id: id ?? this.id,
    conversationId: conversationId,
    clientMessageId: clientMessageId,
    senderType: senderType,
    body: body,
    attachments: attachments ?? this.attachments,
    delivery: delivery ?? this.delivery,
    createdAt: createdAt,
    localImagePath: localImagePath,
  );

  factory StoreSupportMessage.fromJson(Map<String, dynamic> json) =>
      StoreSupportMessage(
        id: _asInt(json['id']),
        conversationId: _asInt(json['conversation_id']),
        clientMessageId: (json['client_message_id'] ?? '').toString(),
        senderType: (json['sender_type'] ?? '').toString(),
        body: (json['body'] ?? '').toString(),
        attachments:
            (json['attachments'] as List? ?? const [])
                .whereType<Map>()
                .map(
                  (row) => StoreSupportAttachment.fromJson(
                    Map<String, dynamic>.from(row),
                  ),
                )
                .toList(),
        delivery: StoreSupportDelivery.sent,
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      );
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
