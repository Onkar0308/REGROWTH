import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/medicine_model.dart';
import '../../services/inventory_service.dart';
import '../../services/medicine_service.dart';
import '../../services/storage_service.dart';
import '../../utils/contants.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();

  final _medicineNameController = TextEditingController();
  final _medicineBatchController = TextEditingController();
  final _medicinePackController = TextEditingController();
  final _quantityController = TextEditingController();
  final _mrpController = TextEditingController();
  final _rateController = TextEditingController();
  final MedicineService _medicineService = MedicineService(StorageService());

  DateTime _selectedDate = DateTime.now();
  DateTime _expiryDate = DateTime.now();
  final InventoryService _inventoryService = InventoryService();
  bool _isLoading = false;
  int? _currentInvoiceId;
  int? _selectedMedicineId;
  List<Medicine> _medicineSuggestions = [];
  List<Map<String, dynamic>> _addedItems = [];
  double _totalInventoryAmount = 0.0;

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _vendorNameController.dispose();

    _medicineNameController.dispose();
    _medicineBatchController.dispose();
    _medicinePackController.dispose();
    _quantityController.dispose();
    _mrpController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isExpiry) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpiry ? _expiryDate : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          _expiryDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(fontFamily: 'Lexend'),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final invoice = {
        "inoviceNumber": _invoiceNumberController.text,
        "purchaseDate": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "vendorName": _vendorNameController.text,
        "totalAmount": 0.0,
      };

      final invoiceResponse = await _inventoryService.createInvoice(invoice);
      setState(() => _currentInvoiceId = invoiceResponse['invoiceId']);
      _showMessage('Invoice created successfully');
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchMedicines(String query) async {
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
      _showMessage('Error searching medicines: $e', isError: true);
    }
  }

  Future<void> _addInventoryTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentInvoiceId == null) {
      await _submitInvoice();
      if (_currentInvoiceId == null) return;
    }

    final quantity = int.parse(_quantityController.text);
    final rate = double.parse(_rateController.text);
    final amount = quantity * rate;

    setState(() => _isLoading = true);

    try {
      final transaction = {
        "medicineName": _medicineNameController.text,
        "medicineId": _selectedMedicineId,
        "invoiceId": _currentInvoiceId,
        "medicineBatch": _medicineBatchController.text,
        "expiry": DateFormat('yyyy-MM-dd').format(_expiryDate),
        "medicinePack": int.parse(_medicinePackController.text),
        "quantity": quantity,
        "mrp": double.parse(_mrpController.text),
        "rate": rate,
        "amount": double.parse(_quantityController.text) *
            double.parse(_rateController.text)
      };

      await _inventoryService.addInventoryTransaction(transaction);

      setState(() {
        _addedItems.add({
          'name': _medicineNameController.text,
          'batch': _medicineBatchController.text,
          'quantity': quantity,
          'rate': rate,
          'amount': amount,
        });
        _totalInventoryAmount += amount;
      });

      _showMessage('Inventory added successfully');
      _clearTransactionForm();
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearTransactionForm() {
    _medicineNameController.clear();
    _medicineBatchController.clear();
    _medicinePackController.clear();
    _quantityController.clear();
    _mrpController.clear();
    _rateController.clear();
    _selectedMedicineId = null;
  }

  Widget _buildAddedItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_addedItems.isNotEmpty) ...[
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
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Added Items',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _addedItems.length,
                  itemBuilder: (context, index) {
                    final item = _addedItems[index];
                    return Card(
                      elevation: 0,
                      color: Colors.blue.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${item['amount'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textblue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batch: ${item['batch']}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Qty: ${item['quantity']} × ₹${item['rate']}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 24),
                Row(
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
                      '₹${_totalInventoryAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textblue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Invoice Summary',
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

                // Invoice Details
                const Text(
                  'Invoice Details',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                    'Invoice Number:', _invoiceNumberController.text),
                _buildSummaryRow('Vendor:', _vendorNameController.text),
                _buildSummaryRow(
                    'Date:', DateFormat('dd MMM yyyy').format(_selectedDate)),

                const SizedBox(height: 16),
                // Items List
                const Text(
                  'Items',
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
                      children: _addedItems
                          .map((item) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: const TextStyle(
                                              fontFamily: 'Lexend',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Batch: ${item['batch']}',
                                            style: TextStyle(
                                              fontFamily: 'Lexend',
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Qty: ${item['quantity']}',
                                        style: const TextStyle(
                                            fontFamily: 'Lexend'),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '₹${item['amount'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                const Divider(thickness: 1),
                // Total
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
                        '₹${_totalInventoryAmount.toStringAsFixed(2)}',
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
                      _showMessage('Invoice created successfully');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Complete Invoice',
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Lexend',
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontFamily: 'Lexend'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management',
            style: TextStyle(fontFamily: 'Lexend')),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice Details Section
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
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoice Details',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _invoiceNumberController,
                      decoration: _buildInputDecoration(
                          'Invoice Number', Icons.receipt),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vendorNameController,
                      decoration:
                          _buildInputDecoration('Vendor Name', Icons.store),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: _buildInputDecoration(
                            'Purchase Date', Icons.calendar_today),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(fontFamily: 'Lexend'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Inventory Details Section
              if (_currentInvoiceId != null)
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
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inventory Details',
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
                        onSelected: (Medicine medicine) {
                          _medicineNameController.text = medicine.medicineName;
                          _selectedMedicineId = medicine.medicineId;
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: _buildInputDecoration(
                              'Medicine Name',
                              Icons.medication,
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
                                width: MediaQuery.of(context).size.width * 0.8,
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
                      TextFormField(
                        controller: _medicineBatchController,
                        decoration: _buildInputDecoration(
                            'Batch Number', Icons.add_box_outlined),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: _buildInputDecoration(
                              'Expiry Date', Icons.calendar_today),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(_expiryDate),
                            style: const TextStyle(fontFamily: 'Lexend'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _medicinePackController,
                              decoration: _buildInputDecoration(
                                  'Pack', Icons.inventory),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: _buildInputDecoration(
                                  'Quantity', Icons.production_quantity_limits),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _mrpController,
                              decoration: _buildInputDecoration(
                                  'MRP', Icons.currency_rupee),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _rateController,
                              decoration: _buildInputDecoration(
                                  'Rate', Icons.price_change),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              if (_currentInvoiceId != null && _addedItems.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildAddedItemsList(),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _currentInvoiceId == null
                                ? _submitInvoice
                                : _addInventoryTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttoncolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                _currentInvoiceId == null
                                    ? 'Create Invoice'
                                    : 'Add Inventory',
                                style: const TextStyle(
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
                        onPressed:
                            _addedItems.isEmpty ? null : _showBillSummary,
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
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.blue.shade50,
    );
  }
}
