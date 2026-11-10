import 'dart:convert';
import 'dart:io';

import '../http_client_platform.dart';

PlatformHttpClient createPlatformHttpClient() => _IoHttpClient();

class _IoHttpClient implements PlatformHttpClient {
  HttpClient? _client;

  HttpClient get _httpClient =>
      _client ??= (HttpClient()
        ..connectionTimeout = const Duration(seconds: 12));

  @override
  Future<HttpResponseData> request({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    final request = await _httpClient.openUrl(method, uri);
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });
    if (body != null && body.isNotEmpty) {
      final bytes = utf8.encode(body);
      request.contentLength = bytes.length;
      request.add(bytes);
    }
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);
    return HttpResponseData(
      statusCode: response.statusCode,
      body: responseBody,
    );
  }

  @override
  void close() {
    _client?.close(force: true);
    _client = null;
  }
}
