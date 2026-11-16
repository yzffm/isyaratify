import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isyaratify/core/errors/app_exceptions.dart';
import 'package:isyaratify/models/attempt_model.dart';
import 'package:isyaratify/models/hand_landmark_model.dart';
import 'package:isyaratify/models/prediction_model.dart';
import 'package:isyaratify/models/progress_model.dart';
import 'package:isyaratify/platform/http_client_platform.dart';
import 'package:isyaratify/services/classifier_service.dart';
import 'package:isyaratify/services/feature_service.dart';
import 'package:isyaratify/services/supabase_service.dart';
import 'package:isyaratify/services/sync_service.dart';

class _FakeDioAdapter implements HttpClientAdapter {
  _FakeDioAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  bool closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {
    closed = true;
  }
}

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

    test(
      'extractMlpFeatures126 menormalisasi wrist per tangan dan menolkan slot tangan ke-2 saat 1 tangan',
      () {
        final singleHand = TrackedHand(
          side: HandSide.right,
          landmarks: _buildLandmarks(offsetX: 0.4),
          handednessScore: 0.91,
        );
        final frame = HandLandmarkFrame.fromHands(
          timestamp: sampleTime,
          hands: <TrackedHand>[singleHand],
        );

        final res = featureService.extractMlpFeatures126(frame);
        expect(res.isValid, isTrue);
        expect(res.handCount, 1);
        expect(res.features.length, 126);
        // Wrist tangan ke-1 berada pada pusat (0, 0, 0)
        expect(res.features[0], closeTo(0.0, 1e-9));
        expect(res.features[1], closeTo(0.0, 1e-9));
        expect(res.features[2], closeTo(0.0, 1e-9));
        // Slot tangan ke-2 (indeks 63..125) bernilai 0.0
        expect(res.features.sublist(63).every((v) => v == 0.0), isTrue);
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
      'parity Python-Dart pada artefak assets/ml/classifier.json menghasilkan label dan skor identik',
      () {
        final file = File('assets/ml/classifier.json');
        expect(file.existsSync(), isTrue);

        final rawJson =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final classifier = ClassifierService()..loadFromJsonMap(rawJson);

        expect(classifier.hasTrainedWeights, isTrue);
        expect(classifier.metadata.inputDimension, 126);
        expect(classifier.metadata.labels.length, 26);

        final paritySample = rawJson['parity_sample'] as Map<String, dynamic>;
        final sampleInput = (paritySample['input'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(growable: false);
        final expectedLabel = paritySample['expected_top_label'] as String;
        final expectedScore = (paritySample['expected_top_score'] as num)
            .toDouble();

        final probs = classifier.forwardPass(sampleInput);
        expect(probs.length, 26);

        var bestIdx = 0;
        for (var i = 1; i < probs.length; i++) {
          if (probs[i] > probs[bestIdx]) bestIdx = i;
        }
        expect(classifier.metadata.labels[bestIdx], expectedLabel);
        expect(probs[bestIdx], closeTo(expectedScore, 1e-5));
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

  group('DioPlatformHttpClient', () {
    test(
      'menyisipkan header JSON standar dan meneruskan respons HTTP dengan benar',
      () async {
        RequestOptions? capturedOptions;
        final dio = Dio();
        final adapter = _FakeDioAdapter((options) async {
          capturedOptions = options;
          return ResponseBody.fromString(
            '{"ok":true}',
            200,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        });
        dio.httpClientAdapter = adapter;

        final client = DioPlatformHttpClient(dio: dio);
        final res = await client.request(
          method: 'POST',
          uri: Uri.parse('https://example.supabase.co/rest/v1/rpc/test'),
          headers: const <String, String>{'apikey': 'sb_publishable_demo'},
          body: '{"hello":"world"}',
        );

        expect(res.isSuccess, isTrue);
        expect(res.statusCode, 200);
        expect(res.body, '{"ok":true}');
        expect(capturedOptions?.headers['apikey'], 'sb_publishable_demo');
        expect(capturedOptions?.headers['Accept'], 'application/json');

        client.close();
        expect(adapter.closed, isTrue);
      },
    );

    test(
      'memetakan DioException timeout menjadi ApiException yang ramah pengguna',
      () async {
        final dio = Dio();
        dio.httpClientAdapter = _FakeDioAdapter((options) async {
          throw DioException.connectionTimeout(
            timeout: const Duration(seconds: 12),
            requestOptions: options,
          );
        });

        final client = DioPlatformHttpClient(dio: dio);
        await expectLater(
          client.request(
            method: 'GET',
            uri: Uri.parse('https://example.supabase.co/rest/v1/letters'),
            headers: const <String, String>{},
          ),
          throwsA(isA<ApiException>()),
        );
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
