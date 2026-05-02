import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductsViewModel extends ChangeNotifier {
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

  List<Product> get filteredExploreProducts {
    if (_selectedChipIndex == 0) return kExploreProducts;
    final chipLabel = kFilterChips[_selectedChipIndex];
    return kExploreProducts.where((p) {
      return p.category.toLowerCase() == chipLabel.toLowerCase();
    }).toList();
  }

  int _selectedMoodIndex = -1;
  int get selectedMoodIndex => _selectedMoodIndex;

  void selectMood(int index) {
    _selectedMoodIndex = _selectedMoodIndex == index ? -1 : index;
    notifyListeners();
  }

  List<Product> get filteredPopularDesserts {
    if (_selectedMoodIndex < 0) return kPopularDesserts;
    final mood = kMoods[_selectedMoodIndex].label;
    final filtered = kPopularDesserts.where((p) {
      return p.moods.contains(mood);
    }).toList();
    return filtered.isEmpty ? kPopularDesserts : filtered;
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Product> get searchResults {
    if (_searchQuery.isEmpty) return [];

    final q = _searchQuery.toLowerCase();
    final all = [...kPopularDesserts, ...kExploreProducts];
    final seen = <String>{};

    return all.where((p) {
      if (seen.contains(p.id)) return false;
      seen.add(p.id);
      return p.name.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }
}
