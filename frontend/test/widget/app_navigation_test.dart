import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/app.dart';

void main() {
  testWidgets('splash -> login -> dashboard -> kamus & practice -> keluar', (
    tester,
  ) async {
    await tester.pumpWidget(const IsyaratifyApp());
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

    await tester.tap(find.text('Latihan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('belum diimplementasikan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Lanjut (placeholder)'), findsOneWidget);
  });
}
