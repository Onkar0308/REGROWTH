import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/procedure_service.dart';
import '../../services/storage_service.dart';
import '../../utils/contants.dart';
import '../../widgets/animated_dailog.dart';


class CreateProcedureScreen extends StatefulWidget {
  final int patientId;

  const CreateProcedureScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<CreateProcedureScreen> createState() => _CreateProcedureScreenState();
}

class _CreateProcedureScreenState extends State<CreateProcedureScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProcedureService _procedureService = ProcedureService();
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _procedureTypeController =
  TextEditingController();
  final TextEditingController _procedureDetailController =
  TextEditingController();
  final TextEditingController _cashPaymentController =
  TextEditingController(text: '0');
  final TextEditingController _onlinePaymentController =
  TextEditingController(text: '0');
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _clinicNameController = TextEditingController();

  final FocusNode _cashPaymentFocusNode = FocusNode();
  final FocusNode _onlinePaymentFocusNode = FocusNode();

  bool _isLoading = false;
  double _totalAmount = 0;
  double _finalAmount = 0;

  @override
  void initState() {
    super.initState();
    _cashPaymentController.addListener(_updateTotals);
    _onlinePaymentController.addListener(_updateTotals);
    _discountController.addListener(_updateTotals);

    _cashPaymentFocusNode.addListener(() {
      if (!_cashPaymentFocusNode.hasFocus && _cashPaymentController.text.isEmpty) {
        _cashPaymentController.text = '0';  // Set to '0' when focus is lost
      }
    });

    _onlinePaymentFocusNode.addListener(() {
      if (!_onlinePaymentFocusNode.hasFocus && _onlinePaymentController.text.isEmpty) {
        _onlinePaymentController.text = '0';  // Set to '0' when focus is lost
      }
    });
  }

  void _updateTotals() {
    final cashPayment = double.tryParse(_cashPaymentController.text) ?? 0;
    final onlinePayment = double.tryParse(_onlinePaymentController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;

    setState(() {
      _totalAmount = cashPayment + onlinePayment;
      _finalAmount = _totalAmount - discount;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
          message: 'Procedure Created successfully',
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

  Future<void> _submitProcedure() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final storageService = StorageService();
      final userCredentials = await storageService.getUserCredentials();
      final username = userCredentials['username'] ?? 'Unknown';

      await _procedureService.createProcedure(
        patientId: widget.patientId,
        procedureDate: DateFormat('dd-MM-yyyy').format(_selectedDate),
        procedureType: _procedureTypeController.text,
        procedureDetail: _procedureDetailController.text,
        cashPayment: double.parse(_cashPaymentController.text),
        onlinePayment: double.parse(_onlinePaymentController.text),
        totalAmount: _totalAmount,
        discount: _discountController.text.isEmpty
            ? 0
            : double.parse(_discountController.text),
        finalAmount: _finalAmount,
        clinicName: _clinicNameController.text,
        cashierName: username,
      );

      Navigator.pop(context, true);
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontFamily: 'Lexend',
          ),
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            border: InputBorder.none,
            labelStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
            ),
          ),
          validator: validator ??
              (isRequired
                  ? (value) => value?.isEmpty ?? true ? 'Required field' : null
                  : null),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Procedure',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFEDEDED),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                  title: const Text(
                    'Procedure Date *',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
              ),
            ),
            _buildFormField(
              controller: _procedureTypeController,
              label: 'Procedure Type',
              isRequired: true,
            ),
            _buildFormField(
              controller: _procedureDetailController,
              label: 'Procedure Details',
              isRequired: true,
              maxLines: 3,
            ),
            _buildFormField(
              controller: _cashPaymentController,
              label: 'Cash Payment',
              isRequired: false,
              keyboardType: TextInputType.number,
            ),
            _buildFormField(
              controller: _onlinePaymentController,
              label: 'Online Payment',
              isRequired: false,
              keyboardType: TextInputType.number,
            ),
            _buildFormField(
              controller: _discountController,
              label: 'Discount',
              keyboardType: TextInputType.number,
            ),
            _buildFormField(
              controller: _clinicNameController,
              label: 'Clinic Name',
              isRequired: true,
            ),
            const SizedBox(height: 24),
            // Summary Card
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFEDEDED),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total Amount: ₹${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Final Amount: ₹${_finalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                height: 50,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttoncolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitProcedure,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Create Procedure',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _procedureTypeController.dispose();
    _procedureDetailController.dispose();
    _cashPaymentController.dispose();
    _onlinePaymentController.dispose();
    _discountController.dispose();
    _clinicNameController.dispose();

    super.dispose();
  }
}
