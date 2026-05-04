import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/meal_db_service.dart';

enum FetchStatus { initial, loading, success, error }

class ProductsViewModel extends ChangeNotifier {
  final MealDbService _api = MealDbService();

  // ── State ────────────────────────────────────────────────────────────────

  FetchStatus _status = FetchStatus.initial;
  String _errorMessage = '';
  List<Product> _apiDesserts = [];

  FetchStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == FetchStatus.loading;
  bool get hasError => _status == FetchStatus.error;

  // ── Category filter chip ─────────────────────────────────────────────────

  int _selectedChipIndex = 0;
  int get selectedChipIndex => _selectedChipIndex;

  void selectChip(int index) {
    _selectedChipIndex = index;
    notifyListeners();
  }

  void navigateToExplore({String? category}) {
    if (category != null) {
      final cat = category.toLowerCase();
      int chipIndex = 0;
      for (int i = 1; i < kFilterChips.length; i++) {
        if (kFilterChips[i].toLowerCase() == cat ||
            cat.contains(kFilterChips[i].toLowerCase()) ||
            kFilterChips[i].toLowerCase().contains(cat)) {
          chipIndex = i;
          break;
        }
      }
      _selectedChipIndex = chipIndex;
    } else {
      _selectedChipIndex = 0;
    }
    notifyListeners();
  }

  // ── Explore products (API + local) ───────────────────────────────────────

  List<Product> get allProducts {
    // Merge API desserts with the curated local list, deduplicating by ID.
    final seen = <String>{};
    final merged = [...kPopularDesserts, ...kExploreProducts, ..._apiDesserts];
    return merged.where((p) => seen.add(p.id)).toList();
  }

  List<Product> get filteredExploreProducts {
    final all = allProducts;
    if (_selectedChipIndex == 0) return all;
    final chipLabel = kFilterChips[_selectedChipIndex];
    return all
        .where((p) => p.category.toLowerCase() == chipLabel.toLowerCase())
        .toList();
  }

  // ── Mood filter ───────────────────────────────────────────────────────────

  int _selectedMoodIndex = -1;
  int get selectedMoodIndex => _selectedMoodIndex;

  void selectMood(int index) {
    _selectedMoodIndex = _selectedMoodIndex == index ? -1 : index;
    notifyListeners();
  }

  List<Product> get filteredPopularDesserts {
    final popular = [...kPopularDesserts, ..._apiDesserts.take(6)];
    if (_selectedMoodIndex < 0) return popular;
    final mood = kMoods[_selectedMoodIndex].label;
    final filtered = popular.where((p) => p.moods.contains(mood)).toList();
    return filtered.isEmpty ? popular : filtered;
  }

  // ── Search ───────────────────────────────────────────────────────────────

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Product> _searchResults = [];
  List<Product> get searchResults => _searchResults;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    notifyListeners();

    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    // Local results immediately.
    final q = query.toLowerCase();
    final all = allProducts;
    final seen = <String>{};
    _searchResults = all.where((p) {
      if (seen.contains(p.id)) return false;
      seen.add(p.id);
      return p.name.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
    notifyListeners();

    // Augment with API search.
    _isSearching = true;
    notifyListeners();
    try {
      final apiResults = await _api.searchDesserts(query);
      final existingIds = _searchResults.map((p) => p.id).toSet();
      final newResults = apiResults.where((p) => !existingIds.contains(p.id));
      _searchResults = [..._searchResults, ...newResults];
    } catch (_) {
      // Silently fall back to local results on network error.
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // ── Data loading ─────────────────────────────────────────────────────────

  /// Load the first page of desserts from the API.
  /// Call this once from the app shell or home view after auth.
  Future<void> loadDesserts() async {
    if (_status == FetchStatus.loading) return;

    _status = FetchStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _api.fetchDesserts(limit: 30);
      _apiDesserts = results;
      _status = FetchStatus.success;
    } catch (e) {
      _errorMessage = 'Could not load desserts. Check your connection.';
      _status = FetchStatus.error;
    }
    notifyListeners();
  }

  /// Silently refresh in the background (e.g. pull-to-refresh).
  Future<void> refresh() async {
    try {
      final results = await _api.fetchDesserts(limit: 30);
      _apiDesserts = results;
      _status = FetchStatus.success;
    } catch (_) {
      // Keep existing data; don't show error on background refresh.
    }
    notifyListeners();
  }
}
