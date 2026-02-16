import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/models/task_model.dart';
import 'package:tobi_todo/models/user_model.dart';
import 'package:tobi_todo/services/secure_storage_service.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:5000/api';
  late Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // Add token interceptor - ADDS JWT TOKEN TO EVERY REQUEST
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _secureStorage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              debugPrint('📤 [API] Token added to headers for ${options.path}');
            }
          } catch (e) {
            debugPrint('⚠️ [API] Could not add token: $e');
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint('❌ [API] Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      // Return mock response (Firebase will handle auth separately)
      return {
        'success': true,
        'user': {
          'id': 'mock-user-id',
          'email': email,
          'full_name': fullName ?? '',
        },
        'token': 'mock-token',
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Return mock response (Firebase will handle auth separately)
      return {
        'success': true,
        'user': {
          'id': 'mock-user-id',
          'email': email,
          'full_name': '',
        },
        'token': 'mock-token',
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> firebaseLogin({
    required String firebaseUid,
    required String email,
    String? fullName,
  }) async {
    try {
      // Return mock response
      return {
        'success': true,
        'user': {
          'id': firebaseUid,
          'email': email,
          'full_name': fullName ?? '',
        },
        'token': 'mock-token',
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      // Return mock user
      return User(
        id: 'mock-user-id',
        email: 'user@example.com',
        fullName: 'Mock User',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Task endpoints
  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post(
        '/tasks',
        data: task.toJson(),
      );
      return Task.fromJson(response.data['task']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Task>> getTasks({
    String? status,
    String? priority,
  }) async {
    try {
      final response = await _dio.get(
        '/tasks',
        queryParameters: {
          if (status != null) 'status': status,
          if (priority != null) 'priority': priority,
        },
      );
      return (response.data['tasks'] as List)
          .map((t) => Task.fromJson(t))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> getTask(String taskId) async {
    try {
      final response = await _dio.get('/tasks/$taskId');
      return Task.fromJson(response.data['task']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> updateTask(String taskId, Task task) async {
    try {
      final response = await _dio.patch(
        '/tasks/$taskId',
        data: task.toJson(),
      );
      return Task.fromJson(response.data['task']);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _dio.delete('/tasks/$taskId');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/tasks/dashboard-stats');
      return response.data['stats'];
    } catch (e) {
      rethrow;
    }
  }

  // AI endpoints
  Future<Map<String, dynamic>> generateTaskBreakdown(String taskDescription) async {
    try {
      final response = await _dio.post(
        '/tasks/ai/breakdown',
        data: {'task_description': taskDescription},
      );
      return response.data['breakdown'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSmartSchedule() async {
    try {
      final response = await _dio.get('/tasks/ai/schedule');
      return response.data['schedule'];
    } catch (e) {
      rethrow;
    }
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      await _dio.get('/health');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Generic HTTP methods
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

// Provide a singleton ApiClient via Riverpod for use by providers
final apiClientProvider = Provider((ref) => ApiClient());
