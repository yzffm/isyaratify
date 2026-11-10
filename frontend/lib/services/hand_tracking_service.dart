import 'package:flutter/widgets.dart';

import '../models/hand_landmark_model.dart';

/// Kontrak hand tracking lintas platform (ADR 0002).
///
/// Web dan Android mengimplementasikan kontrak ini (lihat `lib/platform/`)
/// dan menghasilkan [HandLandmarkFrame] dengan format kanonik yang sama.
abstract interface class HandTrackingService {
  /// Menyiapkan kamera dan tracker. Melempar `HandTrackingException` bila gagal.
  Future<void> initialize();

  /// Aliran hasil landmark. Implementasi memprioritaskan frame terbaru
  /// dan membuang frame lama bila pemrosesan belum selesai (backpressure).
  Stream<HandLandmarkFrame> start();

  /// Menghentikan stream dan melepas kamera sementara.
  Future<void> stop();

  /// Melepas semua resource. Aman dipanggil lebih dari sekali.
  Future<void> dispose();

  /// Membangun widget preview kamera platform.
  Widget buildPreview(BuildContext context);
}
