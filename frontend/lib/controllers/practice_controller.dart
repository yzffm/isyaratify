import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';
import '../services/hand_tracking_service.dart';

enum PracticeStatus { idle, initializing, ready, unavailable }

/// Mengoordinasikan [HandTrackingService]. Hanya state kontrak; classifier,
/// smoothing, dan target practice ditambahkan pada task berikutnya.
class PracticeController extends ChangeNotifier {
  PracticeController(this._tracking);

  static const String genericErrorMessage =
      'Gagal menyiapkan pelacakan tangan. Silakan coba lagi.';

  final HandTrackingService _tracking;

  PracticeStatus _status = PracticeStatus.idle;
  String? _message;
  bool _disposed = false;

  PracticeStatus get status => _status;

  /// Pesan yang dapat ditampilkan ke pengguna bila [status] bukan `ready`.
  String? get message => _message;

  Future<void> initialize() async {
    if (_disposed ||
        _status == PracticeStatus.initializing ||
        _status == PracticeStatus.ready) {
      return;
    }
    _set(PracticeStatus.initializing);
    try {
      await _tracking.initialize();
      if (_disposed) {
        await _stopAndDispose();
        return;
      }
      _set(PracticeStatus.ready);
    } on HandTrackingException catch (e) {
      _set(PracticeStatus.unavailable, e.message);
    } catch (e, st) {
      debugPrint('PracticeController.initialize unexpected error: $e\n$st');
      _set(PracticeStatus.unavailable, genericErrorMessage);
    }
  }

  void _set(PracticeStatus status, [String? message]) {
    if (_disposed) return;
    _status = status;
    _message = message;
    notifyListeners();
  }

  Future<void> _stopAndDispose() async {
    try {
      await _tracking.stop();
    } catch (e, st) {
      debugPrint('PracticeController.stop unexpected error: $e\n$st');
    }
    try {
      await _tracking.dispose();
    } catch (e, st) {
      debugPrint('PracticeController.dispose unexpected error: $e\n$st');
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    // Pastikan kamera/tracker dilepas saat layar practice ditutup.
    unawaited(_stopAndDispose());
    super.dispose();
  }
}
