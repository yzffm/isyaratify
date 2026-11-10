import 'package:flutter/foundation.dart';

import '../models/letter_model.dart';
import '../models/progress_model.dart';
import '../services/supabase_service.dart';

/// Controller untuk Kamus Alfabet BISINDO A–Z dan modul panduan belajar.
class DictionaryController extends ChangeNotifier {
  DictionaryController({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService();

  final SupabaseService _supabaseService;

  List<LetterModel> _letters = kDefaultBisindoLetters;
  List<LearningGuideModel> _guides = kDefaultLearningGuides;
  Map<String, LetterMasteryModel> _masteryByLetter =
      const <String, LetterMasteryModel>{};

  bool _isLoading = false;
  String _searchQuery = '';
  int? _handsFilter; // null = semua, 1 = 1 tangan, 2 = 2 tangan

  List<LetterModel> get allLetters => _letters;
  List<LearningGuideModel> get guides => _guides;
  Map<String, LetterMasteryModel> get masteryByLetter => _masteryByLetter;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int? get handsFilter => _handsFilter;

  List<LetterModel> get filteredLetters {
    return _letters
        .where((item) {
          if (_handsFilter != null && item.handCount != _handsFilter) {
            return false;
          }
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            final matchLetter = item.letter.toLowerCase().contains(q);
            final matchDesc = item.description.toLowerCase().contains(q);
            final matchGuides = item.stepByStepGuides.any(
              (step) => step.toLowerCase().contains(q),
            );
            return matchLetter || matchDesc || matchGuides;
          }
          return true;
        })
        .toList(growable: false);
  }

  LetterMasteryModel? masteryFor(String letter) {
    return _masteryByLetter[letter.toUpperCase()];
  }

  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    notifyListeners();
  }

  void setHandsFilter(int? hands) {
    if (_handsFilter == hands) return;
    _handsFilter = hands;
    notifyListeners();
  }

  Future<void> loadDictionary() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _supabaseService.fetchLetters(),
        _supabaseService.fetchLearningGuides(),
        _supabaseService.fetchLetterMastery(),
      ]);

      _letters = results[0] as List<LetterModel>;
      _guides = results[1] as List<LearningGuideModel>;
      _masteryByLetter = results[2] as Map<String, LetterMasteryModel>;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
