import 'package:chatbot/data/models/login/login_model.dart';
import 'package:chatbot/util/AppPrefrences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/networking/api_exception.dart';
import '../../data/models/login/loginReqModel.dart';
import '../../data/repositories/api_repository.dart';
import '../../routes/app_router.dart';
import '../../util/CommonMethods.dart';

class LoginState {
  final bool isLoading;
  final LoginModel? loginResponse;
  final String? errorMessage;

  LoginState({
    this.isLoading = false,
    this.loginResponse,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    LoginModel? loginResponse,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(ApiRepository());
});

class LoginViewModel extends StateNotifier<LoginState> {
  final ApiRepository _repository;

  LoginViewModel(this._repository) : super(LoginState());

  Future<void> loginUser(String username, String password, BuildContext context) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final requestModel = LoginReqModel(
        username: username,
        password: password,
      );

      final response = await _repository.loginUser(requestModel);

      if(response?.accessToken!=null){

        AppPreferences.saveToken(
            accessToken: response!.accessToken,
            isTokenExternal: false
        );
        _navigateToDashboard(context);

      }

      state = state.copyWith(isLoading: false, loginResponse: response);

    } on ApiException catch (e) {
      String errorMessage = 'Something went wrong';
      if (e.code == 400) {
        errorMessage = 'Username or password is incorrect';
      }
      CommonMethods.showSnackBar(context, errorMessage);
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      //print("loginresponseException $e");
      CommonMethods.showSnackBar(context, 'Something went wrong. Please try again.');
      state = state.copyWith(isLoading: false, errorMessage: 'Unexpected error: $e');
    }
  }

  void _navigateToDashboard(BuildContext context) {
    context.go(AppRoutes.home);
  }

}
