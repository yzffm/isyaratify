import 'package:flutter/foundation.dart';

import '../models/letter_model.dart';
import '../models/progress_model.dart';
import '../models/sign_media_model.dart';
import '../services/commons_sign_service.dart';
import '../services/supabase_service.dart';

/// Controller untuk Kamus Alfabet BISINDO A–Z dan modul panduan belajar.
///
/// Sumber data:
/// - Teks kamus, panduan, mastery → Supabase REST API (fallback lokal bila gagal).
/// - Video peragaan isyarat → API publik Wikimedia Commons (via Dio).
class DictionaryController extends ChangeNotifier {
  DictionaryController({
    SupabaseService? supabaseService,
    CommonsSignService? commonsSignService,
  }) : _supabaseService = supabaseService ?? SupabaseService(),
       _commonsSignService = commonsSignService ?? CommonsSignService();

  final SupabaseService _supabaseService;
  final CommonsSignService _commonsSignService;

  List<LetterModel> _letters = kDefaultBisindoLetters;
  List<LearningGuideModel> _guides = kDefaultLearningGuides;
  Map<String, LetterMasteryModel> _masteryByLetter =
      const <String, LetterMasteryModel>{};
  Map<String, SignMediaModel> _signMedia = const <String, SignMediaModel>{};

  bool _isLoading = false;
  String _searchQuery = '';
  int? _handsFilter; // null = semua, 1 = 1 tangan, 2 = 2 tangan

  SignMediaStatus _signStatus = SignMediaStatus.idle;
  String? _signError;
  DataSource _lettersSource = DataSource.unknown;
  String? _lettersFallbackReason;

  List<LetterModel> get allLetters => _letters;
  List<LearningGuideModel> get guides => _guides;
  Map<String, LetterMasteryModel> get masteryByLetter => _masteryByLetter;
  Map<String, SignMediaModel> get signMedia => _signMedia;
  SignMediaStatus get signStatus => _signStatus;
  String? get signError => _signError;
  DataSource get lettersSource => _lettersSource;
  String? get lettersFallbackReason => _lettersFallbackReason;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int? get handsFilter => _handsFilter;

  SignMediaModel? signMediaFor(String letter) =>
      _signMedia[letter.toUpperCase()];

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
    _signStatus = SignMediaStatus.loading;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _supabaseService.fetchLetters(),
        _supabaseService.fetchLearningGuides(),
        _supabaseService.fetchLetterMastery(),
        _loadSignMedia(),
      ]);

      _letters = results[0] as List<LetterModel>;
      _guides = results[1] as List<LearningGuideModel>;
      _masteryByLetter = results[2] as Map<String, LetterMasteryModel>;
      _lettersSource = _supabaseService.lastLettersSource;
      _lettersFallbackReason = _supabaseService.lastLettersFallbackReason;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Muat video isyarat dari API publik; kegagalan TIDAK menjatuhkan kamus,
  /// tetapi dicatat eksplisit pada [signStatus] / [signError] (tidak senyap).
  Future<void> _loadSignMedia() async {
    try {
      final media = await _commonsSignService.fetchAlphabetSigns();
      _signMedia = media;
      _signError = null;
      _signStatus = media.length >= 26
          ? SignMediaStatus.ready
          : SignMediaStatus.partial;
    } catch (e) {
      _signError = e.toString();
      _signStatus = SignMediaStatus.failed;
    }
  }

  /// Coba lagi memuat video isyarat (mis. setelah koneksi pulih).
  Future<void> retrySignMedia() async {
    _signStatus = SignMediaStatus.loading;
    notifyListeners();
    try {
      final media = await _commonsSignService.fetchAlphabetSigns(
        forceRefresh: true,
      );
      _signMedia = media;
      _signError = null;
      _signStatus = media.length >= 26
          ? SignMediaStatus.ready
          : SignMediaStatus.partial;
    } catch (e) {
      _signError = e.toString();
      _signStatus = SignMediaStatus.failed;
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _commonsSignService.close();
    super.dispose();
  }
}
