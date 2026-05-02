import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _db.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _userName = data['name'] ?? user.displayName ?? 'User';
      _userEmail = data['email'] ?? user.email ?? '';
      _profilePhotoPath = data['photoUrl'] ?? '';
      _deliveryAddress = data['deliveryAddress'] ?? '';
      _notificationsEnabled = data['notificationsEnabled'] ?? true;
      _paymentLast4 = data['paymentLast4'] ?? '4829';
      _paymentBrand = data['paymentBrand'] ?? 'Visa';
    } else {
      _userName = user.displayName ?? 'User';
      _userEmail = user.email ?? '';

      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
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
    notifyListeners();
  }

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

  Future<void> updatePayment({required String last4, required String brand}) async {
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
