import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/patient_model.dart';
import '../../provider/refresh_provider.dart';
import '../../services/patient_service.dart';
import '../../utils/contants.dart';

class EditPatient extends StatefulWidget {
  final Patient patient;

  const EditPatient({
    super.key,
    required this.patient,
  });

  @override
  State<EditPatient> createState() => _EditPatientState();
}

class _EditPatientState extends State<EditPatient> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _mobile1Controller;
  late TextEditingController _mobile2Controller;
  late TextEditingController _medicalHistoryController;
  late TextEditingController _reportsController;
  late String _selectedGender;
  late TextEditingController _regDateController;
  late TextEditingController _cashierNameController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing patient data
    _firstNameController =
        TextEditingController(text: widget.patient.firstName);
    _middleNameController =
        TextEditingController(text: widget.patient.middleName);
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    _ageController =
        TextEditingController(text: widget.patient.patientAge.toString());
    _mobile1Controller =
        TextEditingController(text: widget.patient.patientMobile1.toString());
    _mobile2Controller =
        TextEditingController(text: widget.patient.patientMobile2.toString());
    _medicalHistoryController =
        TextEditingController(text: widget.patient.patientMedicalHistory);
    _reportsController =
        TextEditingController(text: widget.patient.patientReports);
    _selectedGender = widget.patient.patientGender;
    _regDateController =
        TextEditingController(text: widget.patient.patientRegDate);
    _cashierNameController =
        TextEditingController(text: widget.patient.cashierName);
  }

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
    _regDateController.dispose();
    _cashierNameController.dispose();
    super.dispose();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Lexend',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        final patientData = {
          "patientId": widget.patient.patientId,
          "firstName": _firstNameController.text,
          "middleName": _middleNameController.text,
          "lastName": _lastNameController.text,
          "patientAge": int.parse(_ageController.text),
          "patientGender": _selectedGender,
          "patientRegDate": _regDateController.text,
          "patientMobile1": int.parse(_mobile1Controller.text),
          "patientMobile2": int.parse(_mobile2Controller.text),
          "patientMedicalHistory": _medicalHistoryController.text,
          "cashierName": _cashierNameController.text,
          "patientReports": _reportsController.text,
        };

        await PatientService().updatePatient(patientData);

        if (mounted) {
          _showSuccessMessage('Profile Updated successfully');
          context.read<RefreshStateNotifier>().refresh();
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(e.toString());
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Patient',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Divider(),
                            _buildTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                            _buildTextField(
                              controller: _middleNameController,
                              label: 'Middle Name',
                            ),
                            _buildTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                            _buildTextField(
                              controller: _ageController,
                              label: 'Age',
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                            _buildGenderDropdown(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Divider(),
                            _buildTextField(
                              controller: _mobile1Controller,
                              label: 'Primary Mobile',
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                            _buildTextField(
                              controller: _mobile2Controller,
                              label: 'Secondary Mobile',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Medical Information',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Divider(),
                            _buildTextField(
                              controller: _medicalHistoryController,
                              label: 'Medical History',
                              maxLines: 3,
                            ),
                            _buildTextField(
                              controller: _reportsController,
                              label: 'Reports',
                            ),
                            _buildTextField(
                              controller: _cashierNameController,
                              label: 'Cashier Name',
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttoncolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitForm,
                        child: Text(
                          _isLoading ? 'Updating...' : 'Update Patient',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Lexend',
                            color: Colors.white,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Lexend'),
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        items: ['Male', 'Female', 'Other']
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedGender = value);
          }
        },
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }
}
