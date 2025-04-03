import 'package:flutter/material.dart';

import '../../model/procedure_model.dart';
import '../../services/procedure_service.dart';
import '../../utils/contants.dart';

class EditProcedure extends StatefulWidget {
  final Procedure procedure;

  const EditProcedure({
    super.key,
    required this.procedure,
  });

  @override
  State<EditProcedure> createState() => _EditProcedureState();
}

class _EditProcedureState extends State<EditProcedure> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TextEditingController _procedureDateController;
  late TextEditingController _procedureTypeController;
  late TextEditingController _procedureDetailController;
  late TextEditingController _cashPaymentController;
  late TextEditingController _onlinePaymentController;
  late TextEditingController _discountController;
  late TextEditingController _clinicNameController;
  late TextEditingController _cashierNameController;

  double get _totalAmount {
    double cash = double.tryParse(_cashPaymentController.text) ?? 0.0;
    double online = double.tryParse(_onlinePaymentController.text) ?? 0.0;
    return cash + online;
  }

  double get _finalAmount {
    double total = _totalAmount;
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    return total - discount;
  }

  @override
  void initState() {
    super.initState();
    _procedureDateController =
        TextEditingController(text: widget.procedure.procedureDate);
    _procedureTypeController =
        TextEditingController(text: widget.procedure.procedureType);
    _procedureDetailController =
        TextEditingController(text: widget.procedure.procedureDetail);
    _cashPaymentController =
        TextEditingController(text: widget.procedure.cashPayment.toString());
    _onlinePaymentController =
        TextEditingController(text: widget.procedure.onlinePayment.toString());
    _discountController =
        TextEditingController(text: widget.procedure.discount.toString());
    _clinicNameController =
        TextEditingController(text: widget.procedure.clinicName);
    _cashierNameController =
        TextEditingController(text: widget.procedure.cashierName);
  }

  @override
  void dispose() {
    _procedureDateController.dispose();
    _procedureTypeController.dispose();
    _procedureDetailController.dispose();
    _cashPaymentController.dispose();
    _onlinePaymentController.dispose();
    _discountController.dispose();
    _clinicNameController.dispose();
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

        final procedureData = {
          "procedureId": widget.procedure.procedureId,
          "patientId": widget.procedure.patientId,
          "procedureDate": _procedureDateController.text,
          "procedureType": _procedureTypeController.text,
          "procedureDetail": _procedureDetailController.text,
          "cashPayment": double.parse(_cashPaymentController.text),
          "onlinePayment": double.parse(_onlinePaymentController.text),
          "totalAmount": _totalAmount,
          "discount": double.parse(_discountController.text),
          "finalAmount": _finalAmount,
          "clinicName": _clinicNameController.text,
          "cashierName": _cashierNameController.text
        };

        await ProcedureService().updateProcedure(procedureData);

        if (mounted) {
          _showSuccessMessage('Procedure Updated successfully');
          Navigator.pop(context, true);
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
          'Edit Procedure',
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
                    // Procedure Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Procedure Information',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Divider(),
                            _buildTextField(
                              controller: _procedureTypeController,
                              label: 'Procedure Type',
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                            _buildTextField(
                              controller: _procedureDetailController,
                              label: 'Procedure Details',
                              maxLines: 3,
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Information',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Divider(),
                            _buildTextField(
                              controller: _cashPaymentController,
                              label: 'Cash Payment',
                              keyboardType: TextInputType.number,
                              onChanged: (value) => setState(() {}),
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Required';
                                if (double.tryParse(value!) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: _onlinePaymentController,
                              label: 'Online Payment',
                              keyboardType: TextInputType.number,
                              onChanged: (value) => setState(() {}),
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Required';
                                if (double.tryParse(value!) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: _discountController,
                              label: 'Discount',
                              keyboardType: TextInputType.number,
                              onChanged: (value) => setState(() {}),
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Required';
                                if (double.tryParse(value!) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Total Amount: ₹${_totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Final Amount: ₹${_finalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Clinic Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Clinic Information',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Divider(),
                            _buildTextField(
                              controller: _clinicNameController,
                              label: 'Clinic Name',
                              validator: (value) =>
                                  value?.isEmpty == true ? 'Required' : null,
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

                    // Update Button
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
                          _isLoading ? 'Updating...' : 'Update Procedure',
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
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
