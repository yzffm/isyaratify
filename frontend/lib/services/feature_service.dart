import 'dart:math' as math;

import '../models/hand_landmark_model.dart';

class FeatureExtractionResult {
  const FeatureExtractionResult({
    required this.features,
    required this.leftPresent,
    required this.rightPresent,
    required this.handCount,
    required this.isValid,
    this.invalidReason,
  });

  final List<double> features;
  final bool leftPresent;
  final bool rightPresent;
  final int handCount;
  final bool isValid;
  final String? invalidReason;
}

/// Service untuk mengekstrak dan menormalisasi fitur landmark tangan secara konsisten
/// antara pipeline eksperimen Python (`ml/src/feature_extraction.py`) dan runtime
/// on-device Dart.
///
/// Mendukung dua skema dimensi fitur:
/// 1. **Skema MLP Produksi (126 elemen — `kRawCoordinateCount`):**
///    - Tangan diurutkan dari kiri ke kanan layar berdasarkan `wrist.x` (`landmarks[0].x`).
///    - Setiap tangan dinormalisasi terhadap titik wrist-nya masing-masing (`coords - wrist`
///      dibagi jarak Euclidean maksimum dari wrist).
///    - Indeks 0..62   : 21 landmark tangan ke-1 (x, y, z)
///    - Indeks 63..125 : 21 landmark tangan ke-2 (x, y, z), atau 0.0 jika 1 tangan.
/// 2. **Skema Kanonik + Presence (128 elemen — `kCanonicalFeatureLength`):**
///    - Indeks 0..62   : 21 landmark tangan kiri (x, y, z)
///    - Indeks 63..125 : 21 landmark tangan kanan (x, y, z)
///    - Indeks 126     : left_present (1.0 atau 0.0)
///    - Indeks 127     : right_present (1.0 atau 0.0)
class FeatureService {
  const FeatureService({this.minHandednessScore = 0.4});

  final double minHandednessScore;

  static const int expectedFeatureLength = kCanonicalFeatureLength;
  static const int mlpFeatureLength = kLandmarksPerHand * 3 * 2; // 126

  /// Mengecek apakah frame memiliki minimal satu tangan yang valid untuk inferensi.
  bool isFrameValidForInference(HandLandmarkFrame frame) {
    if (frame.isEmpty) return false;
    if (frame.left != null &&
        frame.left!.landmarks.length != kLandmarksPerHand) {
      return false;
    }
    if (frame.right != null &&
        frame.right!.landmarks.length != kLandmarksPerHand) {
      return false;
    }
    return true;
  }

  /// Normalisasi 21 titik satu tangan relatif terhadap wrist (`landmarks[0]`),
  /// identik dengan `normalize_single_hand` di `ml/src/feature_extraction.py`.
  List<double> normalizeSingleHand(TrackedHand hand) {
    final wrist = hand.wrist;
    var maxDist = 0.0;

    for (final pt in hand.landmarks) {
      final dx = pt.x - wrist.x;
      final dy = pt.y - wrist.y;
      final dz = pt.z - wrist.z;
      final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
      if (dist > maxDist) {
        maxDist = dist;
      }
    }

    final scale = maxDist > 1e-6 ? maxDist : 1.0;
    final out = <double>[];
    for (final pt in hand.landmarks) {
      out
        ..add((pt.x - wrist.x) / scale)
        ..add((pt.y - wrist.y) / scale)
        ..add((pt.z - wrist.z) / scale);
    }
    return out;
  }

  /// Mengekstrak vektor fitur 126-dimensi yang 100% kompatibel dengan model
  /// MLP hasil pelatihan di `ml/src/feature_extraction.py` dan `ml/src/train.py`.
  FeatureExtractionResult extractMlpFeatures126(
    HandLandmarkFrame frame, {
    bool normalize = true,
  }) {
    if (!isFrameValidForInference(frame)) {
      return FeatureExtractionResult(
        features: List<double>.filled(mlpFeatureLength, 0.0),
        leftPresent: false,
        rightPresent: false,
        handCount: 0,
        isValid: false,
        invalidReason: 'Tangan belum terdeteksi di kamera.',
      );
    }

    if (!normalize) {
      final raw = frame.toRawCoordinates();
      return FeatureExtractionResult(
        features: List<double>.unmodifiable(raw),
        leftPresent: frame.hasLeft,
        rightPresent: frame.hasRight,
        handCount: frame.handCount,
        isValid: true,
      );
    }

    final detectedHands = <TrackedHand>[
      if (frame.left != null) frame.left!,
      if (frame.right != null) frame.right!,
    ]..sort((a, b) => a.wrist.x.compareTo(b.wrist.x));

    final values = <double>[];
    values.addAll(normalizeSingleHand(detectedHands[0]));

    if (detectedHands.length > 1) {
      values.addAll(normalizeSingleHand(detectedHands[1]));
    } else {
      values.addAll(List<double>.filled(kLandmarksPerHand * 3, 0.0));
    }

    return FeatureExtractionResult(
      features: List<double>.unmodifiable(values),
      leftPresent: frame.hasLeft,
      rightPresent: frame.hasRight,
      handCount: detectedHands.length,
      isValid: true,
    );
  }

  /// Mengekstrak vektor fitur ternormalisasi (default 128 float, atau 126 float
  /// bila [targetDimension] == 126).
  FeatureExtractionResult extractFeatures(
    HandLandmarkFrame frame, {
    bool normalize = true,
    int targetDimension = expectedFeatureLength,
  }) {
    if (targetDimension == mlpFeatureLength) {
      return extractMlpFeatures126(frame, normalize: normalize);
    }

    if (frame.isEmpty) {
      return FeatureExtractionResult(
        features: List<double>.filled(expectedFeatureLength, 0.0),
        leftPresent: false,
        rightPresent: false,
        handCount: 0,
        isValid: false,
        invalidReason: 'Tangan belum terdeteksi di kamera.',
      );
    }

    final left = frame.left;
    final right = frame.right;

    if (!normalize) {
      final raw = frame.toCanonicalFeatureVector();
      return FeatureExtractionResult(
        features: List<double>.unmodifiable(raw),
        leftPresent: frame.hasLeft,
        rightPresent: frame.hasRight,
        handCount: frame.handCount,
        isValid: true,
      );
    }

    // Hitung titik referensi (anchor) dan skala bersama agar relasi antartangan
    // tetap terjaga ketika dua tangan terdeteksi (AGENTS.md §5.4).
    final leftWrist = left?.wrist;
    final rightWrist = right?.wrist;

    final double refX;
    final double refY;
    final double refZ;

    if (leftWrist != null && rightWrist != null) {
      refX = (leftWrist.x + rightWrist.x) / 2.0;
      refY = (leftWrist.y + rightWrist.y) / 2.0;
      refZ = (leftWrist.z + rightWrist.z) / 2.0;
    } else if (leftWrist != null) {
      refX = leftWrist.x;
      refY = leftWrist.y;
      refZ = leftWrist.z;
    } else {
      refX = rightWrist!.x;
      refY = rightWrist.y;
      refZ = rightWrist.z;
    }

    var maxDistance = 0.0;
    void updateMaxDistance(TrackedHand? hand) {
      if (hand == null) return;
      for (final point in hand.landmarks) {
        final dx = point.x - refX;
        final dy = point.y - refY;
        final dz = point.z - refZ;
        final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
        if (dist > maxDistance) {
          maxDistance = dist;
        }
      }
    }

    updateMaxDistance(left);
    updateMaxDistance(right);
    final scale = maxDistance > 1e-6 ? maxDistance : 1.0;

    final values = <double>[];

    void appendNormalizedHand(TrackedHand? hand) {
      if (hand == null) {
        values.addAll(List<double>.filled(kLandmarksPerHand * 3, 0.0));
        return;
      }
      for (final point in hand.landmarks) {
        values
          ..add((point.x - refX) / scale)
          ..add((point.y - refY) / scale)
          ..add((point.z - refZ) / scale);
      }
    }

    appendNormalizedHand(left);
    appendNormalizedHand(right);
    values
      ..add(frame.hasLeft ? 1.0 : 0.0)
      ..add(frame.hasRight ? 1.0 : 0.0);

    return FeatureExtractionResult(
      features: List<double>.unmodifiable(values),
      leftPresent: frame.hasLeft,
      rightPresent: frame.hasRight,
      handCount: frame.handCount,
      isValid: true,
    );
  }
}
