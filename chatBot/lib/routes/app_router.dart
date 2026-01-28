import 'package:chatbot/ui/home/home_screen.dart';
import 'package:chatbot/ui/splash/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/login/LoginScreen.dart';
import '../util/AppPrefrences.dart';

// Route constants for better maintainability
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
}

final authStateProvider = StateProvider<bool>((ref) => false);

final authProvider = FutureProvider<bool>((ref) async {
  final token = await AppPreferences.getAccessToken();
  return token != null && token.isNotEmpty;
});

// Custom transition builder
Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    ) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0), // Slide from right to left
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

// Optimized GoRouter configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

/*  redirect: (context, state) {
    final isLoggedIn =
    ProviderScope.containerOf(context).read(authStateProvider);

    final isLogin = state.matchedLocation == AppRoutes.login;

    if (!isLoggedIn && !isLogin) {
      return AppRoutes.login;
    }

    if (isLoggedIn && isLogin) {
      return AppRoutes.home;
    }

    return null;
  },*/

  routes: [
    GoRoute(
        path:AppRoutes.splash,
        pageBuilder: (context,state) =>
            _buildPage(const SplashScreen())
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) =>
          _buildPage(const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) =>
          _buildPage(const HomeScreen()),
    ),
  ],
);

//Reusable page builder with custom transition
CustomTransitionPage _buildPage(Widget child) {
  return CustomTransitionPage(
    key: ValueKey(child.runtimeType), // Unique key for better navigation stack management
    child: child,
    transitionsBuilder: _slideTransition,
    transitionDuration: const Duration(milliseconds: 200),
  );
}
