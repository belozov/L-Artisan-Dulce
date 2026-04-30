import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import 'api_service.dart';

/// Repository pattern — single source of truth for data access.
/// Coordinates between the remote API and local cache.
class ProductRepository {
  static final ProductRepository _instance = ProductRepository._();
  factory ProductRepository() => _instance;
  ProductRepository._();

  final _api = ApiService();

  // ── In-memory cache ──
  List<Product>? _popularCache;
  List<Product>? _exploreCache;
  DateTime? _lastFetch;

  static const _cacheMaxAge = Duration(minutes: 5);

  bool get _isCacheValid =>
      _lastFetch != null && DateTime.now().difference(_lastFetch!) < _cacheMaxAge;

  /// Invalidate all caches (e.g., after pull-to-refresh).
  void invalidateCache() {
    _popularCache = null;
    _exploreCache = null;
    _lastFetch = null;
  }

  // ── Products ──

  /// Get popular products (cache-first).
  Future<List<Product>> getPopularProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid && _popularCache != null) {
      return _popularCache!;
    }
    final response = await _api.fetchPopularProducts();
    if (response.isSuccess) {
      _popularCache = response.data!;
      _lastFetch = DateTime.now();
      return _popularCache!;
    }
    // Fallback to cache if available
    return _popularCache ?? kPopularDesserts;
  }

  /// Get explore products, optionally filtered (cache-first).
  Future<List<Product>> getExploreProducts({
    String? category,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCacheValid && _exploreCache != null) {
      final cached = _exploreCache!;
      if (category != null && category.isNotEmpty) {
        return cached
            .where((p) => p.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
      return cached;
    }
    // Fetch unfiltered for cache, then apply filter
    final response = await _api.fetchExploreProducts();
    if (response.isSuccess) {
      _exploreCache = response.data!;
      _lastFetch = DateTime.now();
      if (category != null && category.isNotEmpty) {
        return _exploreCache!
            .where((p) => p.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
      return _exploreCache!;
    }
    return _exploreCache ?? kExploreProducts;
  }

  /// Search products.
  Future<List<Product>> searchProducts(String query) async {
    final response = await _api.searchProducts(query);
    return response.isSuccess ? response.data! : [];
  }

  /// Get product by ID.
  Future<Product?> getProductById(String id) async {
    // Check cache first
    final cached = [...?_popularCache, ...?_exploreCache];
    for (final p in cached) {
      if (p.id == id) return p;
    }
    final response = await _api.fetchProductById(id);
    return response.isSuccess ? response.data : null;
  }

  // ── Orders ──

  /// Submit an order and return order ID.
  Future<String?> submitOrder({
    required List<OrderItem> items,
    required String address,
    required String payment,
  }) async {
    final response = await _api.submitOrder(
      items: items,
      deliveryAddress: address,
      paymentMethod: payment,
    );
    return response.isSuccess ? response.data : null;
  }

  // ── Auth ──

  Future<UserProfile?> login(String email, String password) async {
    final response = await _api.login(email: email, password: password);
    if (response.isSuccess) {
      await _saveAuthLocally(response.data!);
      return response.data;
    }
    return null;
  }

  Future<UserProfile?> register(String name, String email, String password) async {
    final response = await _api.register(name: name, email: email, password: password);
    if (response.isSuccess) {
      await _saveAuthLocally(response.data!);
      return response.data;
    }
    return null;
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? address,
  }) async {
    final response = await _api.updateProfile(
      name: name,
      email: email,
      address: address,
    );
    if (!response.isSuccess) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    if (name != null && name.isNotEmpty) {
      await prefs.setString('user_name', name);
    }
    if (email != null && email.isNotEmpty) {
      await prefs.setString('user_email', email);
    }
    if (address != null && address.isNotEmpty) {
      await prefs.setString('delivery_address', address);
    }
    return true;
  }

  // ── Local Persistence ──

  Future<void> _saveAuthLocally(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setBool('is_signed_in', true);
  }

  Future<void> saveFavorites(List<String> productIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', productIds);
  }

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }

  Future<void> saveProfilePhoto(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo', path);
  }

  Future<String?> loadProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_photo');
  }

  Future<Map<String, String>> loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'photo': prefs.getString('profile_photo') ?? '',
      'address': prefs.getString('delivery_address') ?? '',
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_signed_in');
  }
}

