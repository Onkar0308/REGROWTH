import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/procedure_model.dart';
import 'storage_service.dart';

class ProcedureService {
  static const String baseUrl = 'http://13.127.201.96:8082/api';
  final StorageService _storageService = StorageService();

  Future<List<Procedure>> getProcedureList() async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/patients/procedure/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Procedure.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load procedures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching procedures: $e');
    }
  }

  // Example method for error handling
  Future<List<Procedure>> getProcedureListWithErrorHandling() async {
    try {
      return await getProcedureList();
    } on Exception catch (e) {
      if (e.toString().contains('Authentication token not found')) {
        throw Exception('Please login again');
      } else if (e.toString().contains('Failed to load procedures: 401')) {
        throw Exception('Unauthorized access. Please login again');
      } else if (e.toString().contains('Failed to load procedures: 403')) {
        throw Exception('You don\'t have permission to access this resource');
      } else {
        throw Exception('Something went wrong. Please try again later');
      }
    }
  }

  Future<void> createProcedure({
    required int patientId,
    required String procedureDate,
    required String procedureType,
    required String procedureDetail,
    required double cashPayment,
    required double onlinePayment,
    required double totalAmount,
    required double discount,
    required double finalAmount,
    required String clinicName,
    required String cashierName,
  }) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/patients/procedure/createprocedure'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'patientId': patientId,
          'procedureDate': procedureDate,
          'procedureType': procedureType,
          'procedureDetail': procedureDetail,
          'cashPayment': cashPayment,
          'onlinePayment': onlinePayment,
          'totalAmount': totalAmount,
          'discount': discount,
          'finalAmount': finalAmount,
          'clinicName': clinicName,
          'cashierName': cashierName,
         // 'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        }),
      );
      print(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create procedure');
      }
    } catch (e) {
      print(e);
      throw Exception('Error creating procedure: $e');

    }
  }

  Future<void> updateProcedure(Map<String, dynamic> procedureData) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.patch(
        Uri.parse(
            '$baseUrl/patients/procedure/update/${procedureData['procedureId']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(procedureData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update procedure: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating procedure: $e');
    }
  }
}
