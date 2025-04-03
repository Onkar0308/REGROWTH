import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:regrowth_mobile/provider/refresh_provider.dart';
import 'package:regrowth_mobile/utils/contants.dart';

import '../../services/patient_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/animated_dailog.dart';

class AddNewPatient extends StatefulWidget {
  const AddNewPatient({super.key});

  @override
  State<AddNewPatient> createState() => _AddNewPatientState();
}

class _AddNewPatientState extends State<AddNewPatient> {
  final _formKey = GlobalKey<FormState>();
  final PatientService _patientService = PatientService();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobile1Controller = TextEditingController();
  final _mobile2Controller = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  final _reportsController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _mobile1Controller.dispose();
    _mobile2Controller.dispose();
    _medicalHistoryController.dispose();

    _reportsController.dispose();
    super.dispose();
  }

  String capitalizeText(String text) {
    if (text.isEmpty) return text;

    // Split the text into words and capitalize each word
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() +
          (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).join(' ');
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    // Custom validator for mobile numbers
    String? mobileValidator(String? value) {
      if (isRequired && (value == null || value.isEmpty)) {
        return 'Required field';
      }
      if (value != null && value.isNotEmpty) {
        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
          return 'Please enter a valid 10-digit mobile number';
        }
      }
      return null;
    }

    // Default validator for other fields
    String? defaultValidator(String? value) {
      if (isRequired && (value == null || value.isEmpty)) {
        return 'Required field';
      }
      return null;
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFEDEDED),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            final capitalizedText = capitalizeText(value);
            if (value != capitalizedText) {
              controller.value = controller.value.copyWith(
                text: capitalizedText,
                selection:
                    TextSelection.collapsed(offset: capitalizedText.length),
              );
            }
          },
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontFamily: 'Lexend',
          ),
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            border: InputBorder.none,
            labelStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
            ),
          ),
          validator: validator ??
              (label.toLowerCase().contains('mobile')
                  ? mobileValidator
                  : defaultValidator),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        print(_selectedDate);
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AnimatedDialog(
          isSuccess: true,
          title: 'Success!',
          message: 'Patient added successfully',
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final storageService = StorageService();
        final userCredentials = await storageService.getUserCredentials();
        final username = userCredentials['username'] ?? 'Unknown';
        
        final formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);

        final patientData = {
          "firstName": _firstNameController.text,
          "middleName": _middleNameController.text,
          "lastName": _lastNameController.text,
          "patientAge": int.parse(_ageController.text),
          "patientGender": _selectedGender,
          "patientRegDate": formattedDate,  // Use the correctly formatted date
          "patientMobile1": int.parse(_mobile1Controller.text),
          "patientMobile2": _mobile2Controller.text.isEmpty
              ? 0
              : int.parse(_mobile2Controller.text),
          "patientMedicalHistory": _medicalHistoryController.text,
          "cashierName": username,
          "patientReports": _reportsController.text,
        };

        await _patientService.createPatient(patientData);
        context.read<RefreshStateNotifier>().refresh();
        _showSuccessDialog();
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Patient",
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        controller: _firstNameController,
                        label: 'First Name',
                        isRequired: true,
                      ),
                      _buildFormField(
                        controller: _middleNameController,
                        label: 'Middle Name',
                      ),
                      _buildFormField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        isRequired: true,
                      ),
                      _buildFormField(
                        controller: _ageController,
                        label: 'Age',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromRGBO(237, 237, 237, 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender *',
                                border: InputBorder.none,
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              items: ['Male', 'Female', 'Other']
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromRGBO(237, 237, 237, 1),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 28),
                            title: Text(
                              'Registration Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                        ),
                      ),
                      _buildFormField(
                        controller: _mobile1Controller,
                        label: 'Mobile 1',
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildFormField(
                        controller: _mobile2Controller,
                        label: 'Mobile 2',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildFormField(
                        controller: _medicalHistoryController,
                        label: 'Medical History',
                        maxLines: 3,
                      ),
                      _buildFormField(
                        controller: _reportsController,
                        label: 'Reports URL',
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          height: 50,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: AppColors.buttoncolor,
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
