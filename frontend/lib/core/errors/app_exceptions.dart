/// Data landmark tidak memenuhi kontrak (jumlah tangan/landmark, handedness, nilai).
class LandmarkContractException implements Exception {
  const LandmarkContractException(this.message);

  final String message;

  @override
  String toString() => 'LandmarkContractException: $message';
}

/// Hand tracking tidak dapat dijalankan (belum diimplementasikan, ditolak, dsb.).
class HandTrackingException implements Exception {
  const HandTrackingException(this.message);

  /// Implementasi platform belum tersedia (sebelum spike MediaPipe).
  const HandTrackingException.notImplemented(String platform)
    : message = 'Hand tracking untuk $platform belum diimplementasikan.';

  final String message;

  @override
  String toString() => 'HandTrackingException: $message';
}
