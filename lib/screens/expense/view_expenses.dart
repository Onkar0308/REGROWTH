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

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _expenseService.getExpenses();
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load expenses: $e')),
        );
      }
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await _expenseService.deleteExpense(id);
      _loadExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete expense: $e')),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpense()),
              );
              if (result == true) {
                _loadExpenses();
              }
            },
          ),
        ],
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            expense.title,
                            style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                expense.description,
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
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
                                        fontSize: 12,
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
                            ],
                          ),
                          trailing: Text(
                            '₹${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Delete Expense',
                                  style: TextStyle(fontFamily: 'Lexend'),
                                ),
                                content: const Text(
                                  'Are you sure you want to delete this expense?',
                                  style: TextStyle(fontFamily: 'Lexend'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontFamily: 'Lexend'),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteExpense(expense.id);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}