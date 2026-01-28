import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../util/Constants.dart';
import 'api_exception.dart';
import 'retry_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
    BaseOptions(
      baseUrl: Constants.BASE_URL, // Replace with your API base URL
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
      RetryInterceptor(dio: _dio, retries: 3),
    ]);
  }

  Future<T> request<T>(
      String path, {
        String method = 'GET',
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
        required T Function(dynamic) parser,
        Map<String, dynamic>? headers,
      }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method,
            headers: headers),
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  T _handleResponse<T>(Response response, T Function(dynamic) parser) {
    switch (response.statusCode) {
      case 200:
        return parser(response.data);
      case 400:
        throw ApiException.badRequest(
          message: 'Bad request: ${response.data['message'] ?? 'Invalid parameters'}',
          data: response.data,
        );
      default:
        throw ApiException.unknown(
          message: 'Unexpected error: ${response.statusCode}',
          code: response.statusCode,
          data: response.data,
        );
    }
  }
}