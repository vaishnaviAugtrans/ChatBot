import 'package:chatbot/ui/login/LoginViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/login_provider.dart';
import '../../services/location_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with WidgetsBindingObserver {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    ref.read(loginViewModelProvider.notifier).loginUser(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
      context,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensureLocationPermission(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ensureLocationPermission(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

  /*  // Listen for success / error
    ref.listen(loginProvider, (previous, next) {
      next.whenOrNull(
        data: (token) {
          if (token != null) {

            AppPreferences.saveToken(
              accessToken: token.accessToken,
              isTokenExternal: false
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        },
      );
    });
*/

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Title
              Text(
                "Welcome Back!",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF36356B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Chat smarter, faster, better.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Color(0xFF36356B),
                ),
              ),

              const SizedBox(height: 40),

              // User ID
              const Text(
                "User ID",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF36356B),
                ),
              ),
              const SizedBox(height: 8),
              _roundedField(
                controller: _usernameController,
                hint: "Enter user ID",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 24),

              // Password
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF36356B),
                ),
              ),
              const SizedBox(height: 8),
              _roundedField(
                controller: _passwordController,
                hint: "••••••••••",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 16),

              // Remember + Forgot
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (_) {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(
                    "Remember Me",
                    style: TextStyle(color: Color(0xFF36356B)),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF36356B),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: loginState.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36356B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: loginState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _roundedField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool isPassword = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        icon: Icon(icon, color: const Color(0xFF36356B)),
        hintText: hint,
        border: InputBorder.none,
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off, color: Color(0xFF36356B))
            : null,
      ),
    ),
  );
}
