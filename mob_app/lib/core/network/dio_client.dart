import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/exceptions.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';


class DioClient {
  DioClient({
    required String baseUrl,
    required FlutterSecureStorage secureStorage,
    VoidDioCallback? onUnauthorized,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        secureStorage: secureStorage,
        onUnauthorized: onUnauthorized ?? () {},
      ),
      LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;


  Dio get dio => _dio;


  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? fromJson,
  }) async {
    return _execute<T>(
      () => _dio.get(path, queryParameters: queryParams),
      fromJson: fromJson,
    );
  }


  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    return _execute<T>(
      () => _dio.post(path, data: data),
      fromJson: fromJson,
    );
  }


  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    return _execute<T>(
      () => _dio.put(path, data: data),
      fromJson: fromJson,
    );
  }


  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    return _execute<T>(
      () => _dio.patch(path, data: data),
      fromJson: fromJson,
    );
  }


  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    return _execute<T>(
      () => _dio.delete(path, data: data),
      fromJson: fromJson,
    );
  }


  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    String fileField = 'file',
    Map<String, dynamic>? data,
    T Function(dynamic json)? fromJson,
  }) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      ...?data,
      fileField: await MultipartFile.fromFile(filePath, filename: fileName),
    });

    return _execute<T>(
      () => _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      ),
      fromJson: fromJson,
    );
  }


  Future<ApiResponse<T>> _execute<T>(
    Future<Response> Function() request, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await request();
      final body = response.data;


      if (body is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(body, fromJson: fromJson);
      }


      return ApiResponse<T>(
        success: true,
        message: 'OK',
        data: fromJson != null ? fromJson(body) : body as T?,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }


  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        return _mapResponseError(e.response);

      case DioExceptionType.cancel:
        return NetworkException(message: 'Request was cancelled.');

      case DioExceptionType.badCertificate:
        return NetworkException(message: 'Security certificate error.');

      case DioExceptionType.unknown:
        if (e.error != null && e.error.toString().contains('SocketException')) {
          return NetworkException(
            message: 'No internet connection. Please check your network.',
          );
        }
        return NetworkException(
          message: e.message ?? 'An unexpected error occurred.',
        );
    }
  }


  Exception _mapResponseError(Response? response) {
    if (response == null) {
      return NetworkException(message: 'No response from server.');
    }

    final statusCode = response.statusCode ?? 0;
    final body = response.data;


    String message = 'Something went wrong';
    Map<String, dynamic>? errors;

    if (body is Map<String, dynamic>) {
      message = body['message'] as String? ?? message;
      if (body['errors'] is Map) {
        errors = body['errors'] as Map<String, dynamic>;
      }
    }

    switch (statusCode) {
      case 401:
        return AuthException(message: message);

      case 403:
        return AuthException(
          message: 'You do not have permission to perform this action.',
        );

      case 404:
        return ServerException(
          message: 'The requested resource was not found.',
          statusCode: statusCode,
        );

      case 422:
        return ValidationException(
          message: message,
          errors: errors,
        );

      case 429:
        return ServerException(
          message: 'Too many requests. Please wait a moment.',
          statusCode: statusCode,
        );

      default:
        if (statusCode >= 500) {
          return ServerException(
            message: message != 'Something went wrong'
                ? '$message (HTTP $statusCode)'
                : 'Server error. Please try again later.',
            statusCode: statusCode,
          );
        }
        return ServerException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );
    }
  }
}
