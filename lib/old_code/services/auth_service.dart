import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  fb.User? get user => _auth.currentUser;
  String? errorMessage;

  // Stream for AuthWrapper
  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  // ----------- AUTH METHODS -----------

  Future<void> signIn(String email, String password) async {
    errorMessage = null;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } on fb.FirebaseAuthException catch (e) {
      errorMessage = _handleAuthError(e);
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    errorMessage = null;
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } on fb.FirebaseAuthException catch (e) {
      errorMessage = _handleAuthError(e);
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? displayName}) async {
    if (_auth.currentUser == null) return;

    try {
      await _auth.currentUser!.updateDisplayName(displayName);
      await _auth.currentUser!.reload();
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to update profile.";
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    errorMessage = null;
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      errorMessage = _handleAuthError(e);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // ----------- ERROR HANDLING -----------

  String _handleAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'invalid-email':
        return "Invalid email format.";
      case 'user-not-found':
        return "No account found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'weak-password':
        return "Password is too weak.";
      default:
        return "Something went wrong. Try again.";
    }
  }
}
