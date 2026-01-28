import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/chat/chat_message.dart';
import '../../providers/Socket_Provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/chat_provider.dart' hide socketProvider;

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();

}

class _ChatScreenState extends ConsumerState<ChatScreen> {

  final socketStatusProvider = Provider<bool>((ref) {
    return ref.watch(socketProvider).isConnected;
  });

  final ScrollController _scrollController = ScrollController();
  bool _isUserAtBottom = true;

  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).openSocket();
      _scrollToBottom();
    });
  }

  // ================= ATTACH OPTIONS ================= //

  @override
  void dispose() {
    _audioPlayer.dispose();
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
    final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

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

    final localMessages = ref.watch(chatProvider);
    //final apiMessages = ref.watch(chatHistoryProvider);
    ref.listen<List<ChatMessage>>(chatProvider as ProviderListenable<List<ChatMessage>>, (_, __) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6EF),
      body: SafeArea(
        child: Column(
          children: [
            _chatHeader(),

/*
            Expanded(
              child: apiMessages.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text("Failed to load chat")),
                data: (serverMessages) {
                  final allMessages = [
                    for (final m in serverMessages) ...ChatMessage.fromApiList(m),
                    ...localMessages,
                  ];

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: allMessages.length,
                    itemBuilder: (_, i) => _chatBubble(allMessages[i]),
                  );
                },
              ),
            ),
*/

            /*const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Priya is typing...",
                  style: TextStyle(
                    color: Color(0xFF36356B),
                    fontSize: 13,
                  ),
                ),
              ),
            ),*/
            _inputBar(),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    });
  }

  // ================= CHAT BUBBLE =================

  Widget _chatBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _avatar(),

          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isUser ? Colors.white : const Color(0xFF36356B),
              borderRadius: isUser ? BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(0),
              ) : BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _bubbleContent(msg),
          ),
          if (isUser) _userAvatar(),
        ],
      ),
    );
  }

  Widget _avatar() => const CircleAvatar(
    radius: 18,
    backgroundImage: AssetImage("assets/images/png/ic_customer.png"),
  );

  Widget _userAvatar() => const CircleAvatar(
    radius: 18,
    backgroundImage: AssetImage("assets/images/png/ic_profile.png"),
  );

  Widget _inputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Color(0xFF36356B)),
              onPressed: _showAttachOptions,
            ),

            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic,
                color: _isRecording ? Colors.red : const Color(0xFF36356B),
              ),
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Type your message.....",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF36356B),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    ref.read(chatProvider.notifier)
                        .sendText(_controller.text.trim());
                    _controller.clear();
                  }
                },
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.all(5),
          child: Text(
            msg.text ?? '',
            style: TextStyle(
              color: msg.isUser ? Colors.black : Colors.white,
              fontSize: 15,
          ),
        ),
      );
    }
  }

  // ================= IMAGE ================= //

  Widget _imageBubble(ChatMessage msg) {
    final String path = msg.file!.path;
    final bool isNetworkImage = path.startsWith('http');

    return GestureDetector(
      onTap: () {
        _openFullImage(context, path, isNetworkImage);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            isNetworkImage
                ? Image.network(
              path,
              height: 160,
              width: 230,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  height: 160,
                  width: 230,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (_, __, ___) => _imageError(),
            )
                : Image.file(
              File(path),
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
      ),
    );
  }

  void _openFullImage(
      BuildContext context,
      String path,
      bool isNetwork,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: isNetwork
                  ? Image.network(
                path,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 60,
                ),
              )
                  : Image.file(
                File(path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageError() {
    return Container(
      height: 160,
      width: 230,
      color: Colors.grey.shade300,
      child: const Icon(
        Icons.broken_image,
        color: Colors.red,
        size: 36,
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
    final isPlaying = _playingId == msg.id && _audioPlayer.playing;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: msg.isUser ? Colors.green : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: msg.isUser ? Colors.white : Colors.black,
                ),
                onPressed: () async {
                  try {
                    if (isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      _playingId = msg.id;

                      if (msg.file != null) {
                        await _audioPlayer.setFilePath(msg.file!.path);
                      } else if (msg.file!.path != null) {
                        final url = Uri.decodeFull(msg.file!.path!);
                        await _audioPlayer.setUrl(url);
                      } else {
                        return;
                      }
                      await _audioPlayer.play();
                      setState(() {});
                    }
                  } catch (e) {
                    debugPrint("Audio play error: $e");

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Unable to play audio"),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              const Text("Audio"),
            ],
          ),

          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _audioPlayer.duration ?? Duration.zero;
              return Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble().clamp(1, double.infinity),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              );
            },
          ),
          if (msg.isUploading)
            const LinearProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }

  Widget _chatHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF36356B)),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            "User",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF36356B),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 20),
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