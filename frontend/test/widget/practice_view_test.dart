import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/core/errors/app_exceptions.dart';
import 'package:isyaratify/core/theme/app_theme.dart';
import 'package:isyaratify/models/hand_landmark_model.dart';
import 'package:isyaratify/services/hand_tracking_service.dart';
import 'package:isyaratify/services/supabase_service.dart';
import 'package:isyaratify/services/sync_service.dart';
import 'package:isyaratify/views/practice/practice_view.dart';
import 'package:provider/provider.dart';

class _StreamingFakeHandTrackingService implements HandTrackingService {
  _StreamingFakeHandTrackingService({this.initException});

  final HandTrackingException? initException;
  final StreamController<HandLandmarkFrame> _controller =
      StreamController<HandLandmarkFrame>.broadcast();

  int stopCalls = 0;
  int disposeCalls = 0;

  void emitSingleHandFrame() {
    final landmarks = List<HandLandmark>.generate(kLandmarksPerHand, (idx) {
      if (idx == 0) return const HandLandmark(0.5, 0.85, 0.0);
      if (idx == 8 || idx == 12 || idx == 16 || idx == 20) {
        return const HandLandmark(0.5, 0.25, 0.0);
      }
      return const HandLandmark(0.5, 0.65, 0.0);
    });
    _controller.add(
      HandLandmarkFrame(
        timestamp: DateTime(2026, 11, 13, 2, 0),
        right: TrackedHand(
          side: HandSide.right,
          landmarks: landmarks,
          handednessScore: 0.9,
        ),
      ),
    );
  }

  @override
  Future<void> initialize() async {
    if (initException != null) {
      throw initException!;
    }
  }

  @override
  Stream<HandLandmarkFrame> start() => _controller.stream;

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    await _controller.close();
  }

  @override
  Widget buildPreview(BuildContext context) {
    return const Center(
      child: Text('Camera Feed Placeholder', key: ValueKey('camera_preview')),
    );
  }
}

Widget _buildPracticeHarness({
  required HandTrackingService Function() serviceFactory,
  String? initialTargetLetter,
}) {
  final supabase = SupabaseService(supabaseUrl: '', publishableKey: '');
  final sync = SyncService(supabaseService: supabase);

  return MultiProvider(
    providers: [
      Provider<SupabaseService>.value(value: supabase),
      Provider<SyncService>.value(value: sync),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: PracticeView(
        serviceFactory: serviceFactory,
        initialTargetLetter: initialTargetLetter,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'PracticeView desktop menampilkan pratinjau lokal, menerima landmark stream, memilih target, dan berhenti bersih',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _StreamingFakeHandTrackingService();
      await tester.pumpWidget(
        _buildPracticeHarness(serviceFactory: () => fakeService),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Practice BISINDO'), findsOneWidget);
      expect(find.text('Pelacakan tangan siap.'), findsOneWidget);
      expect(find.text('Tangan terdeteksi: 0/2'), findsOneWidget);
      expect(find.byKey(const ValueKey('camera_preview')), findsOneWidget);

      fakeService.emitSingleHandFrame();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Tangan terdeteksi: 1/2'), findsOneWidget);
      expect(find.textContaining('Prediksi: Huruf '), findsOneWidget);

      await tester.ensureVisible(find.text('C (1T)'));
      await tester.tap(find.text('C (1T)'));
      await tester.pumpAndSettle();

      expect(find.text('Latihan Target: Huruf C'), findsOneWidget);
      expect(find.text('Target: Huruf C'), findsOneWidget);

      fakeService.emitSingleHandFrame();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.ensureVisible(find.text('Periksa & Catat Gestur'));
      await tester.tap(find.text('Periksa & Catat Gestur'));
      await tester.pumpAndSettle();

      expect(find.text('1/1'), findsOneWidget);

      final stopButton = find.widgetWithText(OutlinedButton, 'Hentikan Kamera');
      await tester.ensureVisible(stopButton);
      await tester.pumpAndSettle();
      await tester.tap(stopButton);
      await tester.pumpAndSettle();

      expect(fakeService.stopCalls, greaterThanOrEqualTo(1));
      expect(find.text('Mulai / Coba Lagi Kamera'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(fakeService.stopCalls, greaterThanOrEqualTo(1));
      expect(fakeService.disposeCalls, greaterThanOrEqualTo(1));
    },
  );

  testWidgets(
    'PracticeView layar sempit menampilkan pesan dan recoveryHint saat kamera ditolak',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildPracticeHarness(
          serviceFactory: () => _StreamingFakeHandTrackingService(
            initException: const HandTrackingException(
              'Izin kamera ditolak oleh browser.',
              code: HandTrackingErrorCode.permissionDenied,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Izin kamera ditolak oleh browser.'), findsAtLeast(1));
      expect(
        find.text(
          'Izinkan akses kamera pada pengaturan browser atau perangkat Anda, lalu tekan Coba Lagi.',
        ),
        findsOneWidget,
      );
      expect(find.text('Coba Aktifkan Kamera'), findsOneWidget);
    },
  );
}
