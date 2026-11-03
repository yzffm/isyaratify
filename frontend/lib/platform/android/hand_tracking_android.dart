import '../../core/errors/app_exceptions.dart';
import '../../models/hand_landmark_model.dart';
import '../../services/hand_tracking_service.dart';

/// Stub Android. Implementasi (camera stream + MediaPipe Tasks Vision Android
/// melalui plugin/platform channel) dikerjakan pada spike berikutnya.
class AndroidHandTrackingService implements HandTrackingService {
  @override
  Future<void> initialize() async =>
      throw const HandTrackingException.notImplemented('Android');

  @override
  Stream<HandLandmarkFrame> start() => Stream<HandLandmarkFrame>.error(
    const HandTrackingException.notImplemented('Android'),
  );

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

HandTrackingService createPlatformHandTrackingService() =>
    AndroidHandTrackingService();
