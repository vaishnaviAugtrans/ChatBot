import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/video_compress_service.dart';
import '../services/socket_service.dart';
import '../util/AppPrefrences.dart';

final socketProvider = Provider<SocketService>((ref) {
  final socket = SocketService();
  ref.onDispose(socket.disconnect);
  return socket;
});

final chatProvider =
StateNotifierProvider.autoDispose<ChatNotifier, List<ChatMessage>>(
      (ref) {
        final socket = SocketService();
        final socketService = ref.read(socketProvider);
    ref.onDispose(() {
      socket.disconnect();
    });
    return ChatNotifier(socketService);
  },
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier(this._socketService) : super([]);

  final SocketService _socketService;
  final Uuid _uuid = const Uuid();

  bool _isSocketConnected = false;
  bool _isConnecting = false;

  // OPEN SOCKET (screen appear)
  Future<void> openSocket() async {
    if (_isSocketConnected || _isConnecting) return;

    _isConnecting = true;

    final token = await AppPreferences.getAccessToken();
    if (token == null || token.isEmpty) {
      print("Socket not opened: token missing");
      _isConnecting = false;
      return;
    }

    _socketService.connect(
      token: token,
      onMessage: _onSocketMessage,
    );

    _isSocketConnected = true;
    _isConnecting = false;

    print("Socket opened");
  }

  // CLOSE SOCKET (screen disappear)
  void closeSocket() {
    print("bef Socket closed");

    if (!_isSocketConnected) return;

    _socketService.disconnect();
    _isSocketConnected = false;
    _isConnecting = false;

    print("Socket closed");
  }

  // incoming socket message
  void _onSocketMessage(String text) {
    state = [
      ...state,
      ChatMessage(
        id: _uuid.v4(),
        text: text,
        type: MessageType.text,
        isUser: false,
      ),
    ];
  }

  // send text
  void sendText(String text) {
    state = [
      ...state,
    ChatMessage(
    id: _uuid.v4(),
    text: text,
    type: MessageType.text,
    isUser: true,
    ),
    ];
    _socketService.sendText(text);
  }

  @override
  void dispose() {
    closeSocket();
    super.dispose();
  }


/*
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier(this._socketService) : super([]);
  bool _isSocketConnected = false;
  bool _isConnecting = false;
  final SocketService _socketService;
  final Uuid _uuid = const Uuid();

  // connect ONLY when needed
  Future<void> _ensureSocketConnected() async {
    // Already connected OR connecting
    if (_isSocketConnected || _isConnecting) return;

    _isConnecting = true;

    final token = await AppPreferences.getAccessToken();
    if (token == null || token.isEmpty) {
      print("Socket not connected: token missing");
      _isConnecting = false;
      return;
    }

    _socketService.connect(
      token: token,
      onMessage: _onSocketMessage,
    );

    _isSocketConnected = true;
    _isConnecting = false;

    print(" Socket connected once");
  }

  void disconnectSocket() {
    _socketService.disconnect();
    _isSocketConnected = false;
    _isConnecting = false;
  }


  // incoming socket message → UI
  void _onSocketMessage(String text) {
    state = [
      ...state,
      ChatMessage(
        id: _uuid.v4(),
        text: text,
        type: MessageType.text,
        isUser: false,
      ),
    ];
  }

  // ================= TEXT =================
  Future<void> sendText(String text) async {
    // add user message immediately
    state = [
      ...state,
      ChatMessage(
        id: _uuid.v4(),
        text: text,
        type: MessageType.text,
        isUser: true,
      ),
    ];

    // connect socket ONLY here
    await _ensureSocketConnected();

    // send text over socket
    _socketService.sendText(text);
  }
*/

  // ================= IMAGE =================
  Future<void> sendImage(File image) async {
    final String messageId = _uuid.v4();

    state = [
      ...state,
      ChatMessage(
        id: messageId,
        file: image,
        type: MessageType.image,
        isUser: true,
        isUploading: true,
      ),
    ];

    try {
      final response = await ApiService.sendFile(image);

      state = [
        for (final msg in state)
          if (msg.id == messageId)
            msg.copyWith(isUploading: false)
          else
            msg,
        ChatMessage(
          id: _uuid.v4(),
          text: response,
          type: MessageType.text,
          isUser: false,
        ),
      ];
    } catch (e) {
      state = [
        for (final msg in state)
          if (msg.id == messageId)
            msg.copyWith(isUploading: false, uploadFailed: true)
          else
            msg,
      ];
    }
  }

  // ================= VIDEO =================
  Future<void> sendVideo(File video) async {
    final String messageId = _uuid.v4();

    state = [
      ...state,
      ChatMessage(
        id: messageId,
        file: video,
        type: MessageType.video,
        isUser: true,
        isUploading: true,
      ),
    ];

    try {
      final compressed = await VideoCompressService.compressVideo(video);
      if (compressed == null) throw Exception("Compression failed");

      final response = await ApiService.sendFile(compressed);

      state = [
        for (final msg in state)
          if (msg.id == messageId)
            msg.copyWith(isUploading: false)
          else
            msg,
        ChatMessage(
          id: _uuid.v4(),
          text: response,
          type: MessageType.text,
          isUser: false,
        ),
      ];
    } catch (e) {
      state = [
        for (final msg in state)
          if (msg.id == messageId)
            msg.copyWith(isUploading: false, uploadFailed: true)
          else
            msg,
      ];
    }
  }

  // ================= AUDIO =================
  Future<void> sendAudio(File audio) async {
    final id = _uuid.v4();

    state = [
      ...state,
      ChatMessage(
        id: id,
        file: audio,
        type: MessageType.audio,
        isUser: true,
        isUploading: true,
      ),
    ];

    try {
      final response = await ApiService.sendFile(audio);
      _finishUpload(id, response);
    } catch (e) {
      state = [
        for (final msg in state)
          if (msg.id == id)
            msg.copyWith(isUploading: false, uploadFailed: true)
          else
            msg,
        ChatMessage(
          id: _uuid.v4(),
          text: "Failed to send audio",
          type: MessageType.text,
          isUser: false,
        ),
      ];
    }
  }

  void _finishUpload(String messageId, String response) {
    state = [
      for (final msg in state)
        if (msg.id == messageId)
          msg.copyWith(isUploading: false)
        else
          msg,
      ChatMessage(
        id: _uuid.v4(),
        text: response,
        type: MessageType.text,
        isUser: false,
      ),
    ];
  }

 /* @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }*/
}
