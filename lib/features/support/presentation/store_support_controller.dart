import 'dart:async';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../data/store_support_models.dart';
import '../data/store_support_realtime_service.dart';
import '../data/store_support_repository.dart';

class StoreSupportController extends GetxController {
  StoreSupportController({required this.repository});

  final StoreSupportRepository repository;
  final _uuid = const Uuid();
  late final StoreSupportRealtimeService realtime;

  List<StoreSupportConversation> conversations = const [];
  StoreSupportConversation? activeConversation;
  List<StoreSupportMessage> messages = const [];
  bool loadingInbox = false;
  bool loadingConversation = false;
  bool creating = false;
  String? error;
  StoreSupportConnectionState connectionState =
      StoreSupportConnectionState.disconnected;
  Timer? _fallbackTimer;

  int get unreadCount =>
      conversations.fold(0, (sum, row) => sum + row.unreadCount);

  @override
  void onInit() {
    super.onInit();
    realtime = StoreSupportRealtimeService(
      onPayload: _onRealtimePayload,
      onStateChanged: (state) {
        connectionState = state;
        _configureFallback();
        update();
      },
      onReconnect: refreshActive,
    );
  }

  Future<void> loadInbox() async {
    loadingInbox = true;
    error = null;
    update();
    try {
      conversations = await repository.conversations();
    } catch (exception) {
      error = exception.toString();
    } finally {
      loadingInbox = false;
      update();
    }
  }

  Future<StoreSupportConversation?> createConversation({
    required String text,
    int? listingId,
    String? imagePath,
  }) async {
    creating = true;
    error = null;
    update();
    try {
      final result = await repository.create(
        contextType: listingId == null ? 'general' : 'product',
        text: text.trim(),
        clientMessageId: _uuid.v4(),
        listingId: listingId,
        imagePath: imagePath,
      );
      await loadInbox();
      return result.conversation;
    } catch (exception) {
      error = exception.toString();
      return null;
    } finally {
      creating = false;
      update();
    }
  }

  Future<void> openConversation(int id) async {
    loadingConversation = true;
    error = null;
    update();
    try {
      final result = await repository.detail(id);
      activeConversation = result.conversation;
      messages = result.messages;
      await repository.markRead(id);
      await realtime.watchConversation(id);
      _configureFallback();
    } catch (exception) {
      error = exception.toString();
    } finally {
      loadingConversation = false;
      update();
    }
  }

  Future<void> refreshActive() async {
    final id = activeConversation?.id;
    if (id == null) return;
    try {
      final after = messages.where((row) => row.id > 0).lastOrNull?.id;
      final result = await repository.detail(id, afterId: after);
      activeConversation = result.conversation;
      _merge(result.messages);
      await repository.markRead(id);
      update();
    } catch (_) {}
  }

  Future<void> send(String text, {String? imagePath, String? retryId}) async {
    final conversation = activeConversation;
    if (conversation == null || conversation.isClosed) return;
    final body = text.trim();
    if (body.isEmpty && imagePath == null) return;
    final clientId = retryId ?? _uuid.v4();
    final optimistic = StoreSupportMessage(
      id: -DateTime.now().microsecondsSinceEpoch,
      conversationId: conversation.id,
      clientMessageId: clientId,
      senderType: 'store_customer',
      body: body,
      attachments: const [],
      delivery: StoreSupportDelivery.sending,
      createdAt: DateTime.now(),
      localImagePath: imagePath,
    );
    messages = [
      ...messages.where((row) => row.clientMessageId != clientId),
      optimistic,
    ];
    update();
    try {
      final sent = await repository.send(
        conversationId: conversation.id,
        text: body,
        clientMessageId: clientId,
        imagePath: imagePath,
      );
      messages = [
        ...messages.where((row) => row.clientMessageId != clientId),
        sent,
      ]..sort(_messageOrder);
      update();
    } catch (_) {
      messages =
          messages
              .map(
                (row) =>
                    row.clientMessageId == clientId
                        ? row.copyWith(delivery: StoreSupportDelivery.failed)
                        : row,
              )
              .toList();
      update();
    }
  }

  Future<void> retry(StoreSupportMessage message) => send(
    message.body,
    imagePath: message.localImagePath,
    retryId: message.clientMessageId,
  );

  void _onRealtimePayload(Map<String, dynamic> payload) {
    final rawMessage = payload['message'];
    final rawConversation = payload['conversation'];
    if (rawConversation is Map) {
      activeConversation = StoreSupportConversation.fromJson(
        Map<String, dynamic>.from(rawConversation),
      );
    }
    if (rawMessage is Map) {
      _merge([
        StoreSupportMessage.fromJson(Map<String, dynamic>.from(rawMessage)),
      ]);
      final id = activeConversation?.id;
      if (id != null) unawaited(repository.markRead(id));
    }
    update();
  }

  void _merge(List<StoreSupportMessage> incoming) {
    final merged = <String, StoreSupportMessage>{};
    for (final message in [...messages, ...incoming]) {
      final key =
          message.clientMessageId.isNotEmpty
              ? message.clientMessageId
              : 'id:${message.id}';
      merged[key] = message;
    }
    messages = merged.values.toList()..sort(_messageOrder);
  }

  void _configureFallback() {
    _fallbackTimer?.cancel();
    if (activeConversation == null ||
        connectionState == StoreSupportConnectionState.connected) {
      return;
    }
    _fallbackTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => refreshActive(),
    );
  }

  static int _messageOrder(StoreSupportMessage a, StoreSupportMessage b) {
    final time = (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    return time != 0 ? time : a.id.compareTo(b.id);
  }

  @override
  void onClose() {
    _fallbackTimer?.cancel();
    unawaited(realtime.dispose());
    super.onClose();
  }
}
