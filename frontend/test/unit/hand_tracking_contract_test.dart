import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/controllers/practice_controller.dart';
import 'package:isyaratify/core/errors/app_exceptions.dart';
import 'package:isyaratify/models/hand_landmark_model.dart';
import 'package:isyaratify/platform/hand_tracking_platform.dart';
import 'package:isyaratify/services/hand_tracking_service.dart';

class _FakeService implements HandTrackingService {
  _FakeService({this.failInit = false});

  final bool failInit;
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> initialize() async {
    if (failInit) throw const HandTrackingException('gagal');
  }

  @override
  Stream<HandLandmarkFrame> start() => const Stream.empty();

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> dispose() async => disposeCalls++;
}

void main() {
  test(
    'stub platform mengikuti kontrak dan melaporkan belum diimplementasikan',
    () async {
      final service = createPlatformHandTrackingService();
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
    },
  );

  test('PracticeController: status ready bila initialize berhasil', () async {
    final c = PracticeController(_FakeService());
    await c.initialize();
    expect(c.status, PracticeStatus.ready);
    c.dispose();
  });

  test(
    'PracticeController: unavailable + pesan bila initialize gagal',
    () async {
      final c = PracticeController(_FakeService(failInit: true));
      await c.initialize();
      expect(c.status, PracticeStatus.unavailable);
      expect(c.message, 'gagal');
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
}
