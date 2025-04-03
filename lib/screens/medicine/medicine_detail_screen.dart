import 'package:flutter/material.dart';
import 'package:regrowth_mobile/services/storage_service.dart';
import 'package:regrowth_mobile/utils/contants.dart';

import '../../model/medicine_model.dart';
import '../../services/medicine_service.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailsScreen({super.key, required this.medicine});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Medicine?',
              style: TextStyle(fontFamily: 'Lexend')),
          content: const Text('Are you sure you want to delete this medicine?',
              style: TextStyle(fontFamily: 'Lexend')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(fontFamily: 'Lexend', color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await MedicineService(StorageService())
                      .deleteMedicine(medicine.medicineId);

                  Navigator.pop(context); // Close dialog
                  Navigator.pop(
                      context, true); // Return to list with refresh flag
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting medicine: $e')),
                  );
                }
              },
              child: const Text('Delete',
                  style: TextStyle(fontFamily: 'Lexend', color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details',
            style: TextStyle(fontFamily: 'Lexend')),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.medication,
                      'Medicine Name',
                      medicine.medicineName,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.category,
                      'Type',
                      medicine.medicineType,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.inventory,
                      'Pack Size',
                      medicine.medicinePack.toString(),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.numbers,
                      'Quantity',
                      medicine.quantity.toString(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
