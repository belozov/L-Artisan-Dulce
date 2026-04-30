import 'dart:math';
import '../models/product_model.dart';

/// Simulates network latency for realistic API behavior.
class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  final _random = Random();

  /// Simulate network delay (200-800ms).
  Future<void> _simulateLatency() async {
    final ms = 200 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: ms));
  }

  // ── Products ──

  /// Fetch all popular/featured products.
  Future<ApiResponse<List<Product>>> fetchPopularProducts() async {
    await _simulateLatency();
    try {
      return ApiResponse.success(kPopularDesserts);
    } catch (e) {
      return ApiResponse.error('Failed to load popular products: $e');
    }
  }

  /// Fetch all explore products, optionally filtered by category.
  Future<ApiResponse<List<Product>>> fetchExploreProducts({String? category}) async {
    await _simulateLatency();
    try {
      List<Product> results = kExploreProducts;
      if (category != null && category.isNotEmpty) {
        results = results
            .where((p) => p.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
      return ApiResponse.success(results);
    } catch (e) {
      return ApiResponse.error('Failed to load products: $e');
    }
  }

  /// Fetch a single product by ID.
  Future<ApiResponse<Product>> fetchProductById(String id) async {
    await _simulateLatency();
    try {
      final all = [...kPopularDesserts, ...kExploreProducts];
      final product = all.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Product not found'),
      );
      return ApiResponse.success(product);
    } catch (e) {
      return ApiResponse.error('Product not found: $e');
    }
  }

  /// Search products by query string.
  Future<ApiResponse<List<Product>>> searchProducts(String query) async {
    await _simulateLatency();
    try {
      if (query.isEmpty) return ApiResponse.success([]);
      final q = query.toLowerCase();
      final all = [...kPopularDesserts, ...kExploreProducts];
      final seen = <String>{};
      final results = all.where((p) {
        if (seen.contains(p.id)) return false;
        seen.add(p.id);
        return p.name.toLowerCase().contains(q) ||
            p.subtitle.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
      return ApiResponse.success(results);
    } catch (e) {
      return ApiResponse.error('Search failed: $e');
    }
  }

  /// Fetch available categories.
  Future<ApiResponse<List<String>>> fetchCategories() async {
    await _simulateLatency();
    return ApiResponse.success(List.from(kFilterChips));
  }

  // ── Orders ──

  /// Submit a new order.
  Future<ApiResponse<String>> submitOrder({
    required List<OrderItem> items,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    await _simulateLatency();
    try {
      // Simulate order ID generation
      final orderId = 'ORD-${1000 + _random.nextInt(9000)}';
      return ApiResponse.success(orderId);
    } catch (e) {
      return ApiResponse.error('Order submission failed: $e');
    }
  }

  // ── User ──

  /// Simulate user login.
  Future<ApiResponse<UserProfile>> login({
    required String email,
    required String password,
  }) async {
    await _simulateLatency();
    try {
      // Accept any non-empty credentials for demo
      if (email.isEmpty || password.isEmpty) {
        return ApiResponse.error('Email and password are required');
      }
      return ApiResponse.success(UserProfile(
        id: 'usr_${_random.nextInt(99999)}',
        name: email.split('@').first.replaceAll('.', ' '),
        email: email,
      ));
    } catch (e) {
      return ApiResponse.error('Login failed: $e');
    }
  }

  /// Simulate user registration.
  Future<ApiResponse<UserProfile>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _simulateLatency();
    try {
      if (name.isEmpty || email.isEmpty || password.length < 4) {
        return ApiResponse.error('All fields required, password min 4 chars');
      }
      return ApiResponse.success(UserProfile(
        id: 'usr_${_random.nextInt(99999)}',
        name: name,
        email: email,
      ));
    } catch (e) {
      return ApiResponse.error('Registration failed: $e');
    }
  }

  /// Update user profile.
  Future<ApiResponse<bool>> updateProfile({
    String? name,
    String? email,
    String? address,
  }) async {
    await _simulateLatency();
    return ApiResponse.success(true);
  }
}

// ── Response Wrapper ──

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse._({this.data, this.error, required this.isSuccess});

  factory ApiResponse.success(T data) =>
      ApiResponse._(data: data, isSuccess: true);

  factory ApiResponse.error(String message) =>
      ApiResponse._(error: message, isSuccess: false);
}

// ── Data Transfer Objects ──

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
      };
}

class UserProfile {
  final String id;
  final String name;
  final String email;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
  });
}
