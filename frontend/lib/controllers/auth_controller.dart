import 'package:flutter/foundation.dart';

/// Placeholder state autentikasi.
///
/// Belum terhubung ke Supabase Auth. Integrasi sungguhan dikerjakan pada task
/// terpisah; saat itu hanya isi controller ini (dan service) yang berubah.
class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  /// Masuk sementara tanpa kredensial (hanya untuk navigasi placeholder).
  void signInPlaceholder() {
    if (_isAuthenticated) return;
    _isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    notifyListeners();
  }
}
