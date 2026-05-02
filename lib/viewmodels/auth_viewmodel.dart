import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/product_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoadingAuth = true;
  bool get isLoadingAuth => _isLoadingAuth;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  Future<void> init() async {
    final user = _auth.currentUser;
    if (user != null) {
      _isSignedIn = true;
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
      if (credential.user == null) {
        return 'Login failed. Please try again.';
      }
      _isSignedIn = true;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> registerWithEmail(String name, String email, String password) async {
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
    await ProductRepository().clearSession();
    _isSignedIn = false;
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
}
