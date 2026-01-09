import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../models/login_model.dart';
import '../util/AppPrefrences.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.130.237:8001';
  static const String _chatEndpoint = '/data';
  static const String _loginEndpoint = '/login';

  /// Dio for JSON / form APIs
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /* -------------------------------------------------------------------------- */
  /*                               CHAT - TEXT                                  */
  /* -------------------------------------------------------------------------- */

  static Future<String> sendText(String text) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_chatEndpoint'),
      );

      request.fields['content'] = text;
      await _attachToken(request);

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (_isSuccess(response.statusCode)) {
        final json = jsonDecode(body);
        return json['message']?.toString() ?? '';
      }

      return _errorMessage(response.statusCode, body);
    } catch (e) {
      print("TextException: $e");
      return "Failed to send message";
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                               CHAT - FILE                                  */
  /* -------------------------------------------------------------------------- */

  static Future<String> sendFile(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_chatEndpoint'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      await _attachToken(request);

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (_isSuccess(response.statusCode)) {
        final json = jsonDecode(body);
        return json['message']?.toString() ?? 'Upload successful';
      }

      return _errorMessage(response.statusCode, body);
    } catch (e) {
      print("FileUploadException: $e");
      return "Image upload failed";
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                   LOGIN                                    */
  /* -------------------------------------------------------------------------- */

  static Future<LoginModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        _loginEndpoint,
        data: FormData.fromMap({
          'username': username,
          'password': password,
        }),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      return LoginModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      }
      throw Exception('Login failed. Please try again.');
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                               HELPER METHODS                                */
  /* -------------------------------------------------------------------------- */

  static Future<void> _attachToken(http.MultipartRequest request) async {
    final token = await AppPreferences.getAccessToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
  }

  static bool _isSuccess(int? statusCode) {
    return statusCode == 200 || statusCode == 201;
  }

  static String _errorMessage(int? code, String body) {
    return "Request failed ($code)";
  }
}