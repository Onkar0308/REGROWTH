import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:regrowth_mobile/utils/contants.dart';
import '../../model/medicine_model.dart';
import '../../model/patient_model.dart';
import '../../services/billing_service.dart';
import '../../services/medicine_service.dart';
import '../../services/patient_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/animated_dailog.dart';

class CreateBill extends StatefulWidget {
  const CreateBill({super.key});

  @override
  State<CreateBill> createState() => _CreateBillState();
}

class _CreateBillState extends State<CreateBill> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _medNameController = TextEditingController();
  final _medTypeController = TextEditingController();
  final _medPackController = TextEditingController();
  final _quantityController = TextEditingController();
  final _mrpController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  List<Patient> _patientSuggestions = [];
  int? _selectedPatientId;
  bool _isLoading = false;
  int? _currentBillId;
  final List<Map<String, dynamic>> _addedMedicines = [];
  double _totalAmount = 0.0;
  List<Medicine> _medicineSuggestions = [];
  int? _selectedMedicineId;

  List<MedicineInventory> _inventoryList = [];
  MedicineInventory? _selectedInventory;
  bool _medicineSelected = false;

  final PatientService _patientService = PatientService();
  final BillingService _billingService = BillingService();
  final MedicineService _medicineService = MedicineService(StorageService());

  @override
  void dispose() {
    _patientNameController.dispose();
    _medNameController.dispose();
    _medTypeController.dispose();
    _medPackController.dispose();
    _quantityController.dispose();
    _mrpController.dispose();
    super.dispose();
  }

  void _showBillSummary() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bill Summary',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(thickness: 1),

                // Patient Details
                const Text(
                  'Patient Details',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Name:',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _patientNameController.text,
                      style: const TextStyle(fontFamily: 'Lexend'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill Date:',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      DateFormat('dd-MM-yyyy').format(_selectedDate),
                      style: const TextStyle(fontFamily: 'Lexend'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Medicines List
                const Text(
                  'Medicines',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _addedMedicines.map((medicine) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  medicine['name'],
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Qty: ${medicine['quantity']}',
                                  style: const TextStyle(fontFamily: 'Lexend'),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '₹${medicine['total'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const Divider(thickness: 1),
                // Total Amount
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textblue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Print Button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      _showSuccessMessage('Bill Created successfully');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _searchPatients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _patientSuggestions = [];
      });
      return;
    }

    try {
      final patients = await _patientService.getPatientList();
      setState(() {
        _patientSuggestions = patients.where((patient) {
          final fullName =
              '${patient.firstName} ${patient.middleName} ${patient.lastName}'
                  .toLowerCase();
          return fullName.contains(query.toLowerCase());
        }).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Error searching patients: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AnimatedDialog(
          isSuccess: true,
          title: 'Success!',
          message: message,
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

  Future<void> _createInitialBill() async {
    if (_selectedPatientId == null) {
      _showErrorSnackBar('Please select a patient from the list');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final billResponse = await _billingService.createMedicalBill(
        billNumber: 0,
        billDate: _selectedDate,
        patientName: _patientNameController.text,
        totalAmount: 0.0,
        patientId: _selectedPatientId!,
      );

      setState(() {
        _currentBillId = billResponse.billId;
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchMedicines(String query) async {
    if (query.isEmpty) {
      setState(() {
        _medicineSuggestions = [];
      });
      return;
    }

    try {
      final medicines = await _medicineService.getMedicineList();
      setState(() {
        _medicineSuggestions = medicines.where((medicine) {
          return medicine.medicineName
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Error searching medicines: $e');
    }
  }

  Future<void> _addMedicine() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentBillId == null) {
      await _createInitialBill();
    }

    if (_selectedMedicineId == null || _selectedInventory == null) {
      _showErrorSnackBar('Please select a valid medicine and batch');
      return;
    }

    final quantity = int.parse(_quantityController.text);
    final mrp = double.parse(_mrpController.text);
    final totalAmount = quantity * mrp;

    setState(() => _isLoading = true);

    try {
      await _billingService.saveBillTransaction(
        medQuantity: quantity,
        medName: _medNameController.text,
        medMrp: mrp,
        medicineBatch: _selectedInventory!.medicineBatch,
        medTransactionId: _selectedInventory!.medtransactionId,
        totalAmount: totalAmount,
        billNumber: _currentBillId!,
        medicineNumber: _selectedMedicineId!,
      );

      setState(() {
        _addedMedicines.add({
          'name': _medNameController.text,
          'quantity': quantity,
          'mrp': mrp,
          'total': totalAmount,
        });
        _totalAmount += totalAmount;

        // Clear form fields
        _medNameController.clear();
        _selectedMedicineId = null;
        _selectedInventory = null;
        _medPackController.clear();
        _medTypeController.clear();
        _quantityController.clear();
        _mrpController.clear();
      });

      _showSuccessMessage('Medicine added successfully');
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      appBar: AppBar(
        title: const Text(
          'Create Bill',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.list_alt_rounded,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/bill_list');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Details Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Details',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Bill Date',
                          labelStyle: const TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.blue.shade50,
                        ),
                        child: Text(
                          DateFormat('dd-MM-yyyy').format(_selectedDate),
                          style: const TextStyle(fontFamily: 'Lexend'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<Patient>(
                      displayStringForOption: (Patient patient) =>
                          '${patient.firstName} ${patient.middleName} ${patient.lastName}',
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Patient>.empty();
                        }
                        await _searchPatients(textEditingValue.text);
                        return _patientSuggestions;
                      },
                      onSelected: (Patient patient) {
                        _patientNameController.text =
                            '${patient.firstName} ${patient.middleName} ${patient.lastName}';
                        _selectedPatientId = patient.patientId;
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Patient Name',
                            labelStyle: const TextStyle(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please select a patient'
                              : null,
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final patient = options.elementAt(index);
                                  return ListTile(
                                    title: Text(
                                      '${patient.firstName} ${patient.middleName} ${patient.lastName}',
                                      style:
                                          const TextStyle(fontFamily: 'Lexend'),
                                    ),
                                    onTap: () => onSelected(patient),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Medicine Details Section
              if (_currentBillId != null ||
                  _patientNameController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Medicine',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Autocomplete<Medicine>(
                        displayStringForOption: (Medicine medicine) =>
                            medicine.medicineName,
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Medicine>.empty();
                          }
                          await _searchMedicines(textEditingValue.text);
                          return _medicineSuggestions;
                        },
                        onSelected: (Medicine medicine) async {
                          _medicineSelected = true;
                          _medNameController.text = medicine.medicineName;
                          _selectedMedicineId = medicine.medicineId;
                          _medPackController.text =
                              medicine.medicinePack.toString();
                          _medTypeController.text = medicine.medicineType;

                          try {
                            _inventoryList = await _medicineService
                                .getMedicineInventory(medicine.medicineId);
                            if (_inventoryList.isNotEmpty) {
                              _selectedInventory = _inventoryList.first;
                              _mrpController.text =
                                  _selectedInventory!.mrp.toString();
                            }
                            setState(() {});
                          } catch (e) {
                            print('Error fetching inventory: $e');
                          }

                          _quantityController.text =
                              '1'; // Set default quantity
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Medicine Name',
                              labelStyle: const TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.medication),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please select a medicine'
                                : null,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final medicine = options.elementAt(index);
                                    return ListTile(
                                      title: Text(
                                        medicine.medicineName,
                                        style: const TextStyle(
                                            fontFamily: 'Lexend'),
                                      ),
                                      subtitle: Text(
                                        'Pack: ${medicine.medicinePack} | Type: ${medicine.medicineType}',
                                        style: const TextStyle(
                                            fontFamily: 'Lexend'),
                                      ),
                                      onTap: () => onSelected(medicine),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_medicineSelected && _inventoryList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Medicine is not available in stock',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        )
                      else if (_medicineSelected)
                        DropdownButtonFormField<MedicineInventory>(
                          items: _inventoryList.map((inventory) {
                            return DropdownMenuItem<MedicineInventory>(
                              value: inventory,
                              child: Text(
                                '${inventory.medicineBatch} (Available: ${inventory.availableQuantity})',
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (MedicineInventory? selectedInventory) {
                            if (selectedInventory != null) {
                              _selectedInventory = selectedInventory;

                              // MRP per unit calculation
                              double mrpPerUnit = selectedInventory.mrp /
                                  selectedInventory.medicinePack;

                              _mrpController.text = (mrpPerUnit *
                                      int.parse(_quantityController.text))
                                  .toStringAsFixed(2);

                              // Update MRP when quantity changes
                              _quantityController.text =
                                  '1'; // Reset or set default quantity
                              _quantityController.addListener(() {
                                int quantity =
                                    int.tryParse(_quantityController.text) ?? 1;
                                _mrpController.text =
                                    (mrpPerUnit * quantity).toStringAsFixed(2);
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Batch Number',
                            labelStyle: const TextStyle(
                              fontFamily: 'Lexend',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                          ),
                          validator: (value) =>
                              value == null ? 'Please select a batch' : null,
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                labelStyle: const TextStyle(
                                  fontFamily: 'Lexend',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.add_box_outlined),
                                filled: true,
                                fillColor: Colors.blue.shade50,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _mrpController,
                              decoration: InputDecoration(
                                labelText: 'MRP',
                                labelStyle: const TextStyle(
                                  fontFamily: 'Lexend',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.currency_rupee),
                                filled: true,
                                fillColor: Colors.blue.shade50,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_addedMedicines.isNotEmpty) ...[
                        const Text(
                          'Added Medicines',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _addedMedicines.length,
                          itemBuilder: (context, index) {
                            final medicine = _addedMedicines[index];
                            return ListTile(
                              title: Text(
                                medicine['name'],
                                style: const TextStyle(fontFamily: 'Lexend'),
                              ),
                              subtitle: Text(
                                'Qty: ${medicine['quantity']}',
                                style: const TextStyle(fontFamily: 'Lexend'),
                              ),
                              trailing: Text(
                                '₹${medicine['total'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textblue,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount:',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹${_totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textblue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _addMedicine,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttoncolor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Add Medicine',
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _addedMedicines.isEmpty
                                    ? null
                                    : _showBillSummary,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'View Bill',
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
