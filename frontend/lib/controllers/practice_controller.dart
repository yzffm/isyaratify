import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/errors/app_exceptions.dart';
import '../models/attempt_model.dart';
import '../models/hand_landmark_model.dart';
import '../models/prediction_model.dart';
import '../services/classifier_service.dart';
import '../services/hand_tracking_service.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';

enum PracticeStatus { idle, initializing, ready, unavailable }

/// Mengoordinasikan [HandTrackingService], [ClassifierService],
/// [TemporalSmoother], dan pencatatan hasil latihan ke [SupabaseService].
class PracticeController extends ChangeNotifier {
  PracticeController(
    this._tracking, {
    ClassifierService? classifierService,
    SupabaseService? supabaseService,
    SyncService? syncService,
    String? initialTargetLetter,
  }) : _classifier = classifierService ?? ClassifierService(),
       _supabaseService = supabaseService,
       _syncService = syncService,
       _targetLetter = initialTargetLetter?.trim().toUpperCase();

  static const String genericErrorMessage =
      'Gagal menyiapkan pelacakan tangan. Silakan coba lagi.';

  final HandTrackingService _tracking;
  final ClassifierService _classifier;
  final SupabaseService? _supabaseService;
  final SyncService? _syncService;
  final TemporalSmoother _smoother = TemporalSmoother(
    windowSize: 5,
    minMajorityCount: 3,
    confidenceThreshold: 0.60,
  );

  PracticeStatus _status = PracticeStatus.idle;
  String? _message;
  String? _recoveryHint;
  bool _disposed = false;
  bool _pausedByLifecycle = false;

  StreamSubscription<HandLandmarkFrame>? _frameSubscription;
  HandLandmarkFrame? _latestFrame;
  GesturePrediction? _latestPrediction;
  AttemptSubmissionResult? _lastSubmissionResult;
  String? _targetLetter;
  int _sessionAttempts = 0;
  int _sessionCorrect = 0;
  int _sessionXpEarned = 0;

  PracticeStatus get status => _status;

  /// Pesan yang dapat ditampilkan ke pengguna bila [status] bukan `ready`.
  String? get message => _message;
  String? get recoveryHint => _recoveryHint;

  HandLandmarkFrame? get latestFrame => _latestFrame;
  GesturePrediction? get latestPrediction => _latestPrediction;
  AttemptSubmissionResult? get lastSubmissionResult => _lastSubmissionResult;
  String? get targetLetter => _targetLetter;
  bool get isTargetPractice =>
      _targetLetter != null && _targetLetter!.isNotEmpty;
  int get detectedHandCount => _latestFrame?.handCount ?? 0;
  bool get hasAnyHand => _latestFrame?.hasAnyHand ?? false;
  int get sessionAttempts => _sessionAttempts;
  int get sessionCorrect => _sessionCorrect;
  int get sessionXpEarned => _sessionXpEarned;

  Widget buildCameraPreview(BuildContext context) {
    return _tracking.buildPreview(context);
  }

  void setTargetLetter(String? letter) {
    if (_disposed) return;
    final normalized = (letter == null || letter.trim().isEmpty)
        ? null
        : letter.trim().toUpperCase();
    if (_targetLetter == normalized) return;
    _targetLetter = normalized;
    _smoother.clear();
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_disposed ||
        _status == PracticeStatus.initializing ||
        _status == PracticeStatus.ready) {
      return;
    }
    _recoveryHint = null;
    _set(PracticeStatus.initializing);
    try {
      await _tracking.initialize();
      if (_disposed) {
        await _stopAndDispose();
        return;
      }
      if (!_classifier.isInitialized) {
        unawaited(_classifier.initialize());
      }
      _subscribeToFrames();
      _set(PracticeStatus.ready);
    } on HandTrackingException catch (e) {
      _recoveryHint = e.recoveryHint;
      _set(PracticeStatus.unavailable, e.message);
    } catch (e, st) {
      debugPrint('PracticeController.initialize unexpected error: $e\n$st');
      _set(PracticeStatus.unavailable, genericErrorMessage);
    }
  }

  void _subscribeToFrames() {
    _frameSubscription?.cancel();
    _frameSubscription = _tracking.start().listen(
      _onLandmarkFrame,
      onError: (Object error) {
        if (_disposed) return;
        if (error is HandTrackingException) {
          _recoveryHint = error.recoveryHint;
          _set(PracticeStatus.unavailable, error.message);
        } else {
          _set(PracticeStatus.unavailable, genericErrorMessage);
        }
      },
    );
  }

  void _onLandmarkFrame(HandLandmarkFrame frame) {
    if (_disposed || _status != PracticeStatus.ready) return;

    _latestFrame = frame;
    final rawPrediction = _classifier.predictFrame(
      frame,
      preferredTargetLetter: _targetLetter,
    );
    if (rawPrediction == null) {
      _smoother.clear();
      _latestPrediction = null;
      notifyListeners();
      return;
    }

    final smoothed = _smoother.add(rawPrediction);
    _latestPrediction = smoothed;

    if (_smoother.consumeAttemptEligibility(smoothed)) {
      unawaited(_recordStablePrediction(smoothed));
    }

    notifyListeners();
  }

  Future<AttemptSubmissionResult?> submitManualCheck({
    required String predictedLetter,
    double confidence = 0.85,
    int inferenceTimeMs = 12,
  }) async {
    final prediction = GesturePrediction(
      letter: predictedLetter.toUpperCase(),
      score: confidence,
      isStable: true,
      timestamp: DateTime.now(),
      inferenceMs: inferenceTimeMs,
    );
    _latestPrediction = prediction;
    notifyListeners();
    return _recordStablePrediction(prediction);
  }

  Future<AttemptSubmissionResult?> _recordStablePrediction(
    GesturePrediction prediction,
  ) async {
    if (_disposed) return null;

    final target = _targetLetter;
    final isCorrect = target == null || target.isEmpty
        ? true
        : prediction.letter.toUpperCase() == target.toUpperCase();

    final supabase = _supabaseService;
    final userId = supabase?.currentSession?.userId ?? 'demo-user';

    final attempt = PracticeAttemptModel(
      id: 'attempt-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      targetLetter: target,
      predictedLetter: prediction.letter.toUpperCase(),
      confidence: prediction.score,
      isCorrect: isCorrect,
      inferenceMs: prediction.inferenceMs,
      platform: kIsWeb ? 'web' : 'android',
      createdAt: DateTime.now(),
    );

    _sessionAttempts++;
    if (isCorrect) {
      _sessionCorrect++;
    }

    if (supabase == null) {
      final fallbackXp = isCorrect ? (target != null ? 15 : 10) : 2;
      _sessionXpEarned += fallbackXp;
      notifyListeners();
      return null;
    }

    try {
      final result = await supabase.recordPracticeAttempt(attempt);
      if (_disposed) return result;
      _lastSubmissionResult = result;
      _sessionXpEarned += result.totalXpGained;
      notifyListeners();
      return result;
    } catch (_) {
      _syncService?.enqueueAttempt(attempt);
      notifyListeners();
      return null;
    }
  }

  Future<void> pauseForBackground() async {
    if (_disposed || _status != PracticeStatus.ready) return;
    _pausedByLifecycle = true;
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    try {
      await _tracking.stop();
    } catch (_) {}
    _set(PracticeStatus.idle, 'Kamera dijeda saat aplikasi di latar belakang.');
  }

  Future<void> resumeFromBackground() async {
    if (_disposed || !_pausedByLifecycle) return;
    _pausedByLifecycle = false;
    await initialize();
  }

  Future<void> stopSession() async {
    if (_disposed) return;
    _pausedByLifecycle = false;
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    try {
      await _tracking.stop();
    } catch (_) {}
    _smoother.clear();
    _latestFrame = null;
    _latestPrediction = null;
    _set(
      PracticeStatus.idle,
      'Kamera dihentikan. Tekan Mulai untuk berlatih kembali.',
    );
  }

  void _set(PracticeStatus status, [String? message]) {
    if (_disposed) return;
    _status = status;
    _message = message;
    notifyListeners();
  }

  Future<void> _stopAndDispose() async {
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    try {
      await _tracking.stop();
    } catch (e, st) {
      debugPrint('PracticeController.stop unexpected error: $e\n$st');
    }
    try {
      await _tracking.dispose();
    } catch (e, st) {
      debugPrint('PracticeController.dispose unexpected error: $e\n$st');
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    // Pastikan kamera/tracker dilepas saat layar practice ditutup.
    unawaited(_stopAndDispose());
    super.dispose();
  }
}
