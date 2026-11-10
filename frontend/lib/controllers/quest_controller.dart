import 'package:flutter/foundation.dart';

import '../models/quest_model.dart';
import '../services/supabase_service.dart';

/// Controller untuk daftar misi (Quest) harian dan pencapaian.
class QuestController extends ChangeNotifier {
  QuestController({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService();

  final SupabaseService _supabaseService;

  List<QuestModel> _quests = kDefaultQuests;
  bool _isLoading = false;

  List<QuestModel> get quests => _quests;
  bool get isLoading => _isLoading;

  int get completedCount => _quests.where((q) => q.isCompleted).length;
  int get totalAvailableXp =>
      _quests.fold<int>(0, (sum, q) => sum + q.xpReward);

  Future<void> loadQuests() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _quests = await _supabaseService.fetchQuestsWithCompletion();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
