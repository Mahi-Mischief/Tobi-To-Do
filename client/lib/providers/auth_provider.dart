import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/models/user_model.dart' as app_user;
import 'package:tobi_todo/services/api_client.dart';
import 'package:tobi_todo/services/secure_storage_service.dart';
import 'package:tobi_todo/services/firebase_auth_service.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final secureStorageProvider = Provider((ref) => SecureStorageService());

final firebaseAuthServiceProvider = Provider((ref) => FirebaseAuthService());

// Firebase Auth State - Watches Firebase authentication changes
final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  return firebaseAuthService.authStateChanges;
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<app_user.User?>> {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;

  AuthNotifier({
    required this.apiClient,
    required this.secureStorage,
  }) : super(const AsyncValue.loading());

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await apiClient.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      final token = result['token'] as String;
      final user = app_user.User.fromJson(result['user']);
      
      await secureStorage.saveToken(token);
      await secureStorage.saveUserId(user.id);
      await secureStorage.saveEmail(user.email);
      
      state = AsyncValue.data(user);
    } catch (e, _) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await apiClient.login(
        email: email,
        password: password,
      );
      
      final token = result['token'] as String;
      final user = app_user.User.fromJson(result['user']);
      
      await secureStorage.saveToken(token);
      await secureStorage.saveUserId(user.id);
      await secureStorage.saveEmail(user.email);
      
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> firebaseLogin({
    required String firebaseUid,
    required String email,
    String? fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await apiClient.firebaseLogin(
        firebaseUid: firebaseUid,
        email: email,
        fullName: fullName,
      );
      
      final token = result['token'] as String;
      final user = app_user.User.fromJson(result['user']);
      
      await secureStorage.saveToken(token);
      await secureStorage.saveUserId(user.id);
      await secureStorage.saveEmail(user.email);
      
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await secureStorage.clearAll();
    state = const AsyncValue.data(null);
  }

  Future<void> checkAuthStatus() async {
    state = const AsyncValue.loading();
    try {
      final hasToken = await secureStorage.hasToken();
      if (hasToken) {
        final user = await apiClient.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, _) {
      state = const AsyncValue.data(null);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<app_user.User?>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  
  return AuthNotifier(
    apiClient: apiClient,
    secureStorage: secureStorage,
  );
});

// Check if user is authenticated
final isAuthenticatedProvider = Provider((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

// Get current user token
final userTokenProvider = FutureProvider((ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  return secureStorage.getToken();
});
