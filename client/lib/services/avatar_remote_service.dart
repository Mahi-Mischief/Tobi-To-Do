import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tobi_todo/models/avatar_config.dart';
import 'package:tobi_todo/services/api_client.dart';

class AvatarRemoteService {
  AvatarRemoteService() : _dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));

  final Dio _dio;

  Future<String?> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? user.getIdToken() : null;
  }

  Future<AvatarConfig?> fetch(String userId) async {
    final token = await _token();
    if (token == null) return null;

    final res = await _dio.get(
      '/avatar',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = res.data;
    if (data == null || data['config'] == null) return null;
    return AvatarConfig.fromJson(Map<String, dynamic>.from(data['config'] as Map));
  }

  Future<void> save(String userId, AvatarConfig config) async {
    final token = await _token();
    if (token == null) throw Exception('Not authenticated with Firebase');

    await _dio.put(
      '/avatar',
      data: {
        'config': config.toJson(),
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
