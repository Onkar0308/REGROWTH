import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/expense_model.dart';
import 'auth_service.dart';

class ExpenseService {
  static const String _baseUrl = AuthService.baseUrl;
  static const int timeoutDuration = AuthService.timeoutDuration;

  Future<String> addExpense(ExpenseModel expense) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expense.toJson()),
      ).timeout(
        const Duration(seconds: timeoutDuration),
        onTimeout: () {
          throw TimeoutException();
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        throw Exception('Failed to add expense: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Server not responding. Please try again later.');
      }
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/expenses'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: timeoutDuration),
        onTimeout: () {
          throw TimeoutException();
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ExpenseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch expenses: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Server not responding. Please try again later.');
      }
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  Future<ExpenseModel> getExpense(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/expenses/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: timeoutDuration),
        onTimeout: () {
          throw TimeoutException();
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ExpenseModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch expense: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Server not responding. Please try again later.');
      }
      throw Exception('Failed to fetch expense: $e');
    }
  }

  Future<void> updateExpense(String id, ExpenseModel expense) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/expenses/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expense.toJson()),
      ).timeout(
        const Duration(seconds: timeoutDuration),
        onTimeout: () {
          throw TimeoutException();
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update expense: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Server not responding. Please try again later.');
      }
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/expenses/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: timeoutDuration),
        onTimeout: () {
          throw TimeoutException();
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Server not responding. Please try again later.');
      }
      throw Exception('Failed to delete expense: $e');
    }
  }
}