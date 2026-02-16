import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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
    
    // Only initialize Firebase service on non-web platforms
    if (!kIsWeb) {
      firebaseAuthService = FirebaseAuthService();
    } else {
      firebaseAuthService = FirebaseAuthService(isDummy: true);
    }

    // Check if user is already logged in from storage
    await Future.delayed(const Duration(milliseconds: 500));
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
      final isWeb = kIsWeb;
      
      if (isWeb) {
        // Web platform - use backend API for auth
        debugPrint('🔄 [AUTH] Web auth: Creating user via API...');
        try {
          final response = await apiClient.post(
            '/auth/register',
            {
              'email': email,
              'password': password,
              'fullName': fullName,
            },
          );
          
          debugPrint('📥 [AUTH] API Response: $response');
          
          final token = response['token'] as String?;
          final userId = response['user']?['id'] as String? ?? response['userId'] as String?;
          
          if (token != null && userId != null) {
            await secureStorage.saveToken(token);
            await secureStorage.saveUserId(userId);
            await secureStorage.saveEmail(email);
            
            final user = app_user.User(
              id: userId,
              email: email,
              fullName: fullName,
              createdAt: DateTime.now(),
            );
            debugPrint('✅ [AUTH] Web registration successful');
            state = AsyncValue.data(user);
          } else {
            throw Exception('Invalid API response: missing token or userId. Response: $response');
          }
        } catch (e) {
          debugPrint('❌ [AUTH] API Error: $e');
          rethrow;
        }
      } else {
        // Native platform - use Firebase
        debugPrint('🔄 [AUTH] Native auth: Creating Firebase user...');
        final userCred = await firebaseAuthService.firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('✅ [AUTH] Firebase user created: ${userCred.user?.uid}');
        
        await userCred.user?.updateDisplayName(fullName);
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
      final isWeb = kIsWeb;
      
      if (isWeb) {
        // Web platform - use backend API for auth
        debugPrint('🔄 [AUTH] Web auth: Signing in via API...');
        try {
          final response = await apiClient.post(
            '/auth/login',
            {
              'email': email,
              'password': password,
            },
          );
          
          debugPrint('📥 [AUTH] API Response: $response');
          
          final token = response['token'] as String?;
          final userId = response['user']?['id'] as String? ?? response['userId'] as String?;
          final fullName = response['user']?['full_name'] as String? ?? response['fullName'] as String? ?? '';
          
          if (token != null && userId != null) {
            await secureStorage.saveToken(token);
            await secureStorage.saveUserId(userId);
            await secureStorage.saveEmail(email);
            
            final user = app_user.User(
              id: userId,
              email: email,
              fullName: fullName,
              createdAt: DateTime.now(),
            );
            debugPrint('✅ [AUTH] Web login successful');
            state = AsyncValue.data(user);
          } else {
            throw Exception('Invalid API response: missing token or userId. Response: $response');
          }
        } catch (e) {
          debugPrint('❌ [AUTH] API Error: $e');
          rethrow;
        }
      } else {
        // Native platform - use Firebase
        debugPrint('🔄 [AUTH] Native auth: Signing in with Firebase...');
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
      }
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
