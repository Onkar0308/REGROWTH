import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:regrowth_mobile/services/storage_service.dart';

import '../model/medicine_model.dart';

class MedicineService {
  final String baseUrl = 'http://13.127.201.96:8082/api/medical';
  final StorageService _storageService;

  MedicineService(this._storageService);

  Future<List<Medicine>> getMedicineList() async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/medicineList'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Medicine.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load medicines');
      }
    } catch (e) {
      throw Exception('Error fetching medicines: $e');
    }
  }

  Future<List<MedicineInventory>> getMedicineInventory(int medicineId) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/inventory/availableMedicines/$medicineId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => MedicineInventory.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load inventory');
      }
    } catch (e) {
      throw Exception('Error fetching inventory: $e');
    }
  }

  Future<bool> addMedicine(Medicine medicine) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/addMedicine'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'medicineName': medicine.medicineName,
          'medicinePack': medicine.medicinePack,
          'medicineType': medicine.medicineType,
          'quantity': medicine.quantity,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error adding medicine: $e');
    }
  }

  Future<Medicine> getMedicineDetails(int id) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('$baseUrl/medicineDetails/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Medicine.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load medicine details');
      }
    } catch (e) {
      throw Exception('Error fetching medicine details: $e');
    }
  }

  Future<bool> deleteMedicine(int id) async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.delete(
        Uri.parse('$baseUrl/deleteMedicine/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting medicine: $e');
    }
  }

  Future<List<LowStockMedicine>> getLowStockMedicines() async {
    try {
      final credentials = await _storageService.getUserCredentials();
      final token = credentials['token'];

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/medicines/low-stock'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => LowStockMedicine.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load low stock medicines');
      }
    } catch (e) {
      throw Exception('Error fetching low stock medicines: $e');
    }
  }
}
