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
