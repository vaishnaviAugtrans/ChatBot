import 'dart:convert';
import 'dart:io';
import 'package:chatbot/data/models/login/login_model.dart';
import 'package:http/http.dart' as http;
import '../../core/networking/api_client.dart';
import '../../models/chat_ResponseModel.dart';
import '../../util/AppPrefrences.dart';
import '../models/login/loginReqModel.dart';

class ApiRepository {
  final ApiClient _client;

  ApiRepository() : _client = ApiClient();

  static const String _baseUrl = 'http://192.168.130.237:8001';
  static const String _chatEndpoint = '/data';
  static const String _loginEndpoint = '/login';

  Future<T> callApi<T>({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) parser,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _client.request(
        endpoint,
        method: method,
        data: data,
        queryParameters: queryParameters,
        parser: parser,
        headers: headers,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> sendText(String text) async {
    try {
      return await callApi<String>(
        endpoint: _chatEndpoint,
        method: 'POST',
        data: {
          "content": text,
        },
        parser: (data) {
          return data['message']?.toString() ?? '';
        },
      );
    } catch (e) {
      print("TextException: $e");
      return "Failed to send message";
    }
  }

  Future<LoginModel?> loginUser(LoginReqModel request) async {
    return callApi(
      endpoint: _loginEndpoint,
      method: 'POST',
      data: request.toJson(),
      parser: (data) => LoginModel.fromJson(data),
    );
  }

  Future<T> callMultipartApi<T>({
    required String endpoint,
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    required T Function(dynamic) parser,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(endpoint),
      );

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.addAll(files);

      // reuse your existing token logic
      await _attachToken(request);

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_errorMessage(response.statusCode, body));
      }

      return parser(jsonDecode(body));
    } catch (e) {
      rethrow;
    }
  }

  Future<String> sendFile(File file) async {
    try {
      return await callMultipartApi<String>(
        endpoint: '$_baseUrl$_chatEndpoint',
        files: [
          await http.MultipartFile.fromPath(
            'file',
            file.path,
          ),
        ],
        parser: (data) {
          return data['message']?.toString() ?? 'Upload successful';
        },
      );
    } catch (e) {
      print("FileUploadException: $e");
      return "Image upload failed";
    }
  }

  Future<List<ChatMessageModel>> getChatMessages() async {
    return callApi<List<ChatMessageModel>>(
      endpoint: _chatEndpoint, // same endpoint you already use
      method: 'GET',
      parser: (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => ChatMessageModel.fromJson(e))
            .toList();
      },
    );
  }

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