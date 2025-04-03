// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyUsername = 'username';
  static const String keyToken = 'jwt_token';
  static const String keyRole = 'role';
  static const String keyPassword = 'password';

  Future<void> saveUserCredentials(
      String username, String token, String role, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUsername, username);
    await prefs.setString(keyToken, token);
    await prefs.setString(keyRole, role);
    await prefs.setString(keyPassword, password); // Save password
  }

  Future<Map<String, String?>> getUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(keyUsername),
      'token': prefs.getString(keyToken),
      'role': prefs.getString(keyRole),
      'password': prefs.getString(keyPassword), // Include password
    };
  }

  Future<void> clearUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUsername);
    await prefs.remove(keyToken);
    await prefs.remove(keyRole);
    await prefs.remove(keyPassword); // Clear password
  }
}
