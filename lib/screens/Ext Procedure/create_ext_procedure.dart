import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:regrowth_mobile/services/storage_service.dart';

import '../../provider/refresh_provider.dart';
import '../../services/patient_service.dart';
import '../../utils/contants.dart';

class CreateExtProcedure extends StatefulWidget {
  const CreateExtProcedure({super.key});

  @override
  State<CreateExtProcedure> createState() => _CreateExtProcedureState();
}

class _CreateExtProcedureState extends State<CreateExtProcedure> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController procedureDateController = TextEditingController();
  final TextEditingController procedureTypeController = TextEditingController();
  final TextEditingController procedureDetailController =
      TextEditingController();
  final TextEditingController feesChargedController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController finalAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to update the final amount whenever fees or discount changes
    feesChargedController.addListener(_updateFinalAmount);
    discountController.addListener(_updateFinalAmount);
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    doctorNameController.dispose();
    procedureDateController.dispose();
    procedureTypeController.dispose();
    procedureDetailController.dispose();
    feesChargedController.dispose();
    discountController.dispose();
    finalAmountController.dispose();
    super.dispose();
  }

  void _updateFinalAmount() {
    final feesCharged = double.tryParse(feesChargedController.text) ?? 0.0;
    final discount = double.tryParse(discountController.text) ?? 0.0;
    final calculatedFinalAmount = feesCharged - discount;

    finalAmountController.text = calculatedFinalAmount.toStringAsFixed(2);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final storageService = StorageService();
      final userCredentials = await storageService.getUserCredentials();
      final username = userCredentials['username'] ?? 'Unknown';

      // Collect form data
      final procedureData = {
        "doctorName": doctorNameController.text,
        "procedureDate": procedureDateController.text,
        "procedureType": procedureTypeController.text,
        "procedureDetail": procedureDetailController.text,
        "feesCharged": double.tryParse(feesChargedController.text) ?? 0.0,
        "discount": double.tryParse(discountController.text) ?? 0.0,
        "finalAmount": double.tryParse(finalAmountController.text) ?? 0.0,
        "cashierName": username,
      };

      try {
        final isSaved =
            await PatientService().saveExternalProcedure(procedureData);

        if (isSaved) {
          context.read<RefreshStateNotifier>().refresh();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('External procedure created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, true); // Return to the previous screen
        } else {
          throw Exception('Failed to save external procedure.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create external procedure: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Format the selected date and update the controller
        procedureDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
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
          readOnly: readOnly,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '$label is required';
            }
            return null;
          },
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'External Procedures',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              _buildInputField(
                controller: doctorNameController,
                label: 'Doctor Name',
                isRequired: true,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                    title: Text(
                      'Procedure Date: ${procedureDateController.text.isEmpty ? '\nSelect a date' : procedureDateController.text}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
              ),
              _buildInputField(
                controller: procedureTypeController,
                label: 'Procedure Type',
                isRequired: true,
              ),
              _buildInputField(
                controller: procedureDetailController,
                label: 'Procedure Detail',
                isRequired: true,
              ),
              _buildInputField(
                controller: feesChargedController,
                label: 'Fees Charged',
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              _buildInputField(
                controller: discountController,
                label: 'Discount',
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              _buildInputField(
                controller: finalAmountController,
                label: 'Final Amount',
                isRequired: true,
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.buttoncolor,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          )
                        : const Text(
                            'Create Procedure',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
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
