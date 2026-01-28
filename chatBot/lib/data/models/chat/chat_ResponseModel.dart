class ChatMessageModel {
  final int id;
  final String dataType;
  final String? content;
  final String? message;
  final String? bot_answer;
  final String? filePath;
  final DateTime createdTime;
  final DateTime outputTime;

  ChatMessageModel({
    required this.id,
    required this.dataType,
    this.content,
    this.message,
    this.bot_answer,
    this.filePath,
    required this.createdTime,
    required this.outputTime,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      dataType: json['data_type'],
      content: json['content'],
      message: json['message'],
      bot_answer: json['bot_answer'],
      filePath: json['file_path'],
      createdTime: DateTime.parse(json['createdtime']),
      outputTime: DateTime.parse(json['outputtime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "data_type": dataType,
      "content": content,
      "message": message,
      "bot_answer": bot_answer,
      "file_path": filePath,
      "createdtime": createdTime.toIso8601String(),
      "outputtime": outputTime.toIso8601String(),
    };
  }

  // Helper getters for UI
  bool get isText => dataType == "text";
  bool get isImage => dataType == "image";
  bool get isVideo => dataType == "video";
  bool get isAudio => dataType == "audio";

}