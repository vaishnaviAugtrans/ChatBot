import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/login_model.dart';
import '../services/api_service.dart';

final loginProvider =
StateNotifierProvider<LoginNotifier, AsyncValue<LoginModel?>>(
      (ref) => LoginNotifier(),
);

class LoginNotifier extends StateNotifier<AsyncValue<LoginModel?>> {
  LoginNotifier() : super(const AsyncValue.data(null));

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final token = await ApiService.login(
        username: username,
        password: password,
      );

      state = AsyncValue.data(token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
