// import 'package:dio/dio.dart';
//
// import '../errors/api_exception.dart';
//
//
// class ApiService {
//   final Dio _dio;
//   ApiService(this._dio);
//
//   /// Generic GET method
//   Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
//     try {
//       final response = await _dio.get(path, queryParameters: queryParameters);
//       return response;
//     } on DioException catch (e) {
//       throw ApiException.fromDioError(e);
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }
//
//   /// Generic POST method
//   Future<Response> post(String path, {required Map<String, dynamic> data}) async {
//     try {
//       final response = await _dio.post(path, data: data);
//       return response;
//     } on DioException catch (e) {
//       throw ApiException.fromDioError(e);
//     } catch (e) {
//       throw ApiException(e.toString());
//     }
//   }
//
// // Add other methods like put, delete, etc. following the same pattern.
// }