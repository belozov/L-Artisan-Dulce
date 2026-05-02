import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_record.dart';

class OrdersViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<void> loadOrders() async {
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
}
