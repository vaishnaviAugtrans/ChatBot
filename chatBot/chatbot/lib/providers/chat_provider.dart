import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/video_compress_service.dart';

final chatProvider =
StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
      (ref) => ChatNotifier(),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  final Uuid _uuid = const Uuid();

  Future<void> sendText(String text) async {
    state = [
      ...state,
      ChatMessage(
        id: _uuid.v4(),
        text: text,
        type: MessageType.text,
        isUser: true,
      ),
    ];

    final response = await ApiService.sendText(text);

    state = [
      ...state,
      ChatMessage(
        id: _uuid.v4(),
        text: response,
        type: MessageType.text,
        isUser: false,
      ),
    ];
  }

// ---------------- IMAGE (WITH LOADER) ----------------
  Future<void> sendImage(File image) async {

    print("sendFile");
    final String messageId = _uuid.v4();

    // Show image immediately with loader
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
      print("IMAGE UPLOAD ERROR: $e");

      state = [
        for (final msg in state)
          if (msg.id == messageId)
            msg.copyWith(isUploading: false, uploadFailed: true)
          else
            msg,
      ];
    }
  }

  Future<void> sendVideo(File video) async {
    final String messageId = _uuid.v4();

    // Show video bubble with loader
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

    //  Compress video
    final compressed = await VideoCompressService.compressVideo(video);
    if (compressed == null) return;

    //Upload video
    final response = await ApiService.sendFile(compressed);

    // Update loader → false
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

    final response = await ApiService.sendFile(audio);

    _finishUpload(id, response);
  }

  // ---------------- COMMON UPLOAD FINISH ----------------
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
}
