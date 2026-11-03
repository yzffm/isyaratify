import '../core/errors/app_exceptions.dart';

/// Jumlah landmark per tangan pada MediaPipe Hand Landmarker.
const int kLandmarksPerHand = 21;

/// Jumlah tangan maksimum yang diakomodasi.
const int kMaxHands = 2;

/// Panjang vektor koordinat mentah: 2 tangan x 21 landmark x (x, y, z).
const int kCoordinatesPerFrame = kMaxHands * kLandmarksPerHand * 3;

enum HandSide {
  left,
  right;

  static HandSide parse(Object? value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'left':
          return HandSide.left;
        case 'right':
          return HandSide.right;
      }
    }
    throw LandmarkContractException('Handedness tidak valid: $value');
  }
}

double _finite(Object? value, String field) {
  if (value is num && value.isFinite) return value.toDouble();
  throw LandmarkContractException('Nilai $field tidak valid: $value');
}

class HandLandmark {
  const HandLandmark(this.x, this.y, this.z);

  /// Parsing di boundary JSON/interop; memvalidasi tipe dan nilai.
  factory HandLandmark.fromJson(Object? json) {
    if (json is! Map) {
      throw LandmarkContractException('Landmark harus berupa objek: $json');
    }
    return HandLandmark(
      _finite(json['x'], 'x'),
      _finite(json['y'], 'y'),
      _finite(json['z'], 'z'),
    );
  }

  final double x;
  final double y;
  final double z;

  Map<String, double> toJson() => {'x': x, 'y': y, 'z': z};

  @override
  bool operator ==(Object other) =>
      other is HandLandmark && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// Satu tangan: sisi (left/right) dan tepat [kLandmarksPerHand] landmark
/// dengan urutan standar MediaPipe.
class TrackedHand {
  TrackedHand({required this.side, required List<HandLandmark> landmarks})
    : landmarks = List.unmodifiable(landmarks) {
    if (landmarks.length != kLandmarksPerHand) {
      throw LandmarkContractException(
        'Tangan harus memiliki $kLandmarksPerHand landmark, '
        'diterima ${landmarks.length}.',
      );
    }
  }

  factory TrackedHand.fromJson(Object? json) {
    if (json is! Map) {
      throw LandmarkContractException('Tangan harus berupa objek: $json');
    }
    final raw = json['landmarks'];
    if (raw is! List) {
      throw const LandmarkContractException('Field landmarks harus list.');
    }
    return TrackedHand(
      side: HandSide.parse(json['handedness']),
      landmarks: raw.map(HandLandmark.fromJson).toList(),
    );
  }

  final HandSide side;
  final List<HandLandmark> landmarks;

  Map<String, Object?> toJson() => {
    'handedness': side.name,
    'landmarks': landmarks.map((l) => l.toJson()).toList(),
  };
}

/// Hasil tracking satu frame, kontrak yang sama untuk Web dan Android.
///
/// Urutan kanonik: left lalu right, terlepas dari urutan list sumber.
/// Presence per tangan ditentukan oleh [left] dan [right] yang tidak null.
class HandLandmarkFrame {
  HandLandmarkFrame({required this.timestamp, this.left, this.right}) {
    if (left != null && left!.side != HandSide.left) {
      throw const LandmarkContractException('Tangan left memiliki side lain.');
    }
    if (right != null && right!.side != HandSide.right) {
      throw const LandmarkContractException('Tangan right memiliki side lain.');
    }
  }

  /// Membentuk frame dari daftar tangan (0..2) dalam urutan apa pun.
  factory HandLandmarkFrame.fromHands({
    required DateTime timestamp,
    required Iterable<TrackedHand> hands,
  }) {
    final list = hands.toList();
    if (list.length > kMaxHands) {
      throw LandmarkContractException(
        'Maksimal $kMaxHands tangan, diterima ${list.length}.',
      );
    }
    TrackedHand? left;
    TrackedHand? right;
    for (final hand in list) {
      switch (hand.side) {
        case HandSide.left:
          if (left != null) {
            throw const LandmarkContractException('Tangan left ganda.');
          }
          left = hand;
        case HandSide.right:
          if (right != null) {
            throw const LandmarkContractException('Tangan right ganda.');
          }
          right = hand;
      }
    }
    return HandLandmarkFrame(timestamp: timestamp, left: left, right: right);
  }

  factory HandLandmarkFrame.fromJson(Object? json) {
    if (json is! Map) {
      throw LandmarkContractException('Frame harus berupa objek: $json');
    }
    final ts = json['timestamp'];
    final parsed = ts is String ? DateTime.tryParse(ts) : null;
    if (parsed == null) {
      throw LandmarkContractException('Timestamp tidak valid: $ts');
    }
    final hands = json['hands'];
    if (hands is! List) {
      throw const LandmarkContractException('Field hands harus list.');
    }
    return HandLandmarkFrame.fromHands(
      timestamp: parsed,
      hands: hands.map(TrackedHand.fromJson),
    );
  }

  final DateTime timestamp;
  final TrackedHand? left;
  final TrackedHand? right;

  /// Tangan yang terdeteksi, urutan left lalu right.
  List<TrackedHand> get hands => [?left, ?right];

  bool get hasLeft => left != null;
  bool get hasRight => right != null;
  bool get isEmpty => left == null && right == null;

  /// Indikator presence [left, right].
  List<bool> get presence => [hasLeft, hasRight];

  /// Koordinat mentah 126 nilai (left 63 + right 63, tiap landmark x,y,z).
  /// Tangan yang tidak ada diisi 0.0. Ini hanya kontrak mentah: normalisasi
  /// dan pengisian missing hand untuk model ditetapkan di FeatureService.
  List<double> toRawCoordinates() {
    final out = <double>[];
    for (final hand in [left, right]) {
      if (hand == null) {
        out.addAll(List<double>.filled(kLandmarksPerHand * 3, 0));
      } else {
        for (final l in hand.landmarks) {
          out
            ..add(l.x)
            ..add(l.y)
            ..add(l.z);
        }
      }
    }
    return out;
  }

  Map<String, Object?> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'hands': hands.map((h) => h.toJson()).toList(),
  };
}
