import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:regrowth_mobile/model/clinic_model.dart';
import 'package:regrowth_mobile/services/storage_service.dart';

Future<List<Clinic>> getClinicList() async {
  const String baseUrl = 'http://13.127.201.96:8082/api';
  final StorageService _storageService = StorageService();

  try {
    final credentials = await _storageService.getUserCredentials();
    final token = credentials['token'];

    if (token == null) throw Exception('Authentication token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/patients/clinic/list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Clinic.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching clinic list: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching clinic list: $e');
  }
}
