import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/controllers/practice_controller.dart';
import 'package:isyaratify/core/errors/app_exceptions.dart';
import 'package:isyaratify/models/hand_landmark_model.dart';
import 'package:isyaratify/services/hand_tracking_service.dart';

class _FakeService implements HandTrackingService {
  _FakeService({
    this.failInit = false,
    this.initError,
    this.failStop = false,
    this.initCompleter,
  });

  bool failInit;
  Object? initError;
  final bool failStop;
  final Completer<void>? initCompleter;

  int initCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> initialize() async {
    initCalls++;
    if (initCompleter != null) {
      await initCompleter!.future;
    }
    if (initError != null) throw initError!;
    if (failInit) throw const HandTrackingException('gagal');
  }

  @override
  Stream<HandLandmarkFrame> start() => failInit
      ? Stream<HandLandmarkFrame>.error(const HandTrackingException('gagal'))
      : const Stream.empty();

  @override
  Future<void> stop() async {
    stopCalls++;
    if (failStop) throw StateError('stop gagal');
  }

  @override
  Future<void> dispose() async => disposeCalls++;

  @override
  Widget buildPreview(BuildContext context) => const SizedBox.shrink();
}

void main() {
  test(
    'fake HandTrackingService mengikuti kontrak dan melaporkan error saat gagal',
    () async {
      final service = _FakeService(failInit: true);
      expect(service, isA<HandTrackingService>());
      await expectLater(
        service.initialize(),
        throwsA(isA<HandTrackingException>()),
      );
      await expectLater(
        service.start(),
        emitsError(isA<HandTrackingException>()),
      );
      await service.stop();
      await service.dispose();
      await service.dispose(); // aman dipanggil berulang
      expect(service.stopCalls, 1);
      expect(service.disposeCalls, 2);
    },
  );

  test(
    'PracticeController: status ready bila initialize berhasil dan no-op saat dipanggil ulang',
    () async {
      final s = _FakeService();
      final c = PracticeController(s);
      await c.initialize();
      expect(c.status, PracticeStatus.ready);
      expect(s.initCalls, 1);

      await c.initialize();
      expect(c.status, PracticeStatus.ready);
      expect(s.initCalls, 1);
      c.dispose();
    },
  );

  test(
    'PracticeController: unavailable + pesan bila initialize gagal, dan dapat diulang dari unavailable',
    () async {
      final s = _FakeService(failInit: true);
      final c = PracticeController(s);
      await c.initialize();
      expect(c.status, PracticeStatus.unavailable);
      expect(c.message, 'gagal');
      expect(s.initCalls, 1);

      s.failInit = false;
      await c.initialize();
      expect(c.status, PracticeStatus.ready);
      expect(c.message, isNull);
      expect(s.initCalls, 2);
      c.dispose();
    },
  );

  test(
    'PracticeController: initialize tidak berjalan ganda saat masih initializing',
    () async {
      final completer = Completer<void>();
      final s = _FakeService(initCompleter: completer);
      final c = PracticeController(s);

      final first = c.initialize();
      final second = c.initialize();
      expect(c.status, PracticeStatus.initializing);
      expect(s.initCalls, 1);

      completer.complete();
      await Future.wait([first, second]);
      expect(c.status, PracticeStatus.ready);
      expect(s.initCalls, 1);
      c.dispose();
    },
  );

  test(
    'PracticeController: menangkap non-HandTrackingException dengan pesan generik',
    () async {
      final s = _FakeService(initError: StateError('kesalahan internal'));
      final c = PracticeController(s);
      await c.initialize();
      expect(c.status, PracticeStatus.unavailable);
      expect(c.message, PracticeController.genericErrorMessage);
      c.dispose();
    },
  );

  test('PracticeController.dispose menghentikan dan melepas service', () async {
    final s = _FakeService();
    PracticeController(s).dispose();
    await Future<void>.delayed(Duration.zero);
    expect(s.stopCalls, 1);
    expect(s.disposeCalls, 1);
  });

  test(
    'PracticeController.dispose tetap memanggil dispose walau stop melempar error',
    () async {
      final s = _FakeService(failStop: true);
      PracticeController(s).dispose();
      await Future<void>.delayed(Duration.zero);
      expect(s.stopCalls, 1);
      expect(s.disposeCalls, 1);
    },
  );

  test('PracticeController.dispose aman dipanggil dua kali', () async {
    final s = _FakeService();
    final c = PracticeController(s);
    c.dispose();
    c.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(s.stopCalls, 1);
    expect(s.disposeCalls, 1);
  });

  test(
    'PracticeController: initialize selesai setelah dispose melepas ulang service tanpa notifyListeners',
    () async {
      final completer = Completer<void>();
      final s = _FakeService(initCompleter: completer);
      final c = PracticeController(s);

      var notificationsAfterDispose = 0;
      var disposed = false;
      c.addListener(() {
        if (disposed) notificationsAfterDispose++;
      });

      final initFuture = c.initialize();
      expect(c.status, PracticeStatus.initializing);

      disposed = true;
      c.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(s.stopCalls, 1);
      expect(s.disposeCalls, 1);

      completer.complete();
      await initFuture;

      expect(s.stopCalls, 2);
      expect(s.disposeCalls, 2);
      expect(notificationsAfterDispose, 0);
    },
  );
}
