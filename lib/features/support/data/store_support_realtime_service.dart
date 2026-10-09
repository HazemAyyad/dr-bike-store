import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/functions/app_usage_service.dart';

enum StoreSupportConnectionState { disconnected, connecting, connected }

class StoreSupportRealtimeService {
  StoreSupportRealtimeService({
    this.onPayload,
    this.onStateChanged,
    this.onReconnect,
  });

  static const _key = String.fromEnvironment('REVERB_APP_KEY');
  static const _host = String.fromEnvironment('REVERB_HOST');
  static const _scheme = String.fromEnvironment(
    'REVERB_SCHEME',
    defaultValue: 'wss',
  );
  static const _port = int.fromEnvironment('REVERB_PORT', defaultValue: 443);

  final void Function(Map<String, dynamic> payload)? onPayload;
  final void Function(StoreSupportConnectionState state)? onStateChanged;
  final Future<void> Function()? onReconnect;

  WebSocketChannel? _socket;
  StreamSubscription<dynamic>? _subscription;
  Timer? _retryTimer;
  Timer? _pingTimer;
  int? _conversationId;
  String? _socketId;
  bool _disposed = false;
  int _attempt = 0;

  bool get isConfigured => _key.isNotEmpty;

  Future<void> watchConversation(int conversationId) async {
    _conversationId = conversationId;
    _disposed = false;
    await _connect();
  }

  Future<void> _connect() async {
    if (_disposed || _conversationId == null || !isConfigured) {
      onStateChanged?.call(StoreSupportConnectionState.disconnected);
      return;
    }
    onStateChanged?.call(StoreSupportConnectionState.connecting);
    await _subscription?.cancel();
    await _socket?.sink.close();
    final fallbackHost = Uri.parse(AppConstants.appBaseUrl).host;
    final host = _host.isEmpty ? fallbackHost : _host;
    final uri = Uri(
      scheme: _scheme,
      host: host,
      port: _port,
      path: '/app/$_key',
      queryParameters: const {
        'protocol': '7',
        'client': 'doctor-bike-store',
        'version': '1.0',
        'flash': 'false',
      },
    );
    try {
      final socket = WebSocketChannel.connect(uri);
      _socket = socket;
      await socket.ready;
      _subscription = socket.stream.listen(
        _handleFrame,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  Future<void> _handleFrame(dynamic frame) async {
    final decoded = jsonDecode(frame.toString());
    if (decoded is! Map) return;
    final event = decoded['event']?.toString();
    dynamic data = decoded['data'];
    if (data is String && data.isNotEmpty) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (event == 'pusher:connection_established' && data is Map) {
      _socketId = data['socket_id']?.toString();
      await _subscribe();
      return;
    }
    if (event == 'pusher:ping') {
      _send({'event': 'pusher:pong', 'data': const {}});
      return;
    }
    if (event == 'pusher_internal:subscription_succeeded') {
      final reconnected = _attempt > 0;
      _attempt = 0;
      onStateChanged?.call(StoreSupportConnectionState.connected);
      _startPing();
      if (reconnected) await onReconnect?.call();
      return;
    }
    if ((event == 'support.message.created' ||
            event == 'support.conversation.read') &&
        data is Map) {
      onPayload?.call(Map<String, dynamic>.from(data));
    }
  }

  Future<void> _subscribe() async {
    final socketId = _socketId;
    final conversationId = _conversationId;
    if (socketId == null || conversationId == null) return;
    final channel = 'private-support.conversation.$conversationId';
    final token = await AppUsageService.getToken();
    final response = await http.post(
      Uri.parse('${AppConstants.appBaseUrl}/api/broadcasting/auth'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        if (token?.isNotEmpty == true) 'Authorization': 'Bearer $token',
      },
      body: {'socket_id': socketId, 'channel_name': channel},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Realtime authorization failed');
    }
    final body = jsonDecode(response.body);
    _send({
      'event': 'pusher:subscribe',
      'data': {'auth': body['auth'], 'channel': channel},
    });
  }

  void _send(Map<String, dynamic> value) {
    _socket?.sink.add(jsonEncode(value));
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => _send({'event': 'pusher:ping', 'data': const {}}),
    );
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    onStateChanged?.call(StoreSupportConnectionState.disconnected);
    _pingTimer?.cancel();
    _retryTimer?.cancel();
    _attempt++;
    final seconds = _attempt.clamp(1, 15);
    _retryTimer = Timer(Duration(seconds: seconds), _connect);
  }

  Future<void> dispose() async {
    _disposed = true;
    _retryTimer?.cancel();
    _pingTimer?.cancel();
    await _subscription?.cancel();
    await _socket?.sink.close();
    onStateChanged?.call(StoreSupportConnectionState.disconnected);
  }
}
