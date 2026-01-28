import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _accessTokenKey = 'access_token';
  //static const _tokenTypeKey = 'token_type';
  static const _isTokenExternal = '';

  static Future<void> saveToken({
    required String accessToken,
    //required String tokenType,
    required bool isTokenExternal
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    //await prefs.setString(_tokenTypeKey, tokenType);
    await prefs.setBool(_isTokenExternal, isTokenExternal);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
