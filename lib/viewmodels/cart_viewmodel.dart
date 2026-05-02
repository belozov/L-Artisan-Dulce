import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'orders_viewmodel.dart';
import 'navigation_viewmodel.dart';

class CartViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get cartItemCount {
    return _cartItems.fold(0, (totalSum, item) => totalSum + item.quantity);
  }

  double get cartTotal {
    return _cartItems.fold(0.0, (totalSum, item) => totalSum + item.total);
  }

  Future<void> loadCart() async {
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

  Future<void> createOrder(OrdersViewModel ordersVM, NavigationViewModel navVM) async {
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

    await ordersVM.loadOrders();

    navVM.switchTab(2);
    notifyListeners();
  }

  void clear() {
    _cartItems.clear();
    notifyListeners();
  }
}
