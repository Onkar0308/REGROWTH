import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/expense_model.dart';
import 'storage_service.dart';

class ExpenseService {
  static const String baseUrl = 'http://13.127.201.96:8082/api';
  final StorageService _storageService = StorageService();

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('$baseUrl/expenses/list?size=1000000'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final expenseListJson = jsonData['content'] as List<dynamic>;
        return expenseListJson.map((json) => ExpenseModel.fromJson(json)).toList();
      } else {
        throw Exception('Error fetching expenses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching expenses: $e');
    }
  }

  Future<String> addExpense(ExpenseModel expense) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/expenses/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(expense.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'] ?? '';
      } else {
        throw Exception('Failed to add expense: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding expense: $e');
    }
  }

  Future<ExpenseModel> getExpense(String id) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ExpenseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching expense: $e');
    }
  }

  Future<void> updateExpense(String id, ExpenseModel expense) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.patch(
        Uri.parse('$baseUrl/expenses/update/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(expense.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating expense: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.delete(
        Uri.parse('$baseUrl/expenses/delete/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting expense: $e');
    }
  }

  Future<List<ExpenseModel>> getExpensesWithErrorHandling() async {
    try {
      return await getExpenses();
    } on Exception catch (e) {
      if (e.toString().contains('Authentication token not found')) {
        throw Exception('Please login again');
      } else if (e.toString().contains('Failed to load expenses: 401')) {
        throw Exception('Unauthorized access. Please login again');
      } else if (e.toString().contains('Failed to load expenses: 403')) {
        throw Exception('You don\'t have permission to access this resource');
      } else {
        throw Exception('Something went wrong. Please try again later');
      }
    }
  }
}