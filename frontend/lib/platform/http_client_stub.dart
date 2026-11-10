import 'http_client_platform.dart';

PlatformHttpClient createPlatformHttpClient() => _StubHttpClient();

class _StubHttpClient implements PlatformHttpClient {
  @override
  Future<HttpResponseData> request({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    return const HttpResponseData(
      statusCode: 503,
      body: '{"message":"HTTP client stub active"}',
    );
  }

  @override
  void close() {}
}
