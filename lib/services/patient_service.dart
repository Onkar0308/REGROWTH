import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/ext_procedure_model.dart';
import '../model/patient_model.dart';
import 'storage_service.dart';

class PatientService {
  static const String baseUrl = 'http://13.127.201.96:8082/api';
  final StorageService _storageService = StorageService();

  Future<List<Patient>> getPatientList() async {
    try {
      // Get the auth token
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/patients/patientList?size=1000000'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final patientListJson = jsonData['content'] as List<dynamic>;
        final patientList =
            patientListJson.map((json) => Patient.fromJson(json)).toList();
        return patientList;
      } else {
        throw Exception('Error fetching patient list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching patient list: $e');
    }
  }

  // Example usage of error handling
  Future<List<Patient>> getPatientListWithErrorHandling() async {
    try {
      return await getPatientList();
    } on Exception catch (e) {
      if (e.toString().contains('Authentication token not found')) {
        // Handle authentication error
        throw Exception('Please login again');
      } else if (e.toString().contains('Failed to load patients: 401')) {
        // Handle unauthorized access
        throw Exception('Unauthorized access. Please login again');
      } else if (e.toString().contains('Failed to load patients: 403')) {
        // Handle forbidden access
        throw Exception('You don\'t have permission to access this resource');
      } else {
        // Handle other errors
        throw Exception('Something went wrong. Please try again later');
      }
    }
  }

  Future<List<ExternalProcedure>> getExternalProcedureList() async {
    try {
      // Get the auth token
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/patients/external-procedure/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final externalProcedureList =
            jsonData.map((json) => ExternalProcedure.fromJson(json)).toList();
        return externalProcedureList;
      } else {
        throw Exception(
            'Error fetching external procedure list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching external procedure list: $e');
    }
  }

  Future<bool> saveExternalProcedure(Map<String, dynamic> procedureData) async {
    try {
      // Get the auth token
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/patients/external-procedure/save'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(procedureData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // API call successful
      } else {
        throw Exception(
          'Failed to save external procedure: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error saving external procedure: $e');
    }
  }

  Future<void> deleteProcedure(int doctorId) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/patients/external-procedure/delete/$doctorId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete procedure: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting procedure: $e');
    }
  }

  Future<Patient> getPatientDetails(int patientId) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/patients/patientDetails/$patientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Patient.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load patient details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching patient details: $e');
    }
  }

  Future<void> createPatient(Map<String, dynamic> patientData) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/patients/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(patientData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error creating patient: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating patient: $e');
    }
  }

  Future<void> updatePatient(Map<String, dynamic> patientData) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/patients/update/${patientData['patientId']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(patientData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update patient: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating patient: $e');
    }
  }
}
