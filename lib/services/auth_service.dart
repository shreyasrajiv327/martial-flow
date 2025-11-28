import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // sign up
  Future<String?> signUp(String name, String email, String password) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // update display name
      await userCred.user!.updateDisplayName(name);

      // Create initial Firestore doc
      await _db.collection("users").doc(userCred.user!.uid).set({
        "name": name,
        "email": email,
        "onboarded": false, // mark not onboarded yet
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // sign in
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

Future<void> signOut() async {
  print("Signed out!");
  await _auth.signOut();
}

  Stream<User?> get userStream => _auth.authStateChanges();
}
