import 'package:flutter/foundation.dart';

import '../core/errors/app_exceptions.dart';
import '../services/hand_tracking_service.dart';

enum PracticeStatus { idle, initializing, ready, unavailable }

/// Mengoordinasikan [HandTrackingService]. Hanya state kontrak; classifier,
/// smoothing, dan target practice ditambahkan pada task berikutnya.
class PracticeController extends ChangeNotifier {
  PracticeController(this._tracking);

  final HandTrackingService _tracking;

  PracticeStatus _status = PracticeStatus.idle;
  String? _message;
  bool _disposed = false;

  PracticeStatus get status => _status;

  /// Pesan yang dapat ditampilkan ke pengguna bila [status] bukan `ready`.
  String? get message => _message;

  Future<void> initialize() async {
    if (_status == PracticeStatus.initializing) return;
    _set(PracticeStatus.initializing);
    try {
      await _tracking.initialize();
      _set(PracticeStatus.ready);
    } on HandTrackingException catch (e) {
      _set(PracticeStatus.unavailable, e.message);
    }
  }

  void _set(PracticeStatus status, [String? message]) {
    if (_disposed) return;
    _status = status;
    _message = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    // Pastikan kamera/tracker dilepas saat layar practice ditutup.
    _tracking.stop().then((_) => _tracking.dispose());
    super.dispose();
  }
}
