import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/bill_model.dart';
import '../services/storage_service.dart';

class BillingService {
  static const String baseUrl = 'http://13.127.201.96:8082/api';
  final StorageService _storageService = StorageService();

  // Create medical bill
  Future<BillResponse> createMedicalBill({
    required int billNumber,
    required DateTime billDate,
    required String patientName,
    required double totalAmount,
    required int patientId,
  }) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/medical/bill/createMedicalBill'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'billNumber': billNumber,
          'billDate': DateFormat('dd-MM-yyyy').format(billDate),
          'patientName': patientName,
          'totalAmount': totalAmount,
          'patientId': patientId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return BillResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to create bill: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating medical bill: $e');
    }
  }

  Future<bool> saveBillTransaction({
    required int medQuantity,
    required String medName,
    required double medMrp,
    required String medicineBatch,
    required int medTransactionId,
    required double totalAmount,
    required int billNumber,
    required int medicineNumber,
  }) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/medical/bill/saveBillTransaction'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'medQuantity': medQuantity,
          'medName': medName,
          'medMrp': medMrp,
          'medicineBatch': medicineBatch,
          'medtransactionId': medTransactionId,
          'totalAmount': totalAmount,
          'billNumber': billNumber,
          'medicineNumber': medicineNumber,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to save transaction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving bill transaction: $e');
    }
  }

  Future<List<MedicalBill>> getBillList() async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/medical/bill/medicalBillsList'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> content = jsonResponse['content'];
        return content.map((json) => MedicalBill.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch bills: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bills: $e');
    }
  }

  // Get bill by ID
  Future<MedicalBill> getBillById(int billId) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/medical/bill/$billId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MedicalBill.fromJson(jsonData);
      } else {
        throw Exception('Error fetching bill: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bill: $e');
    }
  }

  // Delete bill
  Future<bool> deleteBill(int billId) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/medical/bill/deleteMedicalBill/$billId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error deleting bill: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting bill: $e');
    }
  }

  Future<List<MedicineDetail>> getMedicineDetails(int billId) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/medical/bill/$billId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => MedicineDetail.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Medicine Details not found');
      } else {
        throw Exception(
            'Error fetching medicine details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching medicine details: $e');
    }
  }
}
