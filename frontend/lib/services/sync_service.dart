import '../models/attempt_model.dart';
import 'supabase_service.dart';

/// Service antrean sinkronisasi metadata latihan ketika pengguna berlatih
/// dalam kondisi jaringan terputus (offline-first).
///
/// Sesuai `AGENTS.md` §5.1:
/// - Hanya menyimpan metadata attempt (tanpa foto/frame kamera).
/// - Melakukan flush berurutan tanpa duplikasi saat koneksi tersedia kembali.
class SyncService {
  SyncService({required SupabaseService supabaseService})
    : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;
  final List<PracticeAttemptModel> _pendingQueue = <PracticeAttemptModel>[];
  bool _isSyncing = false;

  List<PracticeAttemptModel> get pendingAttempts =>
      List<PracticeAttemptModel>.unmodifiable(_pendingQueue);

  int get pendingCount => _pendingQueue.length;
  bool get isSyncing => _isSyncing;

  void enqueueAttempt(PracticeAttemptModel attempt) {
    _pendingQueue.add(attempt);
  }

  /// Mencoba mengirim seluruh antrean attempt yang tertunda ke Supabase.
  Future<int> flushPendingAttempts() async {
    if (_isSyncing || _pendingQueue.isEmpty) {
      return 0;
    }
    _isSyncing = true;
    var syncedCount = 0;

    try {
      final copy = List<PracticeAttemptModel>.from(_pendingQueue);
      for (final attempt in copy) {
        await _supabaseService.recordPracticeAttempt(attempt);
        _pendingQueue.remove(attempt);
        syncedCount++;
      }
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }
}
