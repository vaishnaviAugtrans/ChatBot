import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../models/user_data.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  get SharedPreferences => null;

  void init(WidgetRef ref) {
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleUri(uri, ref);
    });
  }

  void _handleUri(Uri uri, WidgetRef ref) {
    print("uri:: $uri");
    final name = uri.queryParameters['name'];
    final password = uri.queryParameters['password'];
    final token = uri.queryParameters['token'];

    if (name != null && password != null) {
      final user = UserData(name: name, password: password,token: token);
      //final user = UserData(name: name, password: password);

      ref.read(userProvider.notifier).state = user;

      // persist
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('name', name);
        prefs.setString('password', password);
        prefs.setString('token', token);
      });
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
