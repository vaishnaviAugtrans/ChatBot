import 'dart:io';
import 'chat_ResponseModel.dart';

enum MessageType { text, image, video, audio }

class ChatMessage {
  final String id;
  final String? text;
  final String? from;
  final File? file;
  final MessageType type;
  final bool isUser;
  final bool isUploading;
  final bool uploadFailed;

  ChatMessage({
    required this.id,
    this.text,
    this.from,
    this.file,
    required this.type,
    required this.isUser,
    this.isUploading = false,
    this.uploadFailed = false,
  });

  ChatMessage copyWith({
    bool? isUploading,
    String? text,
    bool? uploadFailed,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      from: from,
      file: file,
      type: type,
      isUser: isUser,
      isUploading: isUploading ?? this.isUploading,
      uploadFailed: uploadFailed ?? this.uploadFailed,
    );
  }

  static List<ChatMessage> fromApiList(ChatMessageModel m) {
    final list = <ChatMessage>[];

    // USER (image / video / audio / text)
    if (m.filePath != null || (m.content != null && m.content!.isNotEmpty)) {
      list.add(ChatMessage(
        id: "${m.id}_user",
        type: _parseType(m.dataType),
        text: m.content,
        file: m.filePath != null ? File(m.filePath!) : null,
        isUser: true,
      ));
    }

    // BOT (always text)
    if (m.bot_answer != null && m.bot_answer!.isNotEmpty) {
      list.add(ChatMessage(
        id: "${m.id}_bot",
        type: MessageType.text,
        text: m.bot_answer,
        isUser: false,
      ));
    }

    return list;
  }

  static MessageType _parseType(String type) {
    switch (type.toLowerCase()) {
      case "image":
        return MessageType.image;
      case "video":
        return MessageType.video;
      case "audio":
        return MessageType.audio;
      default:
        return MessageType.text;
    }
  }
}
