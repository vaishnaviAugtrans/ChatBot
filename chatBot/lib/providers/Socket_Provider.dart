import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';

final socketProvider = Provider.autoDispose<SocketService>((ref) {
  final socket = SocketService();

  ref.onDispose(() {
    print("socketProvider disposed");
    socket.disconnect();
  });

  return socket;
});