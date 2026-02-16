import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication Service
/// Handles user registration, login, logout, and session management
class FirebaseAuthService {
  static FirebaseAuthService? _instance;
  late final FirebaseAuth _firebaseAuth;
  final bool _isDummy;

  factory FirebaseAuthService({bool isDummy = false}) {
    if (isDummy) {
      return FirebaseAuthService._dummy();
    }
    _instance ??= FirebaseAuthService._internal();
    return _instance!;
  }

  FirebaseAuthService._internal()
      : _isDummy = false,
        _firebaseAuth = FirebaseAuth.instance;

  // Dummy constructor for web platform (doesn't initialize Firebase)
  FirebaseAuthService._dummy()
      : _isDummy = true,
        _firebaseAuth = FirebaseAuth.instance;

  /// Get FirebaseAuth instance for direct access
  FirebaseAuth get firebaseAuth {
    if (_isDummy) {
      throw Exception('Firebase Auth is not available on web platform. Use API authentication instead.');
    }
    return _firebaseAuth;
  }

  /// Get current authenticated user
  User? get currentUser {
    if (_isDummy) return null;
    return _firebaseAuth.currentUser;
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    if (_isDummy) return const Stream.empty();
    return _firebaseAuth.authStateChanges();
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User registered: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Registration error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Login with email and password
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User logged in: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Login error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.updatePhotoURL(photoURL);
      await currentUser?.reload();
      debugPrint('✅ User profile updated');
    } catch (e) {
      debugPrint('❌ Profile update error: $e');
      rethrow;
    }
  }

  /// Get ID token for backend authentication
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final token = await currentUser?.getIdToken(forceRefresh);
      return token;
    } catch (e) {
      debugPrint('❌ Error getting ID token: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('✅ User logged out');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteUser() async {
    try {
      await currentUser?.delete();
      debugPrint('✅ User account deleted');
    } catch (e) {
      debugPrint('❌ Delete user error: $e');
      rethrow;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current user's UID
  String? get uid => currentUser?.uid;

  /// Get current user's email
  String? get email => currentUser?.email;

  /// Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
      debugPrint('✅ Verification email sent to ${currentUser?.email}');
    } catch (e) {
      debugPrint('❌ Error sending verification email: $e');
      rethrow;
    }
  }
}
