import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:regrowth_mobile/services/storage_service.dart';

import '../model/appointment_model.dart';

Future<List<Appointment>> getAppointmentList() async {
  const String baseUrl = 'http://13.127.201.96:8082/api';
  final StorageService _storageService = StorageService();

  try {
    final credentials = await _storageService.getUserCredentials();
    final token = credentials['token'];

    if (token == null) throw Exception('Authentication token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/appointments/list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching appointments: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching appointments: $e');
  }
}

Future<Appointment> getAppointmentDetails(int appointmentId) async {
  const String baseUrl = 'http://15.207.44.219:8082/api';
  final StorageService _storageService = StorageService();

  try {
    final credentials = await _storageService.getUserCredentials();
    final token = credentials['token'];

    if (token == null) throw Exception('Authentication token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/appointments/details/$appointmentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Appointment.fromJson(jsonData);
    } else {
      throw Exception(
          'Error fetching appointment details: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching appointment details: $e');
  }
}

Future<Appointment> editAppointment(
    int appointmentId, Appointment appointment) async {
  const String baseUrl = 'http://15.207.44.219:8082/api';
  final StorageService _storageService = StorageService();

  try {
    final credentials = await _storageService.getUserCredentials();
    final token = credentials['token'];

    if (token == null) throw Exception('Authentication token not found');

    // Prepare the body map for the PATCH request
    final Map<String, dynamic> body = {
      "appointmentId": appointmentId,
      "firstName": appointment.firstName,
      "middleName": appointment.middleName ?? '',
      "lastName": appointment.lastName,
      "treatment": appointment.treatment,
      "startTime": appointment.startTime,
      "appointmentDate": appointment.appointmentDate,
      "patientmobile1": appointment.patientMobile == 0
          ? null
          : appointment.patientMobile.toString(),
      "cashiername": appointment.cashierName,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/edit/$appointmentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Appointment.fromJson(jsonData);
    } else {
      throw Exception(
          'Error editing appointment: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    throw Exception('Error editing appointment: $e');
  }
}

class AppointmentService {
  Future<bool> deleteAppointment(int appointmentId) async {
    const String baseUrl = 'http://15.207.44.219:8082/api';
    final StorageService _storageService = StorageService();

    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.delete(
        Uri.parse('$baseUrl/appointments/delete/$appointmentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error deleting appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
    }
  }

  Future<Appointment> createAppointment(Appointment appointment) async {
    const String baseUrl = 'http://15.207.44.219:8082/api';
    final StorageService _storageService = StorageService();

    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      // Convert the appointment object to a map for the API body
      final Map<String, dynamic> body = {
        "firstName": appointment.firstName,
        "middleName": appointment.middleName ?? '',
        "lastName": appointment.lastName,
        "treatment": appointment.treatment,
        "startTime": appointment.startTime,
        "appointmentDate": appointment.appointmentDate,
        "patientmobile1": appointment.patientMobile == 0
            ? null
            : appointment.patientMobile.toString(),
        "cashiername": appointment.cashierName,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/appointments/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Appointment.fromJson(jsonData);
      } else {
        throw Exception(
            'Error creating appointment: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating appointment: $e');
    }
  }
}
