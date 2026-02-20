import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Service - Initialize and manage Firebase connection
/// 
/// Handles Firebase authentication, Firestore database, and storage
/// This service is called during app startup in main.dart
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  /// Initialize Firebase with platform-specific options
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization error: $e');
      rethrow;
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => Firebase.apps.isNotEmpty;

  /// Get current Firebase app instance
  static FirebaseApp get app => Firebase.app();
}

/// Firebase Configuration - Store your Firebase project settings
/// Generated from: https://console.firebase.google.com
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAYkZHimR12SSGnSKxy3lUHybSgFB5VZX0',
    appId: '1:730780218273:web:a58712579f85c569d9d1e0',
    messagingSenderId: '730780218273',
    projectId: 'tobi-to-do',
    authDomain: 'tobi-to-do.firebaseapp.com',
    storageBucket: 'tobi-to-do.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYkZHimR12SSGnSKxy3lUHybSgFB5VZX0',
    appId: '1:730780218273:android:a58712579f85c569d9d1e0',
    messagingSenderId: '730780218273',
    projectId: 'tobi-to-do',
    storageBucket: 'tobi-to-do.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYkZHimR12SSGnSKxy3lUHybSgFB5VZX0',
    appId: '1:730780218273:ios:a58712579f85c569d9d1e0',
    messagingSenderId: '730780218273',
    projectId: 'tobi-to-do',
    storageBucket: 'tobi-to-do.firebasestorage.app',
    iosBundleId: 'com.example.tobiTodo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYkZHimR12SSGnSKxy3lUHybSgFB5VZX0',
    appId: '1:730780218273:macos:a58712579f85c569d9d1e0',
    messagingSenderId: '730780218273',
    projectId: 'tobi-to-do',
    storageBucket: 'tobi-to-do.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAYkZHimR12SSGnSKxy3lUHybSgFB5VZX0',
    appId: '1:730780218273:windows:a58712579f85c569d9d1e0',
    messagingSenderId: '730780218273',
    projectId: 'tobi-to-do',
    storageBucket: 'tobi-to-do.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyAYkZHimR12SSGnSKxy3lUHybSgFB5VZX0',
    appId: '1:730780218273:linux:a58712579f85c569d9d1e0',
    messagingSenderId: '730780218273',
    projectId: 'tobi-to-do',
    storageBucket: 'tobi-to-do.firebasestorage.app',
  );

  /// Get Firebase options based on current platform
  static FirebaseOptions get currentPlatform {
    // This will be resolved at runtime by Firebase
    throw UnsupportedError(
      'DefaultFirebaseOptions.currentPlatform is not supported in this context',
    );
  }
}
