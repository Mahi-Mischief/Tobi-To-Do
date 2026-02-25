import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tobi_todo/models/avatar_config.dart';

class AvatarRemoteService {
  AvatarRemoteService(this._client);

  final SupabaseClient _client;

  Future<AvatarConfig?> fetch(String userId) async {
    final res = await _client
        .from('avatar_profiles')
        .select('config')
        .eq('user_id', userId)
        .maybeSingle();
    if (res == null || res['config'] == null) return null;
    return AvatarConfig.fromJson(Map<String, dynamic>.from(res['config'] as Map));
  }

  Future<void> save(String userId, AvatarConfig config) async {
    await _client.from('avatar_profiles').upsert({
      'user_id': userId,
      'config': config.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
