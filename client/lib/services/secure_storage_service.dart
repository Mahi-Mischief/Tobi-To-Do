import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';

  // Use secure storage on native platforms; fall back to SharedPreferences on web
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _save(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> saveToken(String token) async => _save(_tokenKey, token);
  Future<String?> getToken() async => _read(_tokenKey);
  Future<void> deleteToken() async => _delete(_tokenKey);

  Future<void> saveUserId(String userId) async => _save(_userIdKey, userId);
  Future<String?> getUserId() async => _read(_userIdKey);

  Future<void> saveEmail(String email) async => _save(_emailKey, email);
  Future<String?> getEmail() async => _read(_emailKey);

  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_emailKey);
    } else {
      await _secureStorage.deleteAll();
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
