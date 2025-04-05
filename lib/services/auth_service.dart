// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthService {
  static const String baseUrl = 'http://13.127.201.96:8082';
  static const int timeoutDuration = 15; // Reduced timeout duration
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Check internet connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return {
          'success': false,
          'message': 'No internet connection.\nPlease check your network settings.',
        };
      }

      // Try to connect to the server
      final response = await http.post(
        Uri.parse('$baseUrl/auth/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(
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
        'message': 'Server not responding.\nPlease try again later or contact support.',
      };
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        return {
          'success': false,
          'message': 'Unable to connect to server.\nPlease check your internet connection.',
        };
      }
      return {
        'success': false,
        'message': 'An unexpected error occurred.\nPlease try again later.',
      };
    }
  }
}

class TimeoutException implements Exception {}
