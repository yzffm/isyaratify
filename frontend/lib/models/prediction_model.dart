import 'dart:collection';

import '../core/errors/app_exceptions.dart';

/// Hasil prediksi classifier lokal pada satu frame landmark (`Technical-Docs.md` §6.6).
///
/// Catatan: [score] adalah skor keyakinan output model (belum tentu probabilitas
/// terkalibrasi).
class GesturePrediction {
  GesturePrediction({
    required this.letter,
    required this.score,
    required this.isStable,
    required this.timestamp,
    this.inferenceMs,
  }) {
    if (!RegExp(r'^[A-Z]$').hasMatch(letter)) {
      throw LandmarkContractException(
        'Huruf prediksi harus A–Z, diterima: $letter',
      );
    }
    if (!score.isFinite || score < 0.0 || score > 1.0) {
      throw LandmarkContractException(
        'Skor prediksi harus berada di rentang 0..1: $score',
      );
    }
  }

  factory GesturePrediction.fromJson(Map<String, Object?> json) {
    final rawLetter = (json['predicted_letter'] ?? json['letter'] ?? '')
        .toString()
        .trim();
    final rawScore = json['score'] ?? json['confidence'] ?? 0.0;
    final rawStable = json['is_stable'] ?? json['isStable'] ?? false;
    final rawTs = json['timestamp']?.toString();
    final rawMs = json['inference_ms'] ?? json['inferenceMs'];
    return GesturePrediction(
      letter: rawLetter.toUpperCase(),
      score: rawScore is num ? rawScore.toDouble() : 0.0,
      isStable: rawStable is bool ? rawStable : false,
      timestamp:
          (rawTs != null ? DateTime.tryParse(rawTs) : null) ?? DateTime.now(),
      inferenceMs: rawMs is num ? rawMs.toInt() : null,
    );
  }

  final String letter;
  final double score;
  final bool isStable;
  final DateTime timestamp;
  final int? inferenceMs;

  GesturePrediction copyWith({bool? isStable}) => GesturePrediction(
    letter: letter,
    score: score,
    isStable: isStable ?? this.isStable,
    timestamp: timestamp,
    inferenceMs: inferenceMs,
  );

  Map<String, Object?> toJson() => {
    'predicted_letter': letter,
    'score': score,
    'is_stable': isStable,
    'timestamp': timestamp.toIso8601String(),
    if (inferenceMs != null) 'inference_ms': inferenceMs,
  };
}

/// Temporal smoothing & debounce untuk mencegah flicker label dan pemberian XP
/// ganda pada satu gestur yang sama (`AGENTS.md` §5.6).
class TemporalSmoother {
  TemporalSmoother({
    this.windowSize = 5,
    this.minMajorityCount = 3,
    this.confidenceThreshold = 0.65,
  }) : assert(windowSize >= 1),
       assert(minMajorityCount >= 1 && minMajorityCount <= windowSize);

  final int windowSize;
  final int minMajorityCount;
  final double confidenceThreshold;

  final ListQueue<GesturePrediction> _window = ListQueue<GesturePrediction>();
  String? _lastAwardedLetter;

  /// Menambahkan prediksi mentah ke jendela waktu dan mengembalikan prediksi
  /// dengan status [GesturePrediction.isStable] yang telah dievaluasi.
  GesturePrediction add(GesturePrediction raw) {
    if (raw.score < confidenceThreshold) {
      _window.clear();
      _lastAwardedLetter = null;
      return raw.copyWith(isStable: false);
    }

    _window.addLast(raw);
    while (_window.length > windowSize) {
      _window.removeFirst();
    }

    final counts = <String, int>{};
    final scoreSums = <String, double>{};
    for (final p in _window) {
      counts[p.letter] = (counts[p.letter] ?? 0) + 1;
      scoreSums[p.letter] = (scoreSums[p.letter] ?? 0.0) + p.score;
    }

    String? bestLetter;
    var bestCount = 0;
    counts.forEach((letter, count) {
      if (count > bestCount) {
        bestCount = count;
        bestLetter = letter;
      }
    });

    if (bestLetter != null && bestCount >= minMajorityCount) {
      final avgScore = (scoreSums[bestLetter!] ?? raw.score) / bestCount;
      return GesturePrediction(
        letter: bestLetter!,
        score: avgScore.clamp(0.0, 1.0),
        isStable: true,
        timestamp: raw.timestamp,
        inferenceMs: raw.inferenceMs,
      );
    }

    return raw.copyWith(isStable: false);
  }

  /// Memeriksa apakah prediksi stabil ini berhak dicatat sebagai attempt baru
  /// (mencegah satu gestur statis yang ditahan terus-menerus memberi XP berulang
  /// pada setiap frame).
  bool consumeAttemptEligibility(GesturePrediction prediction) {
    if (!prediction.isStable) return false;
    if (_lastAwardedLetter == prediction.letter) return false;
    _lastAwardedLetter = prediction.letter;
    return true;
  }

  /// Mengizinkan pencatatan ulang untuk huruf yang sama (mis. ketika pengguna
  /// menekan tombol "Coba Lagi" atau mengganti huruf target).
  void resetDebounce() {
    _lastAwardedLetter = null;
  }

  /// Mengosongkan seluruh riwayat jendela smoothing.
  void clear() {
    _window.clear();
    _lastAwardedLetter = null;
  }
}
