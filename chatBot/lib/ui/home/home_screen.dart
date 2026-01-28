/*
import 'package:chatbot/ui/LoginScreen.dart';
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
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'package:chatbot/ui/login/LoginScreen.dart';
import 'package:flutter/material.dart';

import '../../util/AppPrefrences.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const primaryColor = Color(0xFF36356B);
  static const bgColor = Color(0xFFF7F6EF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _searchBar(),
                    const SizedBox(height: 24),
                    _gridMenu(),
                  ],
                ),
              ),
            ),
            _bottomInput(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/png/ic_profile.png"),
              ),
              const Spacer(),
              // Notification
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none,
                    color: Color(0xFF36356B)),
              ),

              // Logout
              TextButton.icon(
                onPressed: () {
                  AppPreferences.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );                },
                icon: const Icon(Icons.logout,
                    color: Color(0xFF36356B), size: 18),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Color(0xFF36356B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "Welcome, User! Ready to chat\nand get help from your\nassistant?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF36356B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE9E7C9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: primaryColor),
            SizedBox(width: 10),
            Text(
              "Search Dealer, Parts",
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= GRID =================

  Widget _gridMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.9,
        children: const [
          _FeatureCard(
            icon: Icons.engineering,
            title: "Explore Service\nHistory",
          ),
          _FeatureCard(
            icon: Icons.settings,
            title: "Check Spare Parts\nInventory",
          ),
          _FeatureCard(
            icon: Icons.build,
            title: "Operations &\nMaintenance Manual",
          ),
          _FeatureCard(
            icon: Icons.build_circle,
            title: "To Be Discuss",
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM INPUT =================

  Widget _bottomInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune, color: Color(0xFF36356B)),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      },
                      child: const Text(
                        "Chat to bot here",
                        style: TextStyle(
                          color: Color(0xFF36356B),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.mic, color: Color(0xFF36356B)),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFF36356B),
            child: Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

}

// ================= FEATURE CARD =================

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureCard({
    required this.icon,
    required this.title,
  });

  static const primaryColor = Color(0xFF36356B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF3),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: primaryColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}