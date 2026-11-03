import '../../core/errors/app_exceptions.dart';
import '../../models/hand_landmark_model.dart';
import '../../services/hand_tracking_service.dart';

/// Stub Web. Implementasi (getUserMedia + MediaPipe Tasks Vision JS melalui JS
/// interop, `web/hand_tracking_web.js`) dikerjakan pada spike berikutnya.
class WebHandTrackingService implements HandTrackingService {
  @override
  Future<void> initialize() async =>
      throw const HandTrackingException.notImplemented('Web');

  @override
  Stream<HandLandmarkFrame> start() => Stream<HandLandmarkFrame>.error(
    const HandTrackingException.notImplemented('Web'),
  );

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

HandTrackingService createPlatformHandTrackingService() =>
    WebHandTrackingService();
