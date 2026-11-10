import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/models/attempt_model.dart';
import 'package:isyaratify/models/hand_landmark_model.dart';
import 'package:isyaratify/models/prediction_model.dart';
import 'package:isyaratify/models/progress_model.dart';
import 'package:isyaratify/services/classifier_service.dart';
import 'package:isyaratify/services/feature_service.dart';
import 'package:isyaratify/services/supabase_service.dart';
import 'package:isyaratify/services/sync_service.dart';

List<HandLandmark> _buildLandmarks({double offsetX = 0.0}) {
  return List<HandLandmark>.generate(
    kLandmarksPerHand,
    (index) =>
        HandLandmark(offsetX + index * 0.02, index * 0.03, -index * 0.005),
  );
}

void main() {
  final sampleTime = DateTime.utc(2026, 11, 10, 12);

  group('FeatureService', () {
    const featureService = FeatureService();

    test('frame kosong menghasilkan isValid = false dan 128 nilai 0', () {
      final emptyFrame = HandLandmarkFrame.fromHands(
        timestamp: sampleTime,
        hands: const <TrackedHand>[],
      );
      final res = featureService.extractFeatures(emptyFrame);
      expect(res.isValid, isFalse);
      expect(res.features.length, 128);
      expect(res.features.every((v) => v == 0.0), isTrue);
    });

    test(
      'frame 2 tangan mempertahankan posisi relatif antartangan dan presence [1, 1]',
      () {
        final leftHand = TrackedHand(
          side: HandSide.left,
          landmarks: _buildLandmarks(offsetX: 0.2),
          handednessScore: 0.95,
        );
        final rightHand = TrackedHand(
          side: HandSide.right,
          landmarks: _buildLandmarks(offsetX: 0.8),
          handednessScore: 0.92,
        );
        final frame = HandLandmarkFrame.fromHands(
          timestamp: sampleTime,
          hands: <TrackedHand>[leftHand, rightHand],
        );

        final res = featureService.extractFeatures(frame, normalize: true);
        expect(res.isValid, isTrue);
        expect(res.handCount, 2);
        expect(res.features.length, 128);
        expect(res.features[126], 1.0);
        expect(res.features[127], 1.0);
        expect(res.features[0], lessThan(0.0));
        expect(res.features[63], greaterThan(0.0));
      },
    );
  });

  group('ClassifierService & TemporalSmoother', () {
    test(
      'forwardPass MLP menghasilkan distribusi probabilitas yang konsisten',
      () {
        final classifier = ClassifierService();
        final inputZeros = List<double>.filled(128, 0.0);
        inputZeros[0] = 1.0;

        final rowA = List<double>.filled(128, 0.0)..[0] = 3.0;
        final rowB = List<double>.filled(128, 0.0)..[0] = 1.0;
        final rowC = List<double>.filled(128, 0.0)..[0] = -1.0;

        classifier.loadFromJsonMap(<String, dynamic>{
          'metadata': <String, dynamic>{
            'version': '1.0.0-test',
            'labels': <String>['A', 'B', 'C'],
            'input_dimension': 128,
            'confidence_threshold': 0.60,
            'normalize_features': false,
            'is_placeholder': false,
          },
          'layers': <Map<String, dynamic>>[
            <String, dynamic>{
              'weights': <List<double>>[rowA, rowB, rowC],
              'biases': <double>[0.0, 0.0, 0.0],
              'activation': 'softmax',
            },
          ],
        });

        final probs = classifier.forwardPass(inputZeros);
        expect(probs.length, 3);
        expect(probs[0], greaterThan(probs[1]));
        expect(probs[1], greaterThan(probs[2]));
        final sum = probs.fold<double>(0.0, (a, b) => a + b);
        expect(sum, closeTo(1.0, 1e-6));
      },
    );

    test(
      'TemporalSmoother menetapkan isStable setelah majority vote dan mencegah XP berulang',
      () {
        final smoother = TemporalSmoother(
          windowSize: 4,
          minMajorityCount: 3,
          confidenceThreshold: 0.65,
        );

        GesturePrediction makePred(String letter, int offsetSec) =>
            GesturePrediction(
              letter: letter,
              score: 0.85,
              isStable: false,
              timestamp: sampleTime.add(Duration(seconds: offsetSec)),
              inferenceMs: 10,
            );

        expect(smoother.add(makePred('A', 1)).isStable, isFalse);
        expect(smoother.add(makePred('A', 2)).isStable, isFalse);
        final third = smoother.add(makePred('A', 3));
        expect(third.isStable, isTrue);
        expect(third.letter, 'A');

        // Hanya attempt pertama pada gestur stabil yang sama yang berhak mendapat XP
        expect(smoother.consumeAttemptEligibility(third), isTrue);
        expect(smoother.consumeAttemptEligibility(third), isFalse);
        smoother.resetDebounce();
        expect(smoother.consumeAttemptEligibility(third), isTrue);
      },
    );
  });

  group('UserProgressModel, SupabaseService fallback, & SyncService', () {
    test('levelForXp sesuai rumus 1 + (xp ~/ 100)', () {
      expect(UserProgressModel.levelForXp(0), 1);
      expect(UserProgressModel.levelForXp(99), 1);
      expect(UserProgressModel.levelForXp(100), 2);
      expect(UserProgressModel.levelForXp(250), 3);
    });

    test(
      'pencatatan attempt lokal memperbarui XP, mastery huruf, dan antrean SyncService',
      () async {
        final supabase = SupabaseService(supabaseUrl: '', publishableKey: '');
        supabase.signInDemo(displayName: 'Tester');
        final sync = SyncService(supabaseService: supabase);

        final attempt = PracticeAttemptModel(
          id: 'attempt-1',
          userId: 'demo-user',
          targetLetter: 'A',
          predictedLetter: 'A',
          confidence: 0.90,
          isCorrect: true,
          inferenceMs: 14,
          platform: 'web',
          createdAt: sampleTime,
        );

        sync.enqueueAttempt(attempt);
        expect(sync.pendingCount, 1);

        final flushed = await sync.flushPendingAttempts();
        expect(flushed, 1);
        expect(sync.pendingCount, 0);

        final progress = await supabase.fetchUserProgress();
        expect(progress.xp, greaterThanOrEqualTo(15));
      },
    );
  });
}
