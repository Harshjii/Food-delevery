import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Web Server Client ID configured
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '685775433685-sf1cae4gl6qou4cf1v3gkb4kh9v8vmbf.apps.googleusercontent.com',
  );

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Sign Up with Name, Email, Password & Phone Number
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone, // <-- Yahan phone number add kiya gaya hai
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await user.reload();

        // Firestore me user document ke andar phone aur joined date save ho rahi hai
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(), // <-- Phone number Firestore me store hoga
          'createdAt': FieldValue.serverTimestamp(), // <-- Joined date store hogi
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Sign up failed.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // Sign In with Email & Password
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login failed.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      // Purane cached session ko clear karne ke liye
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google sign-in cancelled.";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'Foodie',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? 'N/A', // Google sign-in me agar phone na ho toh N/A
          'createdAt': FieldValue.serverTimestamp(), // Agar pehli baar sign-in hai toh date set hogi
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Google sign-in failed.";
    } catch (e) {
      return "Google Sign-In failed: $e";
    }
  }

  // Reset Password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Could not send reset link.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}