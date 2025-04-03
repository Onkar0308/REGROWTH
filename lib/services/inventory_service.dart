import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/invoice_model.dart';
import '../services/storage_service.dart';

class InventoryService {
  static const String baseUrl = 'http://13.127.201.96:8082/api';
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> createInvoice(
      Map<String, dynamic> invoiceData) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/medical/inventory/createInvoice'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(invoiceData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating invoice: $e');
    }
  }

  Future<void> addInventoryTransaction(
      Map<String, dynamic> transactionData) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/medical/inventory/addInventoryTransaction'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(transactionData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to add inventory: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Medicine From Dropdown');
    }
  }

  Future<List<Invoice>> getInvoiceList() async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/medical/inventory/invoiceList?size=1000000'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final invoiceListJson = jsonData['content'] as List<dynamic>;
        return invoiceListJson.map((json) => Invoice.fromJson(json)).toList();
      } else {
        throw Exception('Error fetching invoice list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching invoice list: $e');
    }
  }

  Future<List<PurchaseDetail>> getPurchaseDetails(int invoiceId) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/medical/inventory/$invoiceId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => PurchaseDetail.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load purchase details');
      }
    } catch (e) {
      throw Exception('Error fetching purchase details: $e');
    }
  }
}
