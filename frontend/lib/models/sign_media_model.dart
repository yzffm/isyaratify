/// Media peragaan isyarat satu huruf BISINDO yang diambil dari API publik
/// Wikimedia Commons (bukan dari Supabase).
///
/// Lisensi konten: umumnya CC BY-SA 4.0 sehingga atribusi (`artist`,
/// `license`, `descriptionUrl`) wajib ditampilkan di UI.
class SignMediaModel {
  const SignMediaModel({
    required this.letter,
    required this.mediaUrl,
    required this.mimeType,
    required this.sizeBytes,
    required this.license,
    required this.artist,
    required this.descriptionUrl,
  });

  final String letter;
  final String mediaUrl;
  final String mimeType;
  final int sizeBytes;
  final String license;
  final String artist;
  final String descriptionUrl;

  bool get isVideo => mimeType.startsWith('video/');

  String get attributionText => '$artist · $license · Wikimedia Commons';
}

/// Status pemuatan media isyarat dari API publik.
enum SignMediaStatus { idle, loading, ready, partial, failed }

/// Asal data teks kamus (untuk transparansi sumber data di UI).
enum DataSource { unknown, remoteApi, localFallback }
