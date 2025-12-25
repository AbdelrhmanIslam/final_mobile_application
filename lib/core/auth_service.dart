import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // ==========================
  // GOOGLE SIGN IN
  // ==========================
  Future<String?> signInWithGoogle() async {
    try {
      // 1️⃣ Trigger Google Sign In
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) {
        return "Sign in cancelled";
      }

      // 2️⃣ Get Auth Details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 3️⃣ Create Firebase Credential
      final AuthCredential credential =
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4️⃣ Firebase Auth Login (CRITICAL STEP)
      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        return "Google sign in failed";
      }

      // 5️⃣ Firestore user creation (NON-BLOCKING)
      _createUserIfNotExists(user);

      return null; // ✅ SUCCESS
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Authentication error";
    } catch (e) {
      debugPrint("Google SignIn Error: $e");
      return "Login failed, please try again";
    }
  }

  // ==========================
  // SAFE FIRESTORE USER CREATION
  // ==========================
  Future<void> _createUserIfNotExists(User user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'username': user.displayName ?? 'Google User',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      // 🔥 Ignore temporary Firestore errors
      if (e.code == 'unavailable') {
        debugPrint('Firestore unavailable, will sync later');
      } else {
        debugPrint('Firestore error: ${e.message}');
      }
    }
  }

  // ==========================
  // EMAIL SIGN UP
  // ==========================
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential result =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return null;
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "Error: $e";
    }
  }

  // ==========================
  // EMAIL LOGIN
  // ==========================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "Error: $e";
    }
  }

  // ==========================
  // LOGOUT
  // ==========================
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
