import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/ext_procedure_model.dart';
import '../../provider/refresh_provider.dart';
import '../../services/patient_service.dart';
import '../../utils/contants.dart';

class ExtProcedureList extends StatefulWidget {
  const ExtProcedureList({super.key});

  @override
  State<ExtProcedureList> createState() => _ExtProcedureListState();
}

class _ExtProcedureListState extends State<ExtProcedureList>
    with WidgetsBindingObserver {
  late Future<List<ExternalProcedure>> _proceduresFuture;

  @override
  void initState() {
    super.initState();
    _proceduresFuture = _getExternalProcedures();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<List<ExternalProcedure>> _getExternalProcedures() async {
    final service = PatientService();
    return await service.getExternalProcedureList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _proceduresFuture = _getExternalProcedures();
    }
  }

  Future<void> _deleteProcedure(int doctorId) async {
    final service = PatientService();
    try {
      await service.deleteProcedure(doctorId);
      setState(() {
        _proceduresFuture = _getExternalProcedures();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procedure deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting procedure: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Procedure'),
            content:
                const Text('Are you sure you want to delete this procedure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.add_box_outlined,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/create_ext_procedure');
              },
            ),
          ),
        ],
      ),
      body: Consumer<RefreshStateNotifier>(
        builder: (context, refreshState, child) {
          // Check if refresh is needed
          if (refreshState.shouldRefresh) {
            _proceduresFuture = _getExternalProcedures();
            refreshState.resetRefresh();
          }

          return FutureBuilder<List<ExternalProcedure>>(
            future: _proceduresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No external procedures found'));
              } else {
                final procedures = snapshot.data!;
                return ListView.builder(
                  itemCount: procedures.length,
                  itemBuilder: (context, index) {
                    final procedure = procedures[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doctor: ${procedure.doctorName}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Procedure: ${procedure.procedureType}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Details: ${procedure.procedureDetail}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${procedure.procedureDate}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fees: ₹${procedure.feesCharged.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cashier: ${procedure.cashierName}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .white, // Set the button background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Rounded corners
                                ),
                              ),
                              onPressed: () async {
                                final confirmed =
                                    await _showConfirmationDialog(context);
                                if (confirmed) {
                                  await _deleteProcedure(procedure.doctorId);
                                }
                              },
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹${procedure.finalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Discount: ₹${procedure.discount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
