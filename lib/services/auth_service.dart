// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://13.127.201.96:8082';
  static const int timeoutDuration = 25;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      )
          .timeout(
        const Duration(seconds: timeoutDuration),
        onTimeout: () {
          throw TimeoutException();
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        final errorMessage = response.body.contains('Access Denied')
            ? 'Invalid username or password'
            : 'Authentication failed';
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Unable to Reach Server. \nPlease contact support team.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection Error. \nPlease check your internet connection.',
      };
    }
  }
}

class TimeoutException implements Exception {}
