import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_service.dart';

/// AuthService handles all Firebase Authentication operations
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Get the current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get user ID of current user
  String? get userId => currentUser?.uid;

  /// Firestore service instance for direct access
  FirestoreService get firestoreService => _firestoreService;

  /// Sign up with email and password
  /// Creates user in Auth and Firestore
  /// Returns UserCredential on success, throws exception on failure
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _firestoreService.createUserDocument(
          userId: userCredential.user!.uid,
          email: email.trim(),
          displayName: userCredential.user!.displayName,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw _firestoreService.handleFirestoreException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Login with email and password
  /// Updates last login in Firestore
  /// Returns UserCredential on success, throws exception on failure
  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update last login timestamp in Firestore
      if (userCredential.user != null) {
        await _firestoreService.updateLastLogin(userCredential.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sign out the current user
  /// Returns void on success, throws exception on failure
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  /// Reload user data
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to reload user data. Please try again.';
    }
  }

  /// Handle FirebaseAuthException and return user-friendly error messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // Sign up errors
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email or login.';
      case 'invalid-email':
        return 'Invalid email address. Please check and try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';

      // Login errors
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';

      // Password reset errors
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      // General errors
      case 'requires-recent-login':
        return 'Please login again to complete this action.';
      case 'user-token-expired':
        return 'Your session has expired. Please login again.';

      default:
        return e.message ?? 'An authentication error occurred. Please try again.';
    }
  }
}
