import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/expense_model.dart';
import '../../services/expense_service.dart';
import '../../utils/contants.dart';
import 'add_expense.dart';

class ViewExpenses extends StatefulWidget {
  const ViewExpenses({Key? key}) : super(key: key);

  @override
  State<ViewExpenses> createState() => _ViewExpensesState();
}

class _ViewExpensesState extends State<ViewExpenses> {
  final ExpenseService _expenseService = ExpenseService();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final expenses = await _expenseService.getExpensesWithErrorHandling();
      if (mounted) {
        setState(() {
          _expenses = expenses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await _expenseService.deleteExpense(id);
      _loadExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
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
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.buttoncolor),
                    SizedBox(height: 16),
                    Text(
                      "Loading expenses...",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Lexend',
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadExpenses,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttoncolor,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _expenses.isEmpty
                    ? const Center(
                        child: Text(
                          'No expenses found',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category and Date
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          expense.category,
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontSize: 14,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(expense.date),
                                        style: const TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Description
                                  Text(
                                    expense.description,
                                    style: const TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Amounts
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Cash Amount
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Cash',
                                              style: TextStyle(
                                                fontFamily: 'Lexend',
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '₹${expense.cash_amount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontFamily: 'Lexend',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Online Amount
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Online',
                                              style: TextStyle(
                                                fontFamily: 'Lexend',
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '₹${expense.online_amount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontFamily: 'Lexend',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Total Amount
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Total',
                                              style: TextStyle(
                                                fontFamily: 'Lexend',
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '₹${expense.totalAmount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontFamily: 'Lexend',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
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
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpense()),
          );
          if (result == true) {
            _loadExpenses();
          }
        },
        backgroundColor: AppColors.buttoncolor,
        child: const Icon(Icons.add),
      ),
    );
  }
}