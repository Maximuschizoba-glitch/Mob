import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.logName = 'MobAPI'});


  final String logName;


  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('╔══════════════════════════════════════')
        ..writeln('║ REQUEST')
        ..writeln('╠──────────────────────────────────────')
        ..writeln('║ ${options.method.toUpperCase()} ${options.uri}')
        ..writeln('║ Headers: ${_maskHeaders(options.headers)}');

      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('║ Query: ${options.queryParameters}');
      }

      if (options.data != null) {
        final data = options.data;

        if (data is FormData) {
          buffer.writeln('║ Body: [FormData: ${data.fields.length} fields, ${data.files.length} files]');
        } else {
          buffer.writeln('║ Body: $data');
        }
      }

      buffer.writeln('╚══════════════════════════════════════');
      _log(buffer.toString());
    }
    handler.next(options);
  }


  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('╔══════════════════════════════════════')
        ..writeln('║ RESPONSE')
        ..writeln('╠──────────────────────────────────────')
        ..writeln('║ ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}')
        ..writeln('║ Data: ${_truncate(response.data.toString(), 500)}')
        ..writeln('╚══════════════════════════════════════');
      _log(buffer.toString());
    }
    handler.next(response);
  }


  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('╔══════════════════════════════════════')
        ..writeln('║ ERROR')
        ..writeln('╠──────────────────────────────────────')
        ..writeln('║ ${err.type.name} — ${err.message}')
        ..writeln('║ ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}');

      if (err.response != null) {
        buffer.writeln('║ Status: ${err.response?.statusCode}');
        buffer.writeln('║ Data: ${_truncate(err.response?.data.toString() ?? '', 500)}');
      }

      buffer.writeln('╚══════════════════════════════════════');

      debugPrint(buffer.toString());
    }
    handler.next(err);
  }


  void _log(String message, {bool isError = false}) {
    developer.log(
      message,
      name: logName,
      level: isError ? 1000 : 800,
    );
  }


  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final masked = Map<String, dynamic>.from(headers);
    if (masked.containsKey('Authorization')) {
      final auth = masked['Authorization'] as String?;
      if (auth != null && auth.length > 15) {
        masked['Authorization'] = '${auth.substring(0, 15)}...***';
      }
    }
    return masked;
  }


  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}... [truncated]';
  }
}
