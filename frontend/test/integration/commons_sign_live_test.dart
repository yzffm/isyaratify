@Tags(<String>['network'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/services/commons_sign_service.dart';

/// Live test ke API Wikimedia Commons sungguhan.
///
/// Dilewati secara default (butuh internet). Jalankan dengan:
///   `flutter test test/integration/commons_sign_live_test.dart --dart-define=RUN_NETWORK_TESTS=true`
void main() {
  const enabled = bool.fromEnvironment('RUN_NETWORK_TESTS');

  setUpAll(() {
    // flutter_test memblokir HTTP nyata secara default; izinkan untuk live test.
    HttpOverrides.global = null;
  });

  test(
    'Commons API mengembalikan 26 video BISINDO A–Z berlisensi CC BY-SA',
    () async {
      final service = CommonsSignService();
      addTearDown(service.close);

      final result = await service.fetchAlphabetSigns();

      expect(result.length, 26);
      for (final entry in result.entries) {
        expect(entry.value.isVideo, isTrue, reason: entry.key);
        expect(entry.value.license, contains('CC BY-SA'), reason: entry.key);
        expect(
          entry.value.mediaUrl,
          startsWith('https://upload.wikimedia.org/'),
          reason: entry.key,
        );
      }
    },
    skip: enabled ? false : 'Set --dart-define=RUN_NETWORK_TESTS=true',
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
