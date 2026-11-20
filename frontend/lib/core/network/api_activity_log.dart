import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Satu catatan request HTTP yang dikirim aplikasi (tanpa body/header sensitif).
class ApiActivityEntry {
  const ApiActivityEntry({
    required this.method,
    required this.host,
    required this.path,
    required this.statusCode,
    required this.durationMs,
    required this.timestamp,
    this.error,
  });

  final String method;
  final String host;
  final String path;
  final int? statusCode;
  final int durationMs;
  final DateTime timestamp;
  final String? error;

  bool get isSuccess =>
      error == null &&
      statusCode != null &&
      statusCode! >= 200 &&
      statusCode! < 300;

  @override
  String toString() =>
      '[API] $method $host$path -> ${statusCode ?? 'ERR'} (${durationMs}ms)'
      '${error == null ? '' : ' | $error'}';
}

/// Log aktivitas API dalam memori agar pemakaian Dio dapat dibuktikan
/// (console debug + riwayat yang dapat diperiksa di test/UI).
///
/// Tidak menyimpan header (apikey/token) maupun query string.
class ApiActivityLog {
  ApiActivityLog._();

  static final ApiActivityLog instance = ApiActivityLog._();

  static const int maxEntries = 50;

  final List<ApiActivityEntry> _entries = <ApiActivityEntry>[];

  List<ApiActivityEntry> get entries => List.unmodifiable(_entries);

  void record(ApiActivityEntry entry) {
    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
    if (kDebugMode) {
      debugPrint(entry.toString());
    }
  }

  void clear() => _entries.clear();

  /// Interceptor Dio yang mencatat setiap request ke [ApiActivityLog].
  static Interceptor interceptor([ApiActivityLog? log]) {
    final target = log ?? ApiActivityLog.instance;
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['_api_started_at'] =
            DateTime.now().millisecondsSinceEpoch;
        handler.next(options);
      },
      onResponse: (response, handler) {
        target.record(_entry(response.requestOptions, response.statusCode));
        handler.next(response);
      },
      onError: (error, handler) {
        target.record(
          _entry(
            error.requestOptions,
            error.response?.statusCode,
            error: error.type.name,
          ),
        );
        handler.next(error);
      },
    );
  }

  static ApiActivityEntry _entry(
    RequestOptions options,
    int? statusCode, {
    String? error,
  }) {
    final started = options.extra['_api_started_at'] as int?;
    final now = DateTime.now();
    return ApiActivityEntry(
      method: options.method,
      host: options.uri.host,
      path: options.uri.path,
      statusCode: statusCode,
      durationMs: started == null ? 0 : now.millisecondsSinceEpoch - started,
      timestamp: now,
      error: error,
    );
  }
}
