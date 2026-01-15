import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  WebSocketChannel? _channel;

  void connect(String token) {
    _channel = WebSocketChannel.connect(
      Uri.parse("wss://example.com/ws/chat?token=$token"),
    );
  }

  Stream<dynamic> get stream => _channel!.stream;

  void sendMessage(String message) {
    final data = {
      "type": "text",
      "message": message,
    };
    _channel?.sink.add(jsonEncode(data));
  }

  void close() {
    _channel?.sink.close();
  }
}