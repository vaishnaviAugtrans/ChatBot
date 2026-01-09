// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import '../providers/chat_provider.dart';
// import '../models/chat_message.dart';
//
// class ChatScreen extends ConsumerStatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _pickMedia() async {
//     final XFile? file = await _picker.pickMedia();
//     if (file == null) return;
//
//     final notifier = ref.read(chatProvider.notifier);
//     final ext = file.path.split('.').last.toLowerCase();
//
//     if (['mp4', 'mov', 'mkv'].contains(ext)) {
//       notifier.sendVideo(File(file.path));
//     } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext)) {
//       notifier.sendAudio(File(file.path));
//     } else {
//       notifier.sendImage(File(file.path));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final messages = ref.watch(chatProvider);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chat Bot')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.only(top: 8),
//               itemCount: messages.length,
//               itemBuilder: (_, index) => _chatBubble(messages[index]),
//             ),
//           ),
//
//           // INPUT BAR
//           SafeArea(
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.attach_file),
//                   onPressed: _pickMedia,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Type message',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     if (_controller.text.trim().isNotEmpty) {
//                       ref
//                           .read(chatProvider.notifier)
//                           .sendText(_controller.text.trim());
//                       _controller.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= CHAT BUBBLE =================
//
//   Widget _chatBubble(ChatMessage msg) {
//     return Align(
//       alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: msg.isUser ? Colors.green : Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: _bubbleContent(msg),
//       ),
//     );
//   }
//   // ================= BUBBLE CONTENT =================
//
//
//   Widget _bubbleContent(ChatMessage msg) {
//     switch (msg.type) {
//       case MessageType.image:
//         return _imageBubble(msg);
//
//       case MessageType.video:
//         return _videoBubble(msg);
//
//       case MessageType.audio:
//         return _audioBubble(msg);
//
//       default:
//         return Padding(
//           padding: const EdgeInsets.all(10),
//           child: Text(
//             msg.text ?? '',
//             style: TextStyle(
//               color: msg.isUser ? Colors.white : Colors.black,
//               fontSize: 15,
//             ),
//           ),
//         );
//     }
//   }
//   // ================= IMAGE BUBBLE WITH LOADER =================
//   Widget _imageBubble(ChatMessage msg) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Image.file(
//             msg.file!,
//             height: 160,
//             width: 230,
//             fit: BoxFit.cover,
//           ),
//
//           // 🔥 IMAGE UPLOAD LOADER
//           if (msg.isUploading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black54,
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 3,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ================= VIDEO BUBBLE WITH LOADER =================
//
//   Widget _videoBubble(ChatMessage msg) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Video placeholder (thumbnail-like)
//           Container(
//             height: 150,
//             width: 230,
//             color: Colors.black,
//             child: const Icon(
//               Icons.videocam,
//               color: Colors.white54,
//               size: 40,
//             ),
//           ),
//
//           // Play icon
//           const Icon(
//             Icons.play_circle_fill,
//             size: 55,
//             color: Colors.white,
//           ),
//           //  UPLOADING LOADER OVERLAY
//           if (msg.isUploading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black54,
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 3,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//   Widget _audioBubble(ChatMessage msg) {
//     return Container(
//       width: 220,
//       padding: const EdgeInsets.all(10),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.audiotrack, color: Colors.white),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   'Audio message',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//
//           if (msg.isUploading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black54,
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;

  // ================= ATTACH OPTIONS =================
  @override
  void dispose() {
    _recorder.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showAttachOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capture Image'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Capture Video'),
                onTap: () {
                  Navigator.pop(context);
                  _captureVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Gallery / Files'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _startRecording() async {
    final hasPermission = await _recorder.checkAndRequestPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();

    setState(() => _isRecording = false);

    print("Before:$path");

    if (path != null) {
      print("after:$path");
      ref.read(chatProvider.notifier).sendAudio(File(path));
    }
  }

  // ================= CAMERA IMAGE =================

  Future<void> _captureImage() async {
    final XFile? photo =
    await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    ref.read(chatProvider.notifier).sendImage(File(photo.path));
  }

  // ================= CAMERA VIDEO =================

  Future<void> _captureVideo() async {
    final XFile? video =
    await _picker.pickVideo(source: ImageSource.camera);

    if (video == null) return;

    ref.read(chatProvider.notifier).sendVideo(File(video.path));
  }

  // ================= GALLERY / FILE PICK =================

  Future<void> _pickMedia() async {
    final XFile? file = await _picker.pickMedia();
    if (file == null) return;

    final notifier = ref.read(chatProvider.notifier);
    final ext = file.path.split('.').last.toLowerCase();

    if (['mp4', 'mov', 'mkv'].contains(ext)) {
      notifier.sendVideo(File(file.path));
    } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg', 'webm'].contains(ext)) {
      print("Audio_path:${file.path}");
      notifier.sendAudio(File(file.path));
    } else {
      print("pickMedia_sendImage");
      notifier.sendImage(File(file.path));
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Bot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: messages.length,
              itemBuilder: (_, index) => _chatBubble(messages[index]),
            ),
          ),

          // ================= INPUT BAR =================
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _showAttachOptions,
                ),

                // 🎙 MIC BUTTON
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop_circle : Icons.mic,
                    color: _isRecording ? Colors.red : Colors.black,
                  ),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      ref
                          .read(chatProvider.notifier)
                          .sendText(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= CHAT BUBBLE =================

  Widget _chatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.green : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _bubbleContent(msg),
      ),
    );
  }

  // ================= BUBBLE CONTENT =================

  Widget _bubbleContent(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.image:
        return _imageBubble(msg);
      case MessageType.video:
        return _videoBubble(msg);
      case MessageType.audio:
        return _audioBubble(msg);
      default:
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            msg.text ?? '',
            style: TextStyle(
              color: msg.isUser ? Colors.white : Colors.black,
              fontSize: 15,
          ),
        ),
      );
    }
  }

  // ================= IMAGE =================

  Widget _imageBubble(ChatMessage msg) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            msg.file!,
            height: 160,
            width: 230,
            fit: BoxFit.cover,
          ),
          if (msg.isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          if (msg.uploadFailed)
            const Text(
              "Image upload failed",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }

  // ================= VIDEO =================

  Widget _videoBubble(ChatMessage msg) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 150,
            width: 230,
            color: Colors.black,
            child: const Icon(Icons.videocam, color: Colors.white54, size: 40),
          ),
          const Icon(Icons.play_circle_fill, size: 55, color: Colors.white),
          if (msg.isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= AUDIO =================

  Widget _audioBubble(ChatMessage msg) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: const [
              Icon(Icons.audiotrack, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Audio message',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          if (msg.isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
extension AudioRecorderPermission on AudioRecorder {
  Future<bool> checkAndRequestPermission() async {
    return await hasPermission();
  }
}