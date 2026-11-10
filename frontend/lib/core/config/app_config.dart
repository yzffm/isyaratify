/// Konfigurasi environment aplikasi yang dibaca pada waktu kompilasi melalui
/// `--dart-define` atau `--dart-define-from-file=../.env` (H10).
///
/// Tidak ada kredensial atau secret yang ditulis langsung di dalam kode sumber.
abstract final class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Bernilai `true` apabila URL dan publishable key Supabase telah diberikan.
  static bool get isSupabaseConfigured =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;
}
