// websocket.dart - WebSocket connection + message handler

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants.dart';

typedef OnMessageCallback = void Function(Map<String, dynamic>);

class WebSocketManager {
  static WebSocketChannel? _channel;
  static bool _isConnected = false;
  static OnMessageCallback? _onMessage;

  static Future<bool> connect(String token, {OnMessageCallback? onMessage}) async {
    try {
      final url = '${AppConstants.wsUrl}?token=$token';
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _onMessage = onMessage;
      _isConnected = true;

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data);
            if (_onMessage != null) _onMessage!(json);
          } catch (e) {
            print('WS Parse error: $e');
          }
        },
        onDone: () {
          _isConnected = false;
          print('WS Disconnected');
        },
        onError: (error) {
          print('WS Error: $error');
          _isConnected = false;
        },
      );
      return true;
    } catch (e) {
      print('WS Connect error: $e');
      return false;
    }
  }

  static void send(Map<String, dynamic> message) {
    if (_channel == null || !_isConnected) {
      print('WS Not connected!');
      return;
    }
    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('WS Send error: $e');
    }
  }

  static void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
  }

  static bool get isConnected => _isConnected;
}
