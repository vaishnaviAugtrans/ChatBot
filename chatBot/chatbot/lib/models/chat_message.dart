import 'dart:io';

enum MessageType { text, image, video, audio }

class ChatMessage {
  final String id;
  final String? text;
  final File? file;
  final MessageType type;
  final bool isUser;
  final bool isUploading;
  final bool uploadFailed;

  ChatMessage({
    required this.id,
    this.text,
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
      file: file,
      type: type,
      isUser: isUser,
      isUploading: isUploading ?? this.isUploading,
      uploadFailed: uploadFailed ?? this.uploadFailed,
    );
  }
}
