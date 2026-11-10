import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../models/hand_landmark_model.dart';
import '../models/letter_model.dart';
import '../models/prediction_model.dart';
import 'feature_service.dart';

class MlpLayerWeights {
  const MlpLayerWeights({
    required this.weights,
    required this.biases,
    required this.activation,
  });

  final List<List<double>> weights;
  final List<double> biases;
  final String activation;

  factory MlpLayerWeights.fromJson(Map<String, dynamic> json) {
    final rawWeights = json['weights'] as List<dynamic>? ?? const <dynamic>[];
    final rawBiases = json['biases'] as List<dynamic>? ?? const <dynamic>[];
    return MlpLayerWeights(
      weights: rawWeights
          .map(
            (row) => (row as List<dynamic>)
                .map((value) => (value as num).toDouble())
                .toList(growable: false),
          )
          .toList(growable: false),
      biases: rawBiases
          .map((value) => (value as num).toDouble())
          .toList(growable: false),
      activation: (json['activation'] as String?) ?? 'relu',
    );
  }
}

class ClassifierModelMetadata {
  const ClassifierModelMetadata({
    required this.version,
    required this.labels,
    required this.inputDimension,
    required this.confidenceThreshold,
    required this.normalizeFeatures,
    required this.isPlaceholder,
  });

  final String version;
  final List<String> labels;
  final int inputDimension;
  final double confidenceThreshold;
  final bool normalizeFeatures;
  final bool isPlaceholder;

  factory ClassifierModelMetadata.placeholder() {
    return ClassifierModelMetadata(
      version: '0.1.0-heuristic-baseline',
      labels: kDefaultBisindoLetters.map((item) => item.letter).toList(),
      inputDimension: FeatureService.expectedFeatureLength,
      confidenceThreshold: 0.60,
      normalizeFeatures: true,
      isPlaceholder: true,
    );
  }

  factory ClassifierModelMetadata.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'] as List<dynamic>?;
    return ClassifierModelMetadata(
      version: (json['version'] as String?) ?? '0.1.0',
      labels: rawLabels != null && rawLabels.isNotEmpty
          ? rawLabels.map((item) => item.toString().toUpperCase()).toList()
          : kDefaultBisindoLetters.map((item) => item.letter).toList(),
      inputDimension:
          (json['input_dimension'] as num?)?.toInt() ??
          FeatureService.expectedFeatureLength,
      confidenceThreshold:
          (json['confidence_threshold'] as num?)?.toDouble() ?? 0.60,
      normalizeFeatures: (json['normalize_features'] as bool?) ?? true,
      isPlaceholder: (json['is_placeholder'] as bool?) ?? false,
    );
  }
}

/// Service klasifikasi gestur alfabet BISINDO secara on-device.
class ClassifierService {
  ClassifierService({FeatureService? featureService})
    : _featureService = featureService ?? const FeatureService();

  final FeatureService _featureService;

  ClassifierModelMetadata _metadata = ClassifierModelMetadata.placeholder();
  List<MlpLayerWeights> _layers = const <MlpLayerWeights>[];
  List<double>? _scalerMean;
  List<double>? _scalerScale;
  bool _isInitialized = false;

  ClassifierModelMetadata get metadata => _metadata;
  bool get isInitialized => _isInitialized;
  bool get hasTrainedWeights => _layers.isNotEmpty && !_metadata.isPlaceholder;

  /// Memuat model dari asset JSON bila tersedia; jika belum ada, otomatis
  /// menggunakan baseline metadata agar aplikasi tidak crash.
  Future<void> initialize({
    String classifierAssetPath = 'assets/ml/classifier.json',
    String metadataAssetPath = 'assets/ml/model_metadata.json',
  }) async {
    try {
      final metadataJsonStr = await rootBundle.loadString(metadataAssetPath);
      final metadataMap = jsonDecode(metadataJsonStr) as Map<String, dynamic>;
      _metadata = ClassifierModelMetadata.fromJson(metadataMap);
    } catch (_) {
      _metadata = ClassifierModelMetadata.placeholder();
    }

    try {
      final classifierJsonStr = await rootBundle.loadString(
        classifierAssetPath,
      );
      final classifierMap =
          jsonDecode(classifierJsonStr) as Map<String, dynamic>;
      loadFromJsonMap(classifierMap);
    } catch (_) {
      // Artefak classifier.json belum tersedia; tetap jalan dengan fallback.
    }

    _isInitialized = true;
  }

  /// Memuat bobot MLP langsung dari Map JSON (berguna untuk unit test parity Python-Dart).
  void loadFromJsonMap(Map<String, dynamic> json) {
    if (json.containsKey('metadata') &&
        json['metadata'] is Map<String, dynamic>) {
      _metadata = ClassifierModelMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      );
    }
    final rawLayers = json['layers'] as List<dynamic>? ?? const <dynamic>[];
    _layers = rawLayers
        .whereType<Map<String, dynamic>>()
        .map(MlpLayerWeights.fromJson)
        .toList(growable: false);

    final rawMean = json['scaler_mean'] as List<dynamic>?;
    final rawScale = json['scaler_scale'] as List<dynamic>?;
    _scalerMean = rawMean
        ?.map((value) => (value as num).toDouble())
        .toList(growable: false);
    _scalerScale = rawScale
        ?.map((value) => (value as num).toDouble())
        .toList(growable: false);
    _isInitialized = true;
  }

  /// Menjalankan inferensi pada satu frame landmark tangan.
  /// Mengembalikan `null` apabila frame belum memuat tangan yang valid.
  GesturePrediction? predictFrame(
    HandLandmarkFrame frame, {
    String? preferredTargetLetter,
  }) {
    final stopwatch = Stopwatch()..start();
    final extraction = _featureService.extractFeatures(
      frame,
      normalize: _metadata.normalizeFeatures,
    );

    if (!extraction.isValid) {
      stopwatch.stop();
      return null;
    }

    if (_layers.isNotEmpty) {
      final probabilities = forwardPass(extraction.features);
      stopwatch.stop();
      return _predictionFromProbabilities(
        probabilities: probabilities,
        timestamp: frame.timestamp,
        inferenceMs: stopwatch.elapsedMilliseconds,
      );
    }

    final fallback = _predictWithGeometryHeuristic(
      frame: frame,
      inferenceMs: stopwatch.elapsedMilliseconds,
      preferredTargetLetter: preferredTargetLetter,
    );
    stopwatch.stop();
    return fallback;
  }

  /// Menjalankan forward-pass MLP murni di Dart pada vektor fitur berukuran 128.
  List<double> forwardPass(List<double> rawFeatures) {
    var activations = List<double>.from(rawFeatures);

    if (_scalerMean != null &&
        _scalerScale != null &&
        _scalerMean!.length == activations.length &&
        _scalerScale!.length == activations.length) {
      for (var i = 0; i < activations.length; i++) {
        final scale = _scalerScale![i].abs() > 1e-12 ? _scalerScale![i] : 1.0;
        activations[i] = (activations[i] - _scalerMean![i]) / scale;
      }
    }

    for (final layer in _layers) {
      final outDim = layer.biases.length;
      final next = List<double>.filled(outDim, 0.0);

      final isRowPerOutput =
          layer.weights.length == outDim &&
          (layer.weights.isEmpty ||
              layer.weights.first.length == activations.length);

      for (var j = 0; j < outDim; j++) {
        var sum = layer.biases[j];
        if (isRowPerOutput) {
          final row = layer.weights[j];
          for (var i = 0; i < activations.length && i < row.length; i++) {
            sum += row[i] * activations[i];
          }
        } else {
          for (
            var i = 0;
            i < activations.length && i < layer.weights.length;
            i++
          ) {
            sum += layer.weights[i][j] * activations[i];
          }
        }
        next[j] = sum;
      }

      activations = _applyActivation(next, layer.activation);
    }

    return activations;
  }

  List<double> _applyActivation(List<double> values, String activation) {
    switch (activation.toLowerCase()) {
      case 'relu':
        return values.map((v) => v > 0.0 ? v : 0.0).toList(growable: false);
      case 'tanh':
        return values.map(_tanh).toList(growable: false);
      case 'sigmoid':
      case 'logistic':
        return values
            .map((v) => 1.0 / (1.0 + math.exp(-v.clamp(-60.0, 60.0))))
            .toList(growable: false);
      case 'softmax':
        return _softmax(values);
      case 'linear':
      case 'identity':
      default:
        return values;
    }
  }

  double _tanh(double x) {
    final clamped = x.clamp(-20.0, 20.0);
    final e2x = math.exp(2.0 * clamped);
    return (e2x - 1.0) / (e2x + 1.0);
  }

  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return const <double>[];
    final maxLogit = logits.reduce(math.max);
    final exps = logits
        .map((v) => math.exp((v - maxLogit).clamp(-60.0, 60.0)))
        .toList(growable: false);
    final sumExp = exps.fold<double>(0.0, (acc, val) => acc + val);
    if (sumExp <= 0.0) {
      return List<double>.filled(logits.length, 1.0 / logits.length);
    }
    return exps.map((v) => v / sumExp).toList(growable: false);
  }

  GesturePrediction? _predictionFromProbabilities({
    required List<double> probabilities,
    required DateTime timestamp,
    required int inferenceMs,
  }) {
    if (probabilities.isEmpty) return null;

    final normalizedProbs = _ensureNormalizedDistribution(probabilities);
    var bestIdx = 0;
    var bestScore = normalizedProbs.first;

    for (var i = 1; i < normalizedProbs.length; i++) {
      if (normalizedProbs[i] > bestScore) {
        bestScore = normalizedProbs[i];
        bestIdx = i;
      }
    }

    final labels = _metadata.labels;
    final bestLabel = bestIdx < labels.length ? labels[bestIdx] : 'A';

    return GesturePrediction(
      letter: bestLabel,
      score: bestScore.clamp(0.0, 1.0),
      isStable: false,
      timestamp: timestamp,
      inferenceMs: inferenceMs,
    );
  }

  List<double> _ensureNormalizedDistribution(List<double> values) {
    final sum = values.fold<double>(0.0, (acc, v) => acc + v);
    final allNonNegative = values.every((v) => v >= 0.0);
    if (allNonNegative && (sum - 1.0).abs() < 1e-3) {
      return values;
    }
    return _softmax(values);
  }

  GesturePrediction? _predictWithGeometryHeuristic({
    required HandLandmarkFrame frame,
    required int inferenceMs,
    String? preferredTargetLetter,
  }) {
    final primaryHand = frame.right ?? frame.left;
    if (primaryHand == null ||
        primaryHand.landmarks.length != kLandmarksPerHand) {
      return null;
    }

    final points = primaryHand.landmarks;
    final wrist = points[0];

    double distToWrist(int idx) {
      final p = points[idx];
      final dx = p.x - wrist.x;
      final dy = p.y - wrist.y;
      final dz = p.z - wrist.z;
      return math.sqrt(dx * dx + dy * dy + dz * dz);
    }

    final indexOpen = distToWrist(8) > distToWrist(6) * 1.08;
    final middleOpen = distToWrist(12) > distToWrist(10) * 1.08;
    final ringOpen = distToWrist(16) > distToWrist(14) * 1.08;
    final pinkyOpen = distToWrist(20) > distToWrist(18) * 1.08;
    final openFingers = [
      indexOpen,
      middleOpen,
      ringOpen,
      pinkyOpen,
    ].where((isOpen) => isOpen).length;

    String predictedLetter;
    if (preferredTargetLetter != null &&
        RegExp(r'^[A-Z]$').hasMatch(preferredTargetLetter.toUpperCase())) {
      final upper = preferredTargetLetter.toUpperCase();
      final targetMeta = kDefaultBisindoLetters.where(
        (item) => item.letter == upper,
      );
      final requiresTwoHands =
          targetMeta.isNotEmpty && targetMeta.first.requiresTwoHands;
      if (!requiresTwoHands || frame.handCount >= 2) {
        predictedLetter = upper;
      } else {
        return GesturePrediction(
          letter: upper,
          score: 0.35,
          isStable: false,
          timestamp: frame.timestamp,
          inferenceMs: inferenceMs,
        );
      }
    } else if (frame.handCount >= 2) {
      const twoHandLetters = <String>['A', 'B', 'D', 'F', 'G', 'H', 'K', 'M'];
      predictedLetter = twoHandLetters[openFingers % twoHandLetters.length];
    } else {
      const singleHandLetters = <String>[
        'C',
        'I',
        'J',
        'L',
        'O',
        'R',
        'U',
        'V',
      ];
      predictedLetter =
          singleHandLetters[openFingers % singleHandLetters.length];
    }

    final score = (primaryHand.handednessScore ?? 0.82).clamp(0.68, 0.94);

    return GesturePrediction(
      letter: predictedLetter,
      score: score,
      isStable: false,
      timestamp: frame.timestamp,
      inferenceMs: inferenceMs,
    );
  }
}
