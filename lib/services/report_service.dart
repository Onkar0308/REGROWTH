import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/report_model.dart';
import 'storage_service.dart';

class ReportService {
  static const String baseUrl = 'http://13.127.201.96:8082/api';
  final StorageService _storageService = StorageService();

  Future<List<Report>> getReports({
    required String fromDate,
    required String toDate,
    required String session,
  }) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/patients/reports/bysession?fromDate=$fromDate&toDate=$toDate&session=$session'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception('Error fetching reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }
}
