import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required FlutterSecureStorage secureStorage,
    required VoidDioCallback onUnauthorized,
  })  : _secureStorage = secureStorage,
        _onUnauthorized = onUnauthorized;

  final FlutterSecureStorage _secureStorage;
  final VoidDioCallback _onUnauthorized;


  static const String tokenKey = 'auth_token';


  bool _isHandling401 = false;


  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: tokenKey);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }


  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isHandling401) {
      _isHandling401 = true;


      await _secureStorage.delete(key: tokenKey);


      _onUnauthorized();


      Future.delayed(const Duration(seconds: 2), () {
        _isHandling401 = false;
      });
    }

    handler.next(err);
  }
}


typedef VoidDioCallback = void Function();
