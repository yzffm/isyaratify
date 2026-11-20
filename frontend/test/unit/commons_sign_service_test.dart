import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/controllers/dictionary_controller.dart';
import 'package:isyaratify/core/errors/app_exceptions.dart';
import 'package:isyaratify/core/network/api_activity_log.dart';
import 'package:isyaratify/models/sign_media_model.dart';
import 'package:isyaratify/services/commons_sign_service.dart';
import 'package:isyaratify/services/supabase_service.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

String _commonsJson({Set<String> missing = const <String>{}}) {
  final pages = <Map<String, Object?>>[];
  for (var i = 0; i < 26; i++) {
    final letter = String.fromCharCode(0x41 + i);
    final title = 'File:$letter dalam BISINDO.webm';
    if (missing.contains(letter)) {
      pages.add(<String, Object?>{'title': title, 'missing': true});
      continue;
    }
    pages.add(<String, Object?>{
      'pageid': 1000 + i,
      'title': title,
      'imageinfo': <Object?>[
        <String, Object?>{
          'size': 500000 + i,
          'url':
              'https://upload.wikimedia.org/wikipedia/commons/0/0e/${letter}_dalam_BISINDO.webm?utm_source=commons.wikimedia.org&utm_campaign=imageinfo',
          'descriptionurl':
              'https://commons.wikimedia.org/wiki/File:${letter}_dalam_BISINDO.webm',
          'mime': 'video/webm',
          'extmetadata': <String, Object?>{
            'LicenseShortName': <String, Object?>{'value': 'CC BY-SA 4.0'},
            'Artist': <String, Object?>{
              'value':
                  '<a href="//commons.wikimedia.org/wiki/User:x">angphotorion</a>',
            },
          },
        },
      ],
    });
  }
  return jsonEncode(<String, Object?>{
    'query': <String, Object?>{'pages': pages},
  });
}

ResponseBody _jsonResponse(String body, {int status = 200}) {
  return ResponseBody.fromString(
    body,
    status,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

CommonsSignService _service(_FakeAdapter adapter, {ApiActivityLog? log}) {
  final dio = Dio(BaseOptions(baseUrl: CommonsSignService.baseUrl));
  dio.httpClientAdapter = adapter;
  return CommonsSignService(dio: dio, activityLog: log);
}

void main() {
  group('CommonsSignService', () {
    test('titleFor membentuk judul berkas Commons yang benar', () {
      expect(CommonsSignService.titleFor('a'), 'File:A dalam BISINDO.webm');
    });

    test(
      'fetchAlphabetSigns: 1 request batch, parsing 26 huruf, atribusi bersih, '
      'query utm dibuang, dan tercatat di ApiActivityLog',
      () async {
        final log = ApiActivityLog.instance..clear();
        final adapter = _FakeAdapter(
          (_) async => _jsonResponse(_commonsJson()),
        );
        final service = _service(adapter, log: log);

        final result = await service.fetchAlphabetSigns();

        expect(adapter.requests, hasLength(1));
        final req = adapter.requests.single;
        expect(req.uri.host, 'commons.wikimedia.org');
        expect(req.uri.path, '/w/api.php');
        expect(req.queryParameters['action'], 'query');
        expect(req.queryParameters['prop'], 'imageinfo');
        expect(req.queryParameters['origin'], '*');
        final titles = (req.queryParameters['titles'] as String).split('|');
        expect(titles, hasLength(26));
        expect(titles.first, 'File:A dalam BISINDO.webm');
        expect(titles.last, 'File:Z dalam BISINDO.webm');
        // GET sederhana: tidak ada Content-Type (menghindari preflight di Web).
        expect(
          req.headers.keys.map((k) => k.toLowerCase()),
          isNot(contains('content-type')),
        );

        expect(result, hasLength(26));
        final a = result['A']!;
        expect(a.isVideo, isTrue);
        expect(a.mediaUrl, isNot(contains('utm_')));
        expect(a.mediaUrl, endsWith('A_dalam_BISINDO.webm'));
        expect(a.artist, 'angphotorion');
        expect(a.license, 'CC BY-SA 4.0');
        expect(a.attributionText, contains('CC BY-SA 4.0'));

        final entries = log.entries;
        expect(entries, isNotEmpty);
        expect(entries.last.host, 'commons.wikimedia.org');
        expect(entries.last.statusCode, 200);
        expect(entries.last.isSuccess, isTrue);
      },
    );

    test(
      'hasil di-cache: pemanggilan kedua tidak mengirim request baru',
      () async {
        final adapter = _FakeAdapter(
          (_) async => _jsonResponse(_commonsJson()),
        );
        final service = _service(adapter);

        await service.fetchAlphabetSigns();
        await service.fetchAlphabetSigns();
        expect(adapter.requests, hasLength(1));

        await service.fetchAlphabetSigns(forceRefresh: true);
        expect(adapter.requests, hasLength(2));
      },
    );

    test('huruf yang hilang di Commons tidak muncul di hasil', () async {
      final adapter = _FakeAdapter(
        (_) async => _jsonResponse(_commonsJson(missing: <String>{'Q', 'X'})),
      );
      final result = await _service(adapter).fetchAlphabetSigns();
      expect(result, hasLength(24));
      expect(result.containsKey('Q'), isFalse);
      expect(result.containsKey('X'), isFalse);
    });

    test('status HTTP non-2xx dan timeout menjadi ApiException', () async {
      final badStatus = _service(
        _FakeAdapter((_) async => _jsonResponse('{}', status: 500)),
      );
      await expectLater(
        badStatus.fetchAlphabetSigns(),
        throwsA(isA<ApiException>()),
      );

      final timeout = _service(
        _FakeAdapter((options) async {
          throw DioException.connectionTimeout(
            timeout: const Duration(seconds: 1),
            requestOptions: options,
          );
        }),
      );
      await expectLater(
        timeout.fetchAlphabetSigns(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Wikimedia Commons'),
          ),
        ),
      );
    });

    test('respons kosong/tidak valid ditolak (bukan data palsu)', () async {
      await expectLater(
        _service(
          _FakeAdapter((_) async => _jsonResponse('{"query":{"pages":[]}}')),
        ).fetchAlphabetSigns(),
        throwsA(isA<ApiException>()),
      );
      expect(
        () => CommonsSignService.parseResponse('bukan-map'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('DictionaryController + Commons API', () {
    test('sukses: status ready dan signMediaFor tersedia', () async {
      final adapter = _FakeAdapter((_) async => _jsonResponse(_commonsJson()));
      final controller = DictionaryController(
        supabaseService: SupabaseService(supabaseUrl: '', publishableKey: ''),
        commonsSignService: _service(adapter),
      );

      await controller.loadDictionary();

      expect(controller.signStatus, SignMediaStatus.ready);
      expect(controller.signError, isNull);
      expect(controller.signMediaFor('b')?.letter, 'B');
      expect(controller.lettersSource, DataSource.localFallback);
      expect(controller.lettersFallbackReason, contains('belum dikonfigurasi'));
    });

    test('gagal: kamus tetap jalan, tetapi kegagalan eksplisit (tidak senyap) '
        'dan retry memulihkan', () async {
      var fail = true;
      final adapter = _FakeAdapter((options) async {
        if (fail) {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
          );
        }
        return _jsonResponse(_commonsJson());
      });
      final controller = DictionaryController(
        supabaseService: SupabaseService(supabaseUrl: '', publishableKey: ''),
        commonsSignService: _service(adapter),
      );

      await controller.loadDictionary();
      expect(controller.signStatus, SignMediaStatus.failed);
      expect(controller.signError, isNotNull);
      expect(controller.allLetters, hasLength(26));
      expect(controller.signMediaFor('A'), isNull);

      fail = false;
      await controller.retrySignMedia();
      expect(controller.signStatus, SignMediaStatus.ready);
      expect(controller.signMediaFor('A'), isNotNull);
    });
  });
}
