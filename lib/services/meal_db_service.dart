import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

/// Integrates TheMealDB free API (https://www.themealdb.com/api.php)
/// to fetch real dessert and baked-goods data with no API key required.
class MealDbService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  static final MealDbService _instance = MealDbService._();
  factory MealDbService() => _instance;
  MealDbService._();

  // ── Public API ──

  /// Fetch a paginated list of desserts from TheMealDB with FULL details
  /// (ingredients, instructions, area) for every item.
  /// Uses batched parallel requests to avoid overloading the API.
  Future<List<Product>> fetchDesserts({int limit = 20, int offset = 0}) async {
    final meals = await _filterByCategory('Dessert');
    final slice = meals.skip(offset).take(limit).toList();

    // Fetch full details for ALL items in batches of 10 (parallel per batch).
    final results = <Product>[];
    const batchSize = 10;
    for (int i = 0; i < slice.length; i += batchSize) {
      final batch = slice.skip(i).take(batchSize).toList();
      final detailed = await Future.wait(
        batch.map((m) => _fetchMealDetail(m['idMeal'] as String)),
      );
      // If detail fetch fails for an item, fall back to summary data.
      for (int j = 0; j < batch.length; j++) {
        results.add(detailed[j] ?? _summaryToProduct(batch[j]));
      }
    }

    return results;
  }

  /// Fetch a single product detail by its TheMealDB ID.
  Future<Product?> fetchDetail(String mealId) => _fetchMealDetail(mealId);

  /// Search for desserts by name.
  Future<List<Product>> searchDesserts(String query) async {
    final uri = Uri.parse('$_base/search.php?s=${Uri.encodeComponent(query)}');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final meals = (body['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Filter to dessert category only to stay relevant to the app.
    final desserts = meals
        .where((m) =>
            (m['strCategory'] as String?)?.toLowerCase() == 'dessert')
        .toList();
    return desserts.map(_detailToProduct).toList();
  }

  /// Fetch the full list of dessert categories from the API.
  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$_base/categories.php');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final cats = (body['categories'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return cats.map((c) => c['strCategory'] as String).toList();
  }

  // ── Private Helpers ──

  Future<List<Map<String, dynamic>>> _filterByCategory(String category) async {
    final uri = Uri.parse('$_base/filter.php?c=${Uri.encodeComponent(category)}');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ((body['meals'] as List?)?.cast<Map<String, dynamic>>()) ?? [];
  }

  Future<Product?> _fetchMealDetail(String mealId) async {
    try {
      final uri = Uri.parse('$_base/lookup.php?i=$mealId');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = (body['meals'] as List?)?.cast<Map<String, dynamic>>();
      if (meals == null || meals.isEmpty) return null;
      return _detailToProduct(meals.first);
    } catch (_) {
      return null;
    }
  }

  /// Maps a full detail response to our Product model.
  Product _detailToProduct(Map<String, dynamic> m) {
    final id = m['idMeal'] as String? ?? '';
    final name = m['strMeal'] as String? ?? 'Unknown';
    final category = m['strCategory'] as String? ?? 'Dessert';
    final area = m['strArea'] as String? ?? '';
    final instructions = m['strInstructions'] as String? ?? '';
    final thumb = m['strMealThumb'] as String? ?? '';
    final tags = (m['strTags'] as String? ?? '').split(',')
      ..removeWhere((t) => t.trim().isEmpty);

    // Build ingredients from the 20 potential ingredient slots.
    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = m['strIngredient$i'] as String? ?? '';
      final measure = m['strMeasure$i'] as String? ?? '';
      if (ingredient.trim().isNotEmpty) {
        ingredients.add(Ingredient(name: ingredient.trim(), quality: measure.trim()));
      }
    }

    // Derive a plausible category label that matches the app's filter chips.
    final mappedCategory = _mapCategory(category, name);

    return Product(
      id: 'mdb_$id',
      name: name,
      subtitle: area.isNotEmpty ? '$area · $mappedCategory' : mappedCategory,
      description: instructions.length > 300
          ? '${instructions.substring(0, 300).trimRight()}…'
          : instructions,
      price: _derivePrice(category, name),
      imageUrl: thumb,
      rating: _deriveRating(id),
      reviewCount: _deriveReviews(id),
      category: mappedCategory,
      moods: tags.take(2).map(_tagToMood).whereType<String>().toList(),
      ingredients: ingredients.take(8).toList(),
      nutrition: _estimateNutrition(category),
    );
  }

  /// Maps a summary-only response (from filter endpoint) to Product.
  Product _summaryToProduct(Map<String, dynamic> m) {
    final id = m['idMeal'] as String? ?? '';
    final name = m['strMeal'] as String? ?? 'Unknown';
    final thumb = m['strMealThumb'] as String? ?? '';
    return Product(
      id: 'mdb_$id',
      name: name,
      subtitle: 'International Dessert',
      description: '',
      price: _derivePrice('Dessert', name),
      imageUrl: thumb,
      rating: _deriveRating(id),
      reviewCount: _deriveReviews(id),
      category: 'Desserts',
    );
  }

  String _mapCategory(String apiCategory, String name) {
    final n = name.toLowerCase();
    if (n.contains('macaron')) return 'Macarons';
    if (n.contains('croissant')) return 'Croissants';
    if (n.contains('tart') || n.contains('pie')) return 'Tarts';
    if (n.contains('eclair') || n.contains('éclair')) return 'Eclairs';
    if (n.contains('chocolate') || n.contains('truffle')) return 'Chocolates';
    if (n.contains('cake') || n.contains('pudding') || n.contains('brownie')) {
      return 'Pastries';
    }
    return 'Desserts';
  }

  double _derivePrice(String category, String name) {
    // Produce a consistent but varied price seeded by the name length.
    final base = name.length % 5;
    return 4.50 + base * 1.75;
  }

  double _deriveRating(String id) {
    // Pseudo-deterministic rating between 4.3 and 5.0.
    final seed = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return 4.3 + (seed % 8) * 0.1;
  }

  int _deriveReviews(String id) {
    final seed = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return 40 + seed % 200;
  }

  String? _tagToMood(String tag) {
    final t = tag.trim().toLowerCase();
    if (t.isEmpty) return null;
    if ({'meat', 'protein', 'savory'}.any((k) => t.contains(k))) {
      return 'Need a Boost';
    }
    return 'Feeling Fancy';
  }

  Map<String, String> _estimateNutrition(String category) {
    // Rough estimates per serving, categorised by type.
    switch (category.toLowerCase()) {
      case 'dessert':
        return {'CALORIES': '220', 'NET FAT': '10g', 'SUGARS': '22g', 'PROTEIN': '3g'};
      default:
        return {'CALORIES': '180', 'NET FAT': '8g', 'SUGARS': '18g', 'PROTEIN': '2g'};
    }
  }
}
