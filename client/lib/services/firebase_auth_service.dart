import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  /// Google Sign-In (web uses popup, mobile uses GoogleSignIn SDK)
  Future<UserCredential> signInWithGoogle() async {
    if (_isDummy) {
      throw Exception('Firebase Auth is not available on this platform.');
    }

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.setCustomParameters({'prompt': 'select_account'});
        return await _firebaseAuth.signInWithPopup(provider);
      }

      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      rethrow;
    }
  }

  /// Apple Sign-In (native only). Uses nonce for replay protection.
  Future<UserCredential> signInWithApple() async {
    if (_isDummy) {
      throw Exception('Firebase Auth is not available on this platform.');
    }

    try {
      if (kIsWeb) {
        final provider = OAuthProvider('apple.com');
        provider.addScope('email');
        provider.addScope('name');
        return await _firebaseAuth.signInWithPopup(provider);
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      return await _firebaseAuth.signInWithCredential(oauthCredential);
    } catch (e) {
      debugPrint('❌ Apple sign-in error: $e');
      rethrow;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
