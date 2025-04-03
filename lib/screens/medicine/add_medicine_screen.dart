import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:regrowth_mobile/provider/refresh_provider.dart';
import 'package:regrowth_mobile/utils/contants.dart';

import '../../model/medicine_model.dart';
import '../../services/medicine_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/animated_dailog.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final MedicineService _medicineService = MedicineService(StorageService());
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _packController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _typeController = TextEditingController();

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AnimatedDialog(
          isSuccess: true,
          title: 'Success!',
          message: 'Medicine added successfully',
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AnimatedDialog(
          isSuccess: false,
          title: 'Error',
          message: error,
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final medicine = Medicine(
          medicineId: 0,
          medicineName: _nameController.text,
          medicinePack: int.parse(_packController.text),
          medicineType: _typeController.text,
          quantity: double.parse(_quantityController.text),
        );

        await _medicineService.addMedicine(medicine);
        context.read<RefreshStateNotifier>().refresh();
        _showSuccessDialog();
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Medicine',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  prefixIcon:
                      Icon(Icons.medication, color: Colors.blue.shade700),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter medicine name'
                    : null,
                style: const TextStyle(fontFamily: 'Lexend'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Medicine Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  prefixIcon: Icon(Icons.category, color: Colors.blue.shade700),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  hintText: 'Enter medicine type',
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter medicine type'
                    : null,
                style: const TextStyle(fontFamily: 'Lexend'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _packController,
                decoration: InputDecoration(
                  labelText: 'Medicine Pack',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  prefixIcon:
                      Icon(Icons.inventory, color: Colors.blue.shade700),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter pack size' : null,
                style: const TextStyle(fontFamily: 'Lexend'),
              ),
              const SizedBox(height: 16),

              //hidden quantity field
              // TextFormField(
              //   controller: _quantityController,
              //   decoration: InputDecoration(
              //     labelText: 'Quantity',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //       borderSide: BorderSide(color: Colors.blue.shade200),
              //     ),
              //     prefixIcon: Icon(Icons.numbers, color: Colors.blue.shade700),
              //     filled: true,
              //     fillColor: Colors.blue.shade50,
              //   ),
              //   keyboardType: TextInputType.number,
              //   validator: (value) =>
              //       value?.isEmpty ?? true ? 'Please enter quantity' : null,
              //   style: const TextStyle(fontFamily: 'Lexend'),
              // ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttoncolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.black)
                      : const Text(
                          'Add Medicine',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
