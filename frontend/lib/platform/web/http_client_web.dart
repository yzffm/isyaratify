import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../http_client_platform.dart';

PlatformHttpClient createPlatformHttpClient() => _WebHttpClient();

@JS('fetch')
external JSPromise<JSObject> _jsFetch(JSString url, JSObject init);

class _WebHttpClient implements PlatformHttpClient {
  @override
  Future<HttpResponseData> request({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    final headersObj = JSObject();
    headers.forEach((key, value) {
      headersObj.setProperty(key.toJS, value.toJS);
    });

    final init = JSObject();
    init.setProperty('method'.toJS, method.toJS);
    init.setProperty('headers'.toJS, headersObj);
    if (body != null && body.isNotEmpty) {
      init.setProperty('body'.toJS, body.toJS);
    }

    final response = await _jsFetch(uri.toString().toJS, init).toDart;
    final statusProp = response.getProperty<JSNumber?>('status'.toJS);
    final statusCode = statusProp?.toDartInt ?? 500;
    final textPromise = response.callMethod<JSPromise<JSString>>('text'.toJS);
    final textResult = await textPromise.toDart;

    return HttpResponseData(statusCode: statusCode, body: textResult.toDart);
  }

  @override
  void close() {}
}
