import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

/*  void connect({
    required String token,
    required void Function(String text) onMessage,
  }) {
    final uri =
    Uri.parse('ws://192.168.130.237:8001/ws/chat?token=$token');

    _channel = WebSocketChannel.connect(uri);

    _subscription = _channel!.stream.listen(
          (data) {
        final decoded = jsonDecode(data);
        if (decoded['from'] == 'bot') {
          final text = decoded['message'];
          if (text != null) onMessage(text.toString());
        }
      },
      onDone: () => print("Socket closed"),
    );
  }*/

  void sendText(String text) {
    _channel?.sink.add(jsonEncode({
      "type": "text",
      "message": text,
    }));
  }

  /*void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(1000, "client closed");
    _channel = null;
  }*/

  void connect({
    required String token,
    required void Function(String text) onMessage,
  }) {
    if (_isConnected) {
      print(" Socket already connected");
      return;
    }

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.130.237:8001/ws/chat?token=$token'),
    );

    _isConnected = true;
    print(" Socket connected");

    _subscription = _channel!.stream.listen(
          (data) {
        final decoded = jsonDecode(data);
        if (decoded['from'] == 'bot') {
          final text = decoded['message'];
          if (text != null) onMessage(text.toString());
        }
      },
      onDone: () {
        _subscription = _channel!.stream.listen(
              (data) {},
          onDone: () {
            print("Socket is CLOSED");
          },
        );
        print("🔌 Socket closed by server");
        _cleanup();
      },
      onError: (e) {
        print(" Socket error: $e");
      },
    );
  }

  void disconnect() {
    if (!_isConnected) return;

    print("🔌 Closing socket...");
    _channel?.sink.close(1000, "client closed");
    _cleanup();
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _isConnected = false;
  }
}
