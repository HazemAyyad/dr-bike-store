import 'package:doctor_bike/core/functions/notification_api.dart';
import 'package:doctor_bike/features/support/data/store_support_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses product context and preserves listing/product identities', () {
    final conversation = StoreSupportConversation.fromJson({
      'id': 7,
      'source': 'online_store',
      'subject': 'منتج',
      'status': 'open',
      'context_type': 'product',
      'requester_unread_count': 2,
      'messages_count': 3,
      'product_context': {
        'listing_id': 91,
        'product_id': 42,
        'name_ar': 'دراجة',
      },
    });

    expect(conversation.product?.listingId, 91);
    expect(conversation.product?.productId, 42);
    expect(conversation.unreadCount, 2);
  });

  test('support notification resolves to conversation target', () {
    final target = NotificationRouteResolver.resolve({
      'destination_type': 'support_conversation',
      'destination_id': '15',
    });

    expect(target, isA<NotificationSupportTarget>());
    expect((target as NotificationSupportTarget).conversationId, 15);
  });

  test('optimistic message keeps retry identity and failure state', () {
    const message = StoreSupportMessage(
      id: -1,
      conversationId: 3,
      clientMessageId: 'fixed-client-id',
      senderType: 'store_customer',
      body: 'مرحبا',
      attachments: [],
      delivery: StoreSupportDelivery.sending,
    );

    final failed = message.copyWith(delivery: StoreSupportDelivery.failed);
    expect(failed.clientMessageId, 'fixed-client-id');
    expect(failed.delivery, StoreSupportDelivery.failed);
  });
}
