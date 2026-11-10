import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';
import '../services/supabase_service.dart';

/// Controller autentikasi yang terhubung ke [SupabaseService].
///
/// Sesuai keputusan DG-04:
/// - Seluruh fitur aplikasi mewajibkan pengguna login terlebih dahulu.
/// - Menyediakan `signInWithPassword`, `signUp`, `signOut`, serta
///   `signInPlaceholder` untuk mode demo lokal / widget testing.
class AuthController extends ChangeNotifier {
  AuthController({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService();

  final SupabaseService _supabaseService;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthSession? get currentSession => _supabaseService.currentSession;
  String get displayName =>
      _supabaseService.currentSession?.displayName ?? 'Pembelajar BISINDO';
  String get userEmail => _supabaseService.currentSession?.email ?? '';

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.signInWithPassword(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Gagal terhubung ke layanan autentikasi. Coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Gagal mendaftarkan akun baru. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Masuk cepat dengan sesi demo lokal (untuk pengembangan & widget test).
  void signInPlaceholder() {
    if (_isAuthenticated) return;
    _supabaseService.signInDemo();
    _isAuthenticated = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
    await _supabaseService.signOut();
  }
}
