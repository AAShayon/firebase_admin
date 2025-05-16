// lib/core/network/api_provider.dart
import 'package:dio/dio.dart';

class ApiProvider {
  final Dio _dio = Dio();

  ApiProvider() {
    _dio.options.baseUrl = 'https://your-api-endpoint.com';
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(path, queryParameters: params);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Add other HTTP methods as needed

  dynamic _handleError(DioError error) {
    // Custom error handling
    throw error;
  }
}