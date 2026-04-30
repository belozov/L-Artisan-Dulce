import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../services/product_repository.dart';

class CartItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;
}

enum OrderStatus { preparing, onTheWay, delivered, cancelled }

class OrderRecord {
  final String id;
  final String date;
  final List<String> items;
  final double total;
  final OrderStatus status;

  const OrderRecord({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class AppState extends ChangeNotifier {
  final _repo = ProductRepository();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ProductRepository get repository => _repo;

  bool _isLoadingAuth = true;
  bool get isLoadingAuth => _isLoadingAuth;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  Future<void> init() async {
    final user = _auth.currentUser;

    if (user != null) {
      _isSignedIn = true;
      await _loadUserProfile(user.uid);
      await loadFavoritesFromDb();
      await loadCartFromDb();
      await loadOrdersFromDb();
    } else {
      _isSignedIn = false;
    }

    _isLoadingAuth = false;
    notifyListeners();
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;

      if (user == null) {
        return 'Login failed. Please try again.';
      }

      await _loadUserProfile(user.uid);
      await loadFavoritesFromDb();
      await loadCartFromDb();
      await loadOrdersFromDb();

      _isSignedIn = true;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;

      if (user == null) {
        return 'Registration failed. Please try again.';
      }

      await user.updateDisplayName(name.trim());

      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'photoUrl': '',
        'deliveryAddress': '',
        'notificationsEnabled': true,
        'paymentLast4': '4829',
        'paymentBrand': 'Visa',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _userName = name.trim();
      _userEmail = email.trim();
      _profilePhotoPath = '';
      _deliveryAddress = '';
      _notificationsEnabled = true;

      await loadFavoritesFromDb();
      await loadCartFromDb();
      await loadOrdersFromDb();

      _isSignedIn = true;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();

    _isSignedIn = false;
    _currentTabIndex = 0;

    _userName = 'User';
    _userEmail = '';
    _profilePhotoPath = '';
    _deliveryAddress = '';

    _favoriteIds.clear();
    _cartItems.clear();
    _orders.clear();

    await _repo.clearSession();

    notifyListeners();
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'internal-error':
        return 'Firebase internal error. Check Authentication settings.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    final user = _auth.currentUser;
    final doc = await _db.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;

      _userName = data['name'] ?? user?.displayName ?? 'User';
      _userEmail = data['email'] ?? user?.email ?? '';
      _profilePhotoPath = data['photoUrl'] ?? '';
      _deliveryAddress = data['deliveryAddress'] ?? '';
      _notificationsEnabled = data['notificationsEnabled'] ?? true;
      _paymentLast4 = data['paymentLast4'] ?? '4829';
      _paymentBrand = data['paymentBrand'] ?? 'Visa';
    } else {
      _userName = user?.displayName ?? 'User';
      _userEmail = user?.email ?? '';

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': _userName,
        'email': _userEmail,
        'photoUrl': '',
        'deliveryAddress': '',
        'notificationsEnabled': true,
        'paymentLast4': '4829',
        'paymentBrand': 'Visa',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void switchTab(int index) {
    _currentTabIndex = index;
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

    _currentTabIndex = 1;
    notifyListeners();
  }

  int _selectedChipIndex = 0;
  int get selectedChipIndex => _selectedChipIndex;

  void selectChip(int index) {
    _selectedChipIndex = index;
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

  final Set<String> _favoriteIds = {};

  bool isFavorite(String id) => _favoriteIds.contains(id);
  int get favoriteCount => _favoriteIds.length;
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<Product> get favoriteProducts {
    final all = [...kPopularDesserts, ...kExploreProducts];

    return all.where((p) {
      return _favoriteIds.contains(p.id);
    }).toList();
  }

  Future<void> loadFavoritesFromDb() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    _favoriteIds.clear();

    for (final doc in snapshot.docs) {
      _favoriteIds.add(doc.id);
    }

    final all = [...kPopularDesserts, ...kExploreProducts];

    for (final p in all) {
      p.isFavorite = _favoriteIds.contains(p.id);
    }

    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(id);

    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      await ref.delete();
    } else {
      _favoriteIds.add(id);

      await ref.set({'productId': id, 'addedAt': FieldValue.serverTimestamp()});
    }

    final all = [...kPopularDesserts, ...kExploreProducts];

    for (final p in all) {
      if (p.id == id) {
        p.isFavorite = _favoriteIds.contains(id);
      }
    }

    notifyListeners();
  }

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get cartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get cartTotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> loadCartFromDb() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    _cartItems.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      _cartItems.add(
        CartItem(
          productId: data['productId'] ?? doc.id,
          productName: data['productName'] ?? 'Product',
          quantity: data['quantity'] ?? 1,
          price: (data['price'] as num).toDouble(),
        ),
      );
    }

    notifyListeners();
  }

  Future<void> addToCart(Product product, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final existing = _cartItems.indexWhere(
      (item) => item.productId == product.id,
    );

    int newQuantity = quantity;

    if (existing >= 0) {
      final old = _cartItems[existing];
      newQuantity = old.quantity + quantity;

      _cartItems[existing] = CartItem(
        productId: product.id,
        productName: product.name,
        quantity: newQuantity,
        price: product.price,
      );
    } else {
      _cartItems.add(
        CartItem(
          productId: product.id,
          productName: product.name,
          quantity: quantity,
          price: product.price,
        ),
      );
    }

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product.id)
        .set({
          'productId': product.id,
          'productName': product.name,
          'price': product.price,
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    notifyListeners();
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;

    if (user != null) {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    _cartItems.clear();
    notifyListeners();
  }

  final List<OrderRecord> _orders = [];

  List<OrderRecord> get activeOrders {
    return _orders.where((order) {
      return order.status == OrderStatus.preparing ||
          order.status == OrderStatus.onTheWay;
    }).toList();
  }

  List<OrderRecord> get orderHistory {
    return _orders.where((order) {
      return order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled;
    }).toList();
  }

  Future<void> loadOrdersFromDb() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    _orders.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final items = (data['items'] as List<dynamic>? ?? []);

      _orders.add(
        OrderRecord(
          id: data['id'] ?? doc.id,
          date: _formatOrderDate(data['createdAt']),
          items: items.map((item) {
            return '${item['quantity']}× ${item['productName']}';
          }).toList(),
          total: (data['total'] as num).toDouble(),
          status: _parseOrderStatus(data['status']),
        ),
      );
    }

    notifyListeners();
  }

  Future<void> createOrder() async {
    final user = _auth.currentUser;

    if (user == null || _cartItems.isEmpty) return;

    final orderRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc();

    await orderRef.set({
      'id': orderRef.id,
      'items': _cartItems.map((item) {
        return {
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.quantity,
          'price': item.price,
        };
      }).toList(),
      'total': cartTotal,
      'status': 'preparing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final cartSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    for (final doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    _cartItems.clear();

    await loadOrdersFromDb();

    _currentTabIndex = 2;
    notifyListeners();
  }

  OrderStatus _parseOrderStatus(String? status) {
    switch (status) {
      case 'preparing':
        return OrderStatus.preparing;
      case 'onTheWay':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.preparing;
    }
  }

  String _formatOrderDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day.$month.$year';
    }

    return 'Today';
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

  String _userName = 'User';
  String _userEmail = '';
  bool _notificationsEnabled = true;
  String _deliveryAddress = '';
  String _paymentLast4 = '4829';
  String _paymentBrand = 'Visa';
  String _profilePhotoPath = '';

  String get profilePhotoPath => _profilePhotoPath;
  String get userName => _userName;
  String get userEmail => _userEmail;

  String get userInitials {
    final parts = _userName.trim().split(' ');

    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return _userName.isNotEmpty ? _userName[0].toUpperCase() : '?';
  }

  bool get notificationsEnabled => _notificationsEnabled;
  String get deliveryAddress => _deliveryAddress;
  String get paymentLast4 => _paymentLast4;
  String get paymentBrand => _paymentBrand;
  String get paymentDisplay => '$_paymentBrand •••• $_paymentLast4';

  Future<void> updateProfile({String? name, String? email}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (name != null && name.trim().isNotEmpty) {
      _userName = name.trim();
      await user.updateDisplayName(_userName);
    }

    if (email != null && email.trim().isNotEmpty) {
      _userEmail = email.trim();
    }

    await _db.collection('users').doc(user.uid).update({
      'name': _userName,
      'email': _userEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  Future<void> setProfilePhoto(String path) async {
    _profilePhotoPath = path;

    final user = _auth.currentUser;

    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'photoUrl': path,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  }

  Future<void> removeProfilePhoto() async {
    _profilePhotoPath = '';

    final user = _auth.currentUser;

    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'photoUrl': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;

    final user = _auth.currentUser;

    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'notificationsEnabled': _notificationsEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  }

  Future<void> updateDeliveryAddress(String address) async {
    if (address.trim().isEmpty) return;

    _deliveryAddress = address.trim();

    final user = _auth.currentUser;

    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'deliveryAddress': _deliveryAddress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  }

  Future<void> updatePayment({
    required String last4,
    required String brand,
  }) async {
    _paymentLast4 = last4;
    _paymentBrand = brand;

    final user = _auth.currentUser;

    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'paymentLast4': last4,
        'paymentBrand': brand,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }

  static AppState read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppStateProvider>()!.notifier!;
  }
}
