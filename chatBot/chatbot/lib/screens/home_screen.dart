import 'package:chatbot/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../util/AppPrefrences.dart';
import 'chat_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _channel = MethodChannel('app/background');

  Future<void> _moveToBackground() async {
    try {
      await _channel.invokeMethod('moveToBackground');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        _moveToBackground();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user != null) ...[
                Text('Name: ${user.name}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Password: ${user.password}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Token: ${user.token}',
                    style: const TextStyle(fontSize: 18)),
              ] else
                const Text('No data received', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
                child: const Text('Go to Chat'),
              ),
              SizedBox(height: 100),

              ElevatedButton(
                onPressed: () {
                  AppPreferences.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('LOGOUT'),
              ),
              //Text('LOGOUT', style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
