import '../models/hand_landmark_model.dart';

/// Kontrak hand tracking lintas platform. Web dan Android mengimplementasikan
/// kontrak ini (lihat `lib/platform/`) dan harus menghasilkan
/// [HandLandmarkFrame] yang sama. Signature dapat disesuaikan setelah spike.
abstract interface class HandTrackingService {
  /// Menyiapkan kamera dan tracker. Melempar `HandTrackingException` bila gagal.
  Future<void> initialize();

  /// Aliran hasil landmark. Implementasi harus memprioritaskan frame terbaru
  /// dan membuang frame lama bila pemrosesan belum selesai.
  Stream<HandLandmarkFrame> start();

  /// Menghentikan stream dan melepas kamera.
  Future<void> stop();

  /// Melepas semua resource. Aman dipanggil lebih dari sekali.
  Future<void> dispose();
}
