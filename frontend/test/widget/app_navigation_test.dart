import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/app.dart';
import 'package:isyaratify/core/errors/app_exceptions.dart';
import 'package:isyaratify/models/hand_landmark_model.dart';
import 'package:isyaratify/services/hand_tracking_service.dart';
import 'package:isyaratify/views/practice/practice_view.dart';

class _FakeHandTrackingService implements HandTrackingService {
  _FakeHandTrackingService({this.error});

  final HandTrackingException? error;

  @override
  Future<void> initialize() async {
    if (error != null) throw error!;
  }

  @override
  Stream<HandLandmarkFrame> start() => const Stream.empty();

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  testWidgets('splash -> login -> dashboard -> kamus & practice -> keluar', (
    tester,
  ) async {
    await tester.pumpWidget(
      IsyaratifyApp(handTrackingServiceFactory: _FakeHandTrackingService.new),
    );
    expect(find.text('Isyaratify'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('Lanjut (placeholder)'), findsOneWidget);

    await tester.tap(find.text('Lanjut (placeholder)'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);

    await tester.tap(find.text('Kamus alfabet'));
    await tester.pumpAndSettle();
    expect(find.textContaining('A–Z'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tentang Kami'));
    await tester.pumpAndSettle();
    expect(find.text('Visi Produk'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Latihan'));
    await tester.pumpAndSettle();
    expect(find.text('Pelacakan tangan siap.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Lanjut (placeholder)'), findsOneWidget);
  });

  testWidgets(
    'PracticeView menampilkan state unavailable saat fake melempar HandTrackingException',
    (tester) async {
      const errorMessage = 'Izin kamera ditolak pada pengujian.';
      await tester.pumpWidget(
        MaterialApp(
          home: PracticeView(
            serviceFactory: () => _FakeHandTrackingService(
              error: const HandTrackingException(errorMessage),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    },
  );
}
