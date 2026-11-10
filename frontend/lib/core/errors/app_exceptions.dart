/// Data landmark tidak memenuhi kontrak (jumlah tangan/landmark, handedness, nilai).
class LandmarkContractException implements Exception {
  const LandmarkContractException(this.message);

  final String message;

  @override
  String toString() => 'LandmarkContractException: $message';
}

/// Klasifikasi terstruktur untuk kegagalan kamera dan hand tracking (ADR 0002).
enum HandTrackingErrorCode {
  permissionDenied,
  cameraUnavailable,
  insecureContext,
  modelLoadFailed,
  notImplemented,
  unknown,
}

/// Hand tracking tidak dapat dijalankan (belum diimplementasikan, izin ditolak, dsb.).
class HandTrackingException implements Exception {
  const HandTrackingException(
    this.message, {
    this.code = HandTrackingErrorCode.unknown,
  });

  /// Implementasi platform belum tersedia.
  const HandTrackingException.notImplemented(String platform)
    : message = 'Hand tracking untuk $platform belum diimplementasikan.',
      code = HandTrackingErrorCode.notImplemented;

  final String message;
  final HandTrackingErrorCode code;

  /// Instruksi pemulihan yang ramah pengguna berdasarkan [code].
  String get recoveryHint => switch (code) {
    HandTrackingErrorCode.permissionDenied =>
      'Izinkan akses kamera pada pengaturan browser atau perangkat Anda, lalu tekan Coba Lagi.',
    HandTrackingErrorCode.cameraUnavailable =>
      'Pastikan perangkat memiliki kamera yang aktif dan tidak sedang dipakai aplikasi lain.',
    HandTrackingErrorCode.insecureContext =>
      'Akses kamera Web memerlukan koneksi aman (HTTPS atau localhost).',
    HandTrackingErrorCode.modelLoadFailed =>
      'Gagal memuat model pelacak tangan MediaPipe. Periksa koneksi internet pada pemuatan awal atau muat ulang halaman.',
    HandTrackingErrorCode.notImplemented =>
      'Pastikan modul kamera platform telah diaktifkan pada perangkat uji.',
    HandTrackingErrorCode.unknown =>
      'Periksa izin kamera dan pencahayaan ruangan Anda, lalu coba lagi.',
  };

  @override
  String toString() => 'HandTrackingException(${code.name}): $message';
}

/// Kegagalan komunikasi dengan Supabase Auth / REST API / RPC.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
