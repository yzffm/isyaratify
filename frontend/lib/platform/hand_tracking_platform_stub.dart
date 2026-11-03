import '../core/errors/app_exceptions.dart';
import '../models/hand_landmark_model.dart';
import '../services/hand_tracking_service.dart';

/// Fallback untuk platform tanpa implementasi.
class UnsupportedHandTrackingService implements HandTrackingService {
  @override
  Future<void> initialize() async =>
      throw const HandTrackingException.notImplemented('platform ini');

  @override
  Stream<HandLandmarkFrame> start() => Stream<HandLandmarkFrame>.error(
    const HandTrackingException.notImplemented('platform ini'),
  );

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

HandTrackingService createPlatformHandTrackingService() =>
    UnsupportedHandTrackingService();
