import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';
import '../core/network/api_activity_log.dart';
import '../models/sign_media_model.dart';

/// Klien API publik **Wikimedia Commons (MediaWiki Action API)** untuk
/// mengambil video peragaan isyarat alfabet BISINDO (A–Z).
///
/// - Endpoint: `GET https://commons.wikimedia.org/w/api.php?action=query&prop=imageinfo`
/// - Tanpa API key; gratis; mendukung CORS (`origin=*`) untuk Flutter Web.
/// - Konten berlisensi CC BY-SA 4.0 (kontributor: angphotorion / Wikibility),
///   sehingga atribusi wajib ditampilkan oleh UI.
/// - Seluruh request memakai Dio dan tercatat di [ApiActivityLog].
///
/// Catatan Web: browser melarang pengaturan header `User-Agent`, dan header
/// kustom memicu CORS preflight. Karena itu request dibuat sebagai *simple
/// GET* tanpa header tambahan; `User-Agent` hanya diatur pada platform non-Web
/// sesuai kebijakan Wikimedia.
class CommonsSignService {
  CommonsSignService({
    Dio? dio,
    ApiActivityLog? activityLog,
    Duration timeout = const Duration(seconds: 15),
  }) : _dio = dio ?? _buildDio(timeout) {
    _dio.interceptors.add(ApiActivityLog.interceptor(activityLog));
  }

  static const String baseUrl = 'https://commons.wikimedia.org';
  static const String apiPath = '/w/api.php';

  /// Pola judul berkas Commons untuk video huruf BISINDO.
  static String titleFor(String letter) =>
      'File:${letter.toUpperCase()} dalam BISINDO.webm';

  static const String _userAgent =
      'Isyaratify/1.0 (aplikasi belajar alfabet BISINDO; proyek akademik)';

  final Dio _dio;

  Map<String, SignMediaModel>? _cache;

  static Dio _buildDio(Duration timeout) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        responseType: ResponseType.json,
        headers: kIsWeb ? null : <String, dynamic>{'User-Agent': _userAgent},
      ),
    );
  }

  /// Mengambil metadata video A–Z dalam **satu** request (batch 26 judul).
  ///
  /// Melempar [ApiException] bila jaringan gagal atau respons tidak valid.
  /// Huruf yang tidak ditemukan di Commons tidak muncul pada hasil.
  Future<Map<String, SignMediaModel>> fetchAlphabetSigns({
    bool forceRefresh = false,
  }) async {
    final cached = _cache;
    if (!forceRefresh && cached != null) return cached;

    final letters = List<String>.generate(
      26,
      (i) => String.fromCharCode(0x41 + i),
    );

    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        apiPath,
        queryParameters: <String, dynamic>{
          'action': 'query',
          'format': 'json',
          'formatversion': '2',
          'origin': '*',
          'titles': letters.map(titleFor).join('|'),
          'prop': 'imageinfo',
          'iiprop': 'url|mime|size|extmetadata',
          'iiextmetadatafilter': 'LicenseShortName|Artist',
        },
      );
    } on DioException catch (e) {
      throw ApiException(_describe(e), statusCode: e.response?.statusCode);
    }

    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw ApiException(
        'Wikimedia Commons mengembalikan status $status.',
        statusCode: status,
      );
    }

    final result = parseResponse(response.data);
    if (result.isEmpty) {
      throw const ApiException(
        'Wikimedia Commons tidak mengembalikan video isyarat BISINDO.',
      );
    }
    return _cache = Map<String, SignMediaModel>.unmodifiable(result);
  }

  /// Mengurai respons `action=query&formatversion=2` menjadi peta huruf → media.
  @visibleForTesting
  static Map<String, SignMediaModel> parseResponse(Object? data) {
    if (data is! Map) {
      throw const ApiException('Format respons Wikimedia Commons tidak valid.');
    }
    final query = data['query'];
    final pages = query is Map ? query['pages'] : null;
    if (pages is! List) {
      throw const ApiException(
        'Respons Wikimedia Commons tidak berisi halaman.',
      );
    }

    final out = <String, SignMediaModel>{};
    for (final page in pages) {
      if (page is! Map || page['missing'] == true) continue;
      final title = page['title']?.toString() ?? '';
      final match = RegExp(
        r'^File:([A-Z]) dalam BISINDO\.webm$',
      ).firstMatch(title);
      final infos = page['imageinfo'];
      if (match == null || infos is! List || infos.isEmpty) continue;

      final info = infos.first;
      if (info is! Map) continue;
      final url = info['url']?.toString() ?? '';
      if (url.isEmpty) continue;

      final meta = info['extmetadata'];
      String metaValue(String key) {
        if (meta is Map && meta[key] is Map) {
          return (meta[key] as Map)['value']?.toString() ?? '';
        }
        return '';
      }

      final letter = match.group(1)!;
      final size = info['size'];
      out[letter] = SignMediaModel(
        letter: letter,
        mediaUrl: _stripQuery(url),
        mimeType: info['mime']?.toString() ?? 'video/webm',
        sizeBytes: size is num ? size.toInt() : 0,
        license: _nonEmpty(metaValue('LicenseShortName'), 'CC BY-SA 4.0'),
        artist: _nonEmpty(
          _stripHtml(metaValue('Artist')),
          'Kontributor Commons',
        ),
        descriptionUrl: info['descriptionurl']?.toString() ?? '',
      );
    }
    return out;
  }

  static String _stripQuery(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.replace(query: '').toString().replaceFirst(RegExp(r'\?$'), '');
  }

  static String _stripHtml(String input) =>
      input.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  static String _nonEmpty(String value, String fallback) =>
      value.trim().isEmpty ? fallback : value.trim();

  static String _describe(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Waktu koneksi ke Wikimedia Commons habis.',
      DioExceptionType.connectionError =>
        'Tidak dapat terhubung ke Wikimedia Commons. Periksa internet Anda.',
      DioExceptionType.badResponse =>
        'Wikimedia Commons menolak permintaan (status ${e.response?.statusCode}).',
      _ => e.message ?? 'Gangguan jaringan saat memuat video isyarat.',
    };
  }

  void close() => _dio.close(force: true);
}
