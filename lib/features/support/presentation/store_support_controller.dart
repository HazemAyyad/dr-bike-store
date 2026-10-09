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
  bool supportIsTyping = false;
  Timer? _fallbackTimer;
  Timer? _typingIdleTimer;
  Timer? _remoteTypingTimer;
  DateTime? _lastTypingSignal;
  bool _typingSent = false;

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
    _clearRemoteTyping();
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
    stopTyping();
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

  void composerChanged(String value) {
    final conversation = activeConversation;
    if (conversation == null || conversation.isClosed) return;
    if (value.trim().isEmpty) {
      stopTyping();
      return;
    }

    final now = DateTime.now();
    if (!_typingSent ||
        _lastTypingSignal == null ||
        now.difference(_lastTypingSignal!) >= const Duration(seconds: 2)) {
      _typingSent = true;
      _lastTypingSignal = now;
      unawaited(repository.setTyping(conversation.id, true).catchError((_) {}));
    }
    _typingIdleTimer?.cancel();
    _typingIdleTimer = Timer(const Duration(seconds: 3), stopTyping);
  }

  void stopTyping() {
    _typingIdleTimer?.cancel();
    final conversationId = activeConversation?.id;
    if (!_typingSent || conversationId == null) return;
    _typingSent = false;
    _lastTypingSignal = null;
    unawaited(repository.setTyping(conversationId, false).catchError((_) {}));
  }

  void _onRealtimePayload(Map<String, dynamic> payload) {
    if (payload['actor_type']?.toString() == 'support' &&
        payload.containsKey('is_typing')) {
      _setRemoteTyping(payload['is_typing'] == true);
      return;
    }
    final rawMessage = payload['message'];
    final rawConversation = payload['conversation'];
    if (rawConversation is Map) {
      activeConversation = StoreSupportConversation.fromJson(
        Map<String, dynamic>.from(rawConversation),
      );
    }
    if (rawMessage is Map) {
      final message = StoreSupportMessage.fromJson(
        Map<String, dynamic>.from(rawMessage),
      );
      if (!message.isMine) _clearRemoteTyping();
      _merge([message]);
      final id = activeConversation?.id;
      if (id != null) unawaited(repository.markRead(id));
    }
    update();
  }

  void _setRemoteTyping(bool value) {
    _remoteTypingTimer?.cancel();
    supportIsTyping = value;
    if (value) {
      _remoteTypingTimer = Timer(
        const Duration(seconds: 6),
        _clearRemoteTyping,
      );
    }
    update();
  }

  void _clearRemoteTyping() {
    _remoteTypingTimer?.cancel();
    if (!supportIsTyping) return;
    supportIsTyping = false;
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
    _typingIdleTimer?.cancel();
    _remoteTypingTimer?.cancel();
    stopTyping();
    unawaited(realtime.dispose());
    super.onClose();
  }
}
