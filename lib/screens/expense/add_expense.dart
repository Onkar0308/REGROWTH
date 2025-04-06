import 'package:flutter/material.dart';
import '../../model/expense_model.dart';
import '../../services/expense_service.dart';
import '../../widgets/input_field.dart';
import '../../utils/contants.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({Key? key}) : super(key: key);

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final _expenseService = ExpenseService();
  
  final _cashAmountController = TextEditingController();
  final _onlineAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Rent';
  DateTime _selectedDate = DateTime.now();
  double _totalAmount = 0.0;

  final List<String> _categories = [
    'Rent',
    'Other Staff',
    'Travel',
    'Food',
    'Medical Supplies'
  ];

  @override
  void initState() {
    super.initState();
    _cashAmountController.addListener(_updateTotalAmount);
    _onlineAmountController.addListener(_updateTotalAmount);
  }

  void _updateTotalAmount() {
    setState(() {
      double cashAmount = double.tryParse(_cashAmountController.text) ?? 0;
      double onlineAmount = double.tryParse(_onlineAmountController.text) ?? 0;
      _totalAmount = cashAmount + onlineAmount;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      try {
        final expense = ExpenseModel(
          cash_amount: double.parse(_cashAmountController.text),
          online_amount: double.parse(_onlineAmountController.text),
          category: _selectedCategory,
          description: _descriptionController.text,
          date: _selectedDate,
        );

        await _expenseService.addExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add expense: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: AppColors.lightGradient,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(0, 0, 0, 1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Category',
                      labelStyle: TextStyle(
                        fontFamily: 'Lexend',
                        color: Color.fromRGBO(80, 80, 80, 1),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 15,
                      color: Color.fromRGBO(80, 80, 80, 1),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(0, 0, 0, 1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 15,
                          color: Color.fromRGBO(80, 80, 80, 1),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cash Amount
                CustomInputField(
                  hintText: 'Cash Amount',
                  controller: _cashAmountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cash amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Online Amount
                CustomInputField(
                  hintText: 'Online Amount',
                  controller: _onlineAmountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter online amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Total Amount Display
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(0, 0, 0, 1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 15,
                          color: Color.fromRGBO(80, 80, 80, 1),
                        ),
                      ),
                      Text(
                        '₹${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(80, 80, 80, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                CustomInputField(
                  hintText: 'Description',
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttoncolor,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save Expense',
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cashAmountController.removeListener(_updateTotalAmount);
    _onlineAmountController.removeListener(_updateTotalAmount);
    _cashAmountController.dispose();
    _onlineAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}