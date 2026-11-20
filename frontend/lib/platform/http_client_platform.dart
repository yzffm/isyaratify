import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/errors/app_exceptions.dart';
import '../core/network/api_activity_log.dart';

export 'http_client_stub.dart'
    if (dart.library.js_interop) 'web/http_client_web.dart'
    if (dart.library.io) 'android/http_client_io.dart';

class HttpResponseData {
  const HttpResponseData({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

abstract interface class PlatformHttpClient {
  Future<HttpResponseData> request({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  });

  void close();
}

/// Implementasi [PlatformHttpClient] berbasis `package:dio` untuk Web dan Android.
///
/// Mendukung konfigurasi timeout terpusat, interceptor header JSON standar,
/// serta pemetaan [DioException] yang seragam tanpa mengekspos frame kamera.
class DioPlatformHttpClient implements PlatformHttpClient {
  DioPlatformHttpClient({
    Dio? dio,
    Duration timeout = const Duration(seconds: 12),
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: timeout,
               receiveTimeout: timeout,
               responseType: ResponseType.plain,
               validateStatus: (_) => true,
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.putIfAbsent('Accept', () => 'application/json');
          // Content-Type hanya relevan untuk request yang membawa body. Pada
          // GET tanpa body, header ini di Web memicu CORS preflight tak perlu.
          if (options.data != null) {
            options.headers.putIfAbsent(
              'Content-Type',
              () => 'application/json',
            );
          }
          handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(ApiActivityLog.interceptor());
  }

  final Dio _dio;

  @override
  Future<HttpResponseData> request({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    final hasBody = body != null && body.isNotEmpty;
    final effectiveHeaders = Map<String, dynamic>.from(headers);
    if (!hasBody) {
      effectiveHeaders.removeWhere(
        (key, _) => key.toLowerCase() == 'content-type',
      );
    }
    try {
      final response = await _dio.requestUri<dynamic>(
        uri,
        data: hasBody ? body : null,
        options: Options(
          method: method.toUpperCase(),
          headers: effectiveHeaders,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );

      final statusCode = response.statusCode ?? 500;
      final rawData = response.data;
      final String bodyStr;
      if (rawData == null) {
        bodyStr = '';
      } else if (rawData is String) {
        bodyStr = rawData;
      } else {
        bodyStr = jsonEncode(rawData);
      }

      return HttpResponseData(statusCode: statusCode, body: bodyStr);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final rawData = e.response?.data;
      if (statusCode != null && rawData != null) {
        final bodyStr = rawData is String ? rawData : jsonEncode(rawData);
        return HttpResponseData(statusCode: statusCode, body: bodyStr);
      }
      throw ApiException(_mapDioErrorMessage(e), statusCode: statusCode);
    }
  }

  String _mapDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi ke server habis. Periksa jaringan internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.cancel:
        return 'Permintaan jaringan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat keamanan koneksi tidak valid.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
      default:
        return error.message ?? 'Terjadi gangguan jaringan yang tidak terduga.';
    }
  }

  @override
  void close() {
    _dio.close(force: true);
  }
}
