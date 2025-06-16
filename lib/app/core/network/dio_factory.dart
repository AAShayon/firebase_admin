import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:network_sanitizer/network_sanitizer.dart';

class DioFactory {
  /// Creates a new configured instance of [Dio].
  Dio create(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add the caching interceptor.
    dio.interceptors.add(
      NetworkSanitizerInterceptor(const Duration(minutes: 10)),
    );

    // Add a logger for debugging if in debug mode.
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        requestHeader: false,
      ));
    }

    return dio;
  }
}