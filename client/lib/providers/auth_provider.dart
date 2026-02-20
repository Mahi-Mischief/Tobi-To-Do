import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/models/user_model.dart' as app_user;
import 'package:tobi_todo/services/api_client.dart';
import 'package:tobi_todo/services/secure_storage_service.dart';
import 'package:tobi_todo/services/firebase_auth_service.dart';

final apiClientProvider = Provider((ref) => ApiClient());
final secureStorageProvider = Provider((ref) => SecureStorageService());
final firebaseAuthServiceProvider = Provider((ref) => FirebaseAuthService());

// Auth provider
class AuthNotifier extends AsyncNotifier<app_user.User?> {
  late final ApiClient apiClient;
  late final SecureStorageService secureStorage;
  late final FirebaseAuthService firebaseAuthService;

  @override
  Future<app_user.User?> build() async {
    apiClient = ref.watch(apiClientProvider);
    secureStorage = ref.watch(secureStorageProvider);
    
    // Initialize Firebase auth service for all platforms (web + native)
    firebaseAuthService = FirebaseAuthService();

    // Check if user is already logged in from storage
    try {
      final storedUserId = await secureStorage.getUserId();
      final storedEmail = await secureStorage.getEmail();
      final hasToken = await secureStorage.hasToken();

      if (storedUserId != null && storedUserId.isNotEmpty) {
        // Try to restore a native Firebase user if possible
        if (!kIsWeb) {
          final current = firebaseAuthService.firebaseAuth.currentUser;
          if (current != null) {
            final restored = app_user.User(
              id: current.uid,
              email: current.email ?? storedEmail ?? '',
              fullName: current.displayName ?? '',
              createdAt: DateTime.now(),
            );
            return restored;
          }
        }

        // Fallback: return a minimal user from stored data (useful for web/API flows)
        if (storedEmail != null && hasToken) {
          return app_user.User(
            id: storedUserId,
            email: storedEmail,
            fullName: '',
            createdAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ [AUTH] Failed to restore user from storage: $e');
    }

    return null; // Start with no user
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    debugPrint('🔄 [AUTH] Starting registration: $email');
    state = const AsyncValue.loading();
    try {
      // Use Firebase for registration across platforms (web & native)
      debugPrint('🔄 [AUTH] Creating Firebase user...');
      final userCred = await firebaseAuthService.firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ [AUTH] Firebase user created: ${userCred.user?.uid}');

      await userCred.user?.updateDisplayName(fullName);
      await userCred.user?.reload();
      final idToken = await userCred.user?.getIdToken() ?? '';

      final user = app_user.User(
        id: userCred.user!.uid,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      await secureStorage.saveToken(idToken);
      await secureStorage.saveUserId(user.id);
      await secureStorage.saveEmail(user.email);
      debugPrint('✅ [AUTH] User data saved');

      state = AsyncValue.data(user);
    } catch (e, st) {
      debugPrint('❌ [AUTH] Registration error: $e');
      state = AsyncValue.error(e, st);
    }
    } catch (e, st) {
      debugPrint('❌ [AUTH] Registration error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    debugPrint('🔄 [AUTH] Starting login: $email');
    state = const AsyncValue.loading();
    try {
      // Use Firebase for login across platforms (web + native)
      debugPrint('🔄 [AUTH] Signing in with Firebase...');
      final userCred = await firebaseAuthService.firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ [AUTH] Firebase signin successful: ${userCred.user?.uid}');

      final idToken = await userCred.user?.getIdToken() ?? '';
      debugPrint('✅ [AUTH] Token obtained');

      final user = app_user.User(
        id: userCred.user!.uid,
        email: email,
        fullName: userCred.user!.displayName ?? '',
        createdAt: DateTime.now(),
      );

      await secureStorage.saveToken(idToken);
      await secureStorage.saveUserId(user.id);
      await secureStorage.saveEmail(user.email);
      debugPrint('✅ [AUTH] User data saved');

      state = AsyncValue.data(user);
    } catch (e, st) {
      debugPrint('❌ [AUTH] Login error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      if (!kIsWeb) {
        await firebaseAuthService.firebaseAuth.signOut();
      }
      await secureStorage.clearAll();
      state = const AsyncValue.data(null);
      debugPrint('✅ [AUTH] Logout successful');
    } catch (e) {
      debugPrint('❌ [AUTH] Logout error: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, app_user.User?>(() {
  return AuthNotifier();
});

// Helper providers
final isAuthenticatedProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

final userTokenProvider = FutureProvider((ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  return secureStorage.getToken();
});
