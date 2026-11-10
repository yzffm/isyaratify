import '../core/errors/app_exceptions.dart';

/// Jumlah landmark per tangan pada MediaPipe Hand Landmarker.
const int kLandmarksPerHand = 21;

/// Jumlah tangan maksimum yang diakomodasi.
const int kMaxHands = 2;

/// Panjang vektor koordinat mentah: 2 tangan x 21 landmark x (x, y, z).
const int kCoordinatesPerFrame = kMaxHands * kLandmarksPerHand * 3; // 126

/// Panjang vektor fitur kanonik: 126 koordinat + 2 indikator presence.
const int kCanonicalFeatureLength = kCoordinatesPerFrame + kMaxHands; // 128

/// Sisi tangan menurut kanon proyek (urutan selalu: left lalu right).
enum HandSide {
  left,
  right;

  static HandSide parse(Object? raw) => switch (raw?.toString().toLowerCase()) {
    'left' => HandSide.left,
    'right' => HandSide.right,
    _ => throw LandmarkContractException('Handedness tidak valid: $raw'),
  };
}

/// Satu titik landmark 3D dari MediaPipe.
class HandLandmark {
  const HandLandmark(this.x, this.y, this.z);

  factory HandLandmark.fromJson(Object? json) {
    if (json is! Map) {
      throw LandmarkContractException('Landmark harus berupa objek: $json');
    }
    return HandLandmark(
      _num(json['x'], 'x'),
      _num(json['y'], 'y'),
      _num(json['z'], 'z'),
    );
  }

  final double x;
  final double y;
  final double z;

  static double _num(Object? v, String field) {
    if (v is num && v.isFinite) return v.toDouble();
    throw LandmarkContractException('Koordinat $field tidak valid: $v');
  }

  Map<String, double> toJson() => {'x': x, 'y': y, 'z': z};
}

/// Satu tangan terdeteksi beserta tepat [kLandmarksPerHand] landmark.
class TrackedHand {
  TrackedHand({
    required this.side,
    required List<HandLandmark> landmarks,
    this.handednessScore,
    List<HandLandmark>? worldLandmarks,
  }) : landmarks = List.unmodifiable(landmarks),
       worldLandmarks = worldLandmarks == null
           ? null
           : List.unmodifiable(worldLandmarks) {
    if (landmarks.length != kLandmarksPerHand) {
      throw LandmarkContractException(
        'Tangan harus memiliki $kLandmarksPerHand landmark, '
        'diterima ${landmarks.length}.',
      );
    }
    if (worldLandmarks != null && worldLandmarks.length != kLandmarksPerHand) {
      throw LandmarkContractException(
        'worldLandmarks harus memiliki $kLandmarksPerHand titik, '
        'diterima ${worldLandmarks.length}.',
      );
    }
    if (handednessScore != null &&
        (!handednessScore!.isFinite ||
            handednessScore! < 0.0 ||
            handednessScore! > 1.0)) {
      throw LandmarkContractException(
        'handednessScore harus berada di rentang 0..1: $handednessScore',
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
    final rawWorld = json['worldLandmarks'] ?? json['world_landmarks'];
    List<HandLandmark>? world;
    if (rawWorld != null) {
      if (rawWorld is! List) {
        throw const LandmarkContractException(
          'Field worldLandmarks harus list.',
        );
      }
      world = rawWorld.map(HandLandmark.fromJson).toList();
    }
    final rawScore = json['handednessScore'] ?? json['handedness_score'];
    double? score;
    if (rawScore != null) {
      if (rawScore is! num || !rawScore.isFinite) {
        throw LandmarkContractException(
          'Field handednessScore tidak valid: $rawScore',
        );
      }
      score = rawScore.toDouble();
    }
    return TrackedHand(
      side: HandSide.parse(json['handedness']),
      landmarks: raw.map(HandLandmark.fromJson).toList(),
      handednessScore: score,
      worldLandmarks: world,
    );
  }

  final HandSide side;
  final List<HandLandmark> landmarks;
  final double? handednessScore;
  final List<HandLandmark>? worldLandmarks;

  /// Titik wrist (landmark indeks 0).
  HandLandmark get wrist => landmarks.first;

  /// Membuat salinan tangan dengan sisi [newSide] (dipakai saat resolusi spasial).
  TrackedHand copyWithSide(HandSide newSide) => TrackedHand(
    side: newSide,
    landmarks: landmarks,
    handednessScore: handednessScore,
    worldLandmarks: worldLandmarks,
  );

  Map<String, Object?> toJson() => {
    'handedness': side.name,
    'landmarks': landmarks.map((l) => l.toJson()).toList(),
    if (handednessScore != null) 'handednessScore': handednessScore,
    if (worldLandmarks != null)
      'worldLandmarks': worldLandmarks!.map((l) => l.toJson()).toList(),
  };
}

/// Hasil tracking satu frame, kontrak yang sama untuk Web dan Android (ADR 0002).
///
/// Urutan kanonik: left lalu right, terlepas dari urutan list sumber.
/// Presence per tangan ditentukan oleh [left] dan [right] yang tidak null.
class HandLandmarkFrame {
  HandLandmarkFrame({
    required this.timestamp,
    this.left,
    this.right,
    this.isHandednessInferred = false,
    this.imageWidth,
    this.imageHeight,
    this.isMirrored = false,
  }) {
    if (left != null && left!.side != HandSide.left) {
      throw const LandmarkContractException('Tangan left memiliki side lain.');
    }
    if (right != null && right!.side != HandSide.right) {
      throw const LandmarkContractException('Tangan right memiliki side lain.');
    }
    if (imageWidth != null && imageWidth! <= 0) {
      throw LandmarkContractException('imageWidth tidak valid: $imageWidth');
    }
    if (imageHeight != null && imageHeight! <= 0) {
      throw LandmarkContractException('imageHeight tidak valid: $imageHeight');
    }
  }

  /// Membentuk frame dari daftar tangan (0..2) dalam urutan apa pun.
  ///
  /// Bila [resolveDuplicateSides] bernilai `true` dan 2 tangan memiliki label
  /// [HandSide] yang sama, keduanya diurutkan secara spasial berdasarkan
  /// koordinat `x` wrist (`landmarks[0].x` lebih kecil menjadi `left`, lebih
  /// besar menjadi `right`) dan [isHandednessInferred] ditandai `true`.
  factory HandLandmarkFrame.fromHands({
    required DateTime timestamp,
    required Iterable<TrackedHand> hands,
    bool resolveDuplicateSides = false,
    int? imageWidth,
    int? imageHeight,
    bool isMirrored = false,
  }) {
    final list = hands.toList();
    if (list.length > kMaxHands) {
      throw LandmarkContractException(
        'Maksimal $kMaxHands tangan, diterima ${list.length}.',
      );
    }
    if (list.length == 2 && list[0].side == list[1].side) {
      if (!resolveDuplicateSides) {
        throw LandmarkContractException('Tangan ${list[0].side.name} ganda.');
      }
      final sorted = [...list]..sort((a, b) => a.wrist.x.compareTo(b.wrist.x));
      return HandLandmarkFrame(
        timestamp: timestamp,
        left: sorted[0].copyWithSide(HandSide.left),
        right: sorted[1].copyWithSide(HandSide.right),
        isHandednessInferred: true,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        isMirrored: isMirrored,
      );
    }

    TrackedHand? left;
    TrackedHand? right;
    for (final hand in list) {
      switch (hand.side) {
        case HandSide.left:
          left = hand;
        case HandSide.right:
          right = hand;
      }
    }
    return HandLandmarkFrame(
      timestamp: timestamp,
      left: left,
      right: right,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      isMirrored: isMirrored,
    );
  }

  factory HandLandmarkFrame.fromJson(
    Object? json, {
    bool resolveDuplicateSides = false,
  }) {
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
    final rawWidth = json['imageWidth'] ?? json['image_width'];
    final rawHeight = json['imageHeight'] ?? json['image_height'];
    final rawMirrored = json['isMirrored'] ?? json['is_mirrored'];
    return HandLandmarkFrame.fromHands(
      timestamp: parsed,
      hands: hands.map(TrackedHand.fromJson),
      resolveDuplicateSides: resolveDuplicateSides,
      imageWidth: rawWidth is num ? rawWidth.toInt() : null,
      imageHeight: rawHeight is num ? rawHeight.toInt() : null,
      isMirrored: rawMirrored is bool ? rawMirrored : false,
    );
  }

  final DateTime timestamp;
  final TrackedHand? left;
  final TrackedHand? right;
  final bool isHandednessInferred;
  final int? imageWidth;
  final int? imageHeight;
  final bool isMirrored;

  /// Tangan yang terdeteksi, urutan left lalu right.
  List<TrackedHand> get hands => [?left, ?right];

  int get handCount => (left != null ? 1 : 0) + (right != null ? 1 : 0);

  bool get hasLeft => left != null;
  bool get hasRight => right != null;
  bool get isEmpty => left == null && right == null;
  bool get hasAnyHand => !isEmpty;
  int get timestampMs => timestamp.millisecondsSinceEpoch;

  /// Indikator presence [left, right].
  List<bool> get presence => [hasLeft, hasRight];

  /// Vektor fitur kanonik 128 nilai: 126 koordinat mentah + 2 indikator presence.
  List<double> toCanonicalFeatureVector() => [
    ...toRawCoordinates(),
    hasLeft ? 1.0 : 0.0,
    hasRight ? 1.0 : 0.0,
  ];

  /// Koordinat mentah 126 nilai (left 63 + right 63, tiap landmark x,y,z).
  /// Tangan yang tidak ada diisi 0.0.
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
    if (isHandednessInferred) 'isHandednessInferred': isHandednessInferred,
    if (imageWidth != null) 'imageWidth': imageWidth,
    if (imageHeight != null) 'imageHeight': imageHeight,
    if (isMirrored) 'isMirrored': isMirrored,
  };
}
