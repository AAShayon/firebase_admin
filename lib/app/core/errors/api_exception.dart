import 'dart:io';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  factory ApiException.fromDioError(DioException error) {
    String errorMessage;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please check your internet connection and try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleErrorResponse(error.response);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          errorMessage = 'No internet connection. Please check your network.';
        } else {
          errorMessage = 'An unexpected network error occurred.';
        }
        break;
      default:
        errorMessage = 'An unknown error occurred.';
        break;
    }
    return ApiException(errorMessage);
  }

  static String _handleErrorResponse(Response? response) {
    if (response == null) {
      return 'Received an invalid response from the server.';
    }
    final statusCode = response.statusCode;
    // Attempt to parse a specific error message from the response body
    final serverMessage = response.data?['message'] ?? response.data?['error'] ?? 'Unknown server error.';
    return 'Error $statusCode: $serverMessage';
  }

  @override
  String toString() => message;
}