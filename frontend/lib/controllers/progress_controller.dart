import 'package:flutter/foundation.dart';

import '../models/attempt_model.dart';
import '../models/progress_model.dart';
import '../services/supabase_service.dart';

/// Controller untuk progres pengguna (XP, level, streak), penguasaan huruf,
/// lencana (badges), riwayat latihan, dan Leaderboard publik.
class ProgressController extends ChangeNotifier {
  ProgressController({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService();

  final SupabaseService _supabaseService;

  UserProgressModel _progress = UserProgressModel.empty('demo-user');
  Map<String, LetterMasteryModel> _mastery =
      const <String, LetterMasteryModel>{};
  List<BadgeModel> _badges = kDefaultBadges;
  List<LeaderboardEntryModel> _leaderboard = const <LeaderboardEntryModel>[];
  List<PracticeAttemptModel> _recentAttempts = const <PracticeAttemptModel>[];
  bool _isLoading = false;

  UserProgressModel get progress => _progress;
  Map<String, LetterMasteryModel> get mastery => _mastery;
  List<BadgeModel> get badges => _badges;
  List<LeaderboardEntryModel> get leaderboard => _leaderboard;
  List<PracticeAttemptModel> get recentAttempts => _recentAttempts;
  bool get isLoading => _isLoading;

  int get masteredLettersCount =>
      _mastery.values.where((item) => item.isMastered).length;

  int get earnedBadgesCount => _badges.where((item) => item.isEarned).length;

  Future<void> refreshAll() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _supabaseService.fetchUserProgress(),
        _supabaseService.fetchLetterMastery(),
        _supabaseService.fetchBadgesWithEarnedStatus(),
        _supabaseService.fetchLeaderboard(),
        _supabaseService.fetchRecentAttempts(),
      ]);

      _progress = results[0] as UserProgressModel;
      _mastery = results[1] as Map<String, LetterMasteryModel>;
      _badges = results[2] as List<BadgeModel>;
      _leaderboard = results[3] as List<LeaderboardEntryModel>;
      _recentAttempts = results[4] as List<PracticeAttemptModel>;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
