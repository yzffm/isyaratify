import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/core/errors/app_exceptions.dart';
import 'package:isyaratify/models/hand_landmark_model.dart';

List<HandLandmark> _landmarks({
  int count = kLandmarksPerHand,
  double base = 0,
}) => List.generate(
  count,
  (i) => HandLandmark(base + i, base + i + 0.5, -i.toDouble()),
);

TrackedHand _hand(HandSide side, {double base = 0}) => TrackedHand(
  side: side,
  landmarks: _landmarks(base: base),
);

final _t = DateTime.utc(2026, 11, 4, 12);

void main() {
  group('TrackedHand', () {
    test('menerima tepat 21 landmark', () {
      expect(_hand(HandSide.left).landmarks.length, 21);
    });

    test('menolak jumlah landmark selain 21', () {
      expect(
        () =>
            TrackedHand(side: HandSide.left, landmarks: _landmarks(count: 20)),
        throwsA(isA<LandmarkContractException>()),
      );
      expect(
        () =>
            TrackedHand(side: HandSide.left, landmarks: _landmarks(count: 22)),
        throwsA(isA<LandmarkContractException>()),
      );
    });

    test('list landmark tidak dapat dimodifikasi', () {
      final h = _hand(HandSide.right);
      expect(
        () => h.landmarks.add(const HandLandmark(0, 0, 0)),
        throwsUnsupportedError,
      );
    });
  });

  group('HandLandmarkFrame', () {
    test('frame kosong: tanpa tangan', () {
      final f = HandLandmarkFrame.fromHands(timestamp: _t, hands: const []);
      expect(f.isEmpty, isTrue);
      expect(f.presence, [false, false]);
      expect(f.hands, isEmpty);
    });

    test('satu tangan: presence sesuai sisi', () {
      final f = HandLandmarkFrame.fromHands(
        timestamp: _t,
        hands: [_hand(HandSide.right)],
      );
      expect(f.presence, [false, true]);
      expect(f.hands.single.side, HandSide.right);
    });

    test('urutan kanonik left lalu right walau input terbalik', () {
      final f = HandLandmarkFrame.fromHands(
        timestamp: _t,
        hands: [_hand(HandSide.right), _hand(HandSide.left)],
      );
      expect(f.hands.map((h) => h.side), [HandSide.left, HandSide.right]);
      expect(f.presence, [true, true]);
    });

    test('menolak lebih dari dua tangan', () {
      expect(
        () => HandLandmarkFrame.fromHands(
          timestamp: _t,
          hands: [
            _hand(HandSide.left),
            _hand(HandSide.right),
            _hand(HandSide.left),
          ],
        ),
        throwsA(isA<LandmarkContractException>()),
      );
    });

    test('menolak sisi ganda', () {
      expect(
        () => HandLandmarkFrame.fromHands(
          timestamp: _t,
          hands: [_hand(HandSide.left), _hand(HandSide.left)],
        ),
        throwsA(isA<LandmarkContractException>()),
      );
    });

    test('konstruktor menolak tangan di slot yang salah', () {
      expect(
        () => HandLandmarkFrame(timestamp: _t, left: _hand(HandSide.right)),
        throwsA(isA<LandmarkContractException>()),
      );
    });

    test('koordinat mentah 126 nilai, urutan left lalu right, missing = 0', () {
      final both = HandLandmarkFrame.fromHands(
        timestamp: _t,
        hands: [_hand(HandSide.right, base: 100), _hand(HandSide.left)],
      ).toRawCoordinates();
      expect(both.length, kCoordinatesPerFrame);
      expect(both.length, 126);
      expect(both.sublist(0, 3), [0, 0.5, 0]); // landmark 0 left
      expect(both.sublist(63, 66), [100, 100.5, 0]); // landmark 0 right

      final onlyRight = HandLandmarkFrame.fromHands(
        timestamp: _t,
        hands: [_hand(HandSide.right, base: 1)],
      ).toRawCoordinates();
      expect(onlyRight.sublist(0, 63).every((v) => v == 0), isTrue);
      expect(onlyRight[63], 1);
    });
  });

  group('JSON', () {
    test('round-trip', () {
      final f = HandLandmarkFrame.fromHands(
        timestamp: _t,
        hands: [_hand(HandSide.left), _hand(HandSide.right, base: 5)],
      );
      final back = HandLandmarkFrame.fromJson(f.toJson());
      expect(back.timestamp, f.timestamp);
      expect(back.toRawCoordinates(), f.toRawCoordinates());
      expect(back.presence, [true, true]);
    });

    test('menolak handedness tidak dikenal', () {
      final json = {
        'timestamp': _t.toIso8601String(),
        'hands': [
          {
            'handedness': 'middle',
            'landmarks': _landmarks().map((l) => l.toJson()).toList(),
          },
        ],
      };
      expect(
        () => HandLandmarkFrame.fromJson(json),
        throwsA(isA<LandmarkContractException>()),
      );
    });

    test('menolak nilai non-numerik / NaN', () {
      expect(
        () => HandLandmark.fromJson({'x': 'a', 'y': 0, 'z': 0}),
        throwsA(isA<LandmarkContractException>()),
      );
      expect(
        () => HandLandmark.fromJson({'x': double.nan, 'y': 0, 'z': 0}),
        throwsA(isA<LandmarkContractException>()),
      );
    });

    test('menolak timestamp dan hands yang tidak valid', () {
      expect(
        () => HandLandmarkFrame.fromJson({'timestamp': 'x', 'hands': []}),
        throwsA(isA<LandmarkContractException>()),
      );
      expect(
        () => HandLandmarkFrame.fromJson({'timestamp': _t.toIso8601String()}),
        throwsA(isA<LandmarkContractException>()),
      );
      expect(
        () => HandLandmarkFrame.fromJson('bukan map'),
        throwsA(isA<LandmarkContractException>()),
      );
    });
  });
}
