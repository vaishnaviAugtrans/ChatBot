import 'package:chatbot/util/AppPrefrences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';

final socketProvider = Provider<SocketService>((ref) {
  final socket = SocketService();
  final token = AppPreferences.getAccessToken();

  socket.connect(token);

  ref.onDispose(() => socket.close());
  return socket;
});