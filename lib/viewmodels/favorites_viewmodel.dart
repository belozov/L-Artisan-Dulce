import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<void> loadFavorites() async {
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

  void clear() {
    _favoriteIds.clear();
    final all = [...kPopularDesserts, ...kExploreProducts];
    for (final p in all) {
      p.isFavorite = false;
    }
    notifyListeners();
  }
}
