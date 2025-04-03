import 'package:flutter/material.dart';
import 'package:regrowth_mobile/screens/billing/bill_details.dart';
import 'package:regrowth_mobile/utils/contants.dart';

import '../../model/bill_model.dart';
import '../../services/billing_service.dart';

class PatientBills extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientBills({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientBills> createState() => _PatientBillsState();
}

class _PatientBillsState extends State<PatientBills> {
  final BillingService _billingService = BillingService();
  bool _isLoading = false;
  List<MedicalBill> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadPatientBills();
  }

  Future<void> _loadPatientBills() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final allBills = await _billingService.getBillList();
      if (mounted) {
        setState(() {
          _bills = allBills
              .where((bill) => bill.patientId.toString() == widget.patientId)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bills: $e')),
        );
      }
    }
  }

  Future<void> _refreshBills() async {
    try {
      final allBills = await _billingService.getBillList();
      if (mounted) {
        setState(() {
          _bills = allBills
              .where((bill) => bill.patientId.toString() == widget.patientId)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing bills: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _refreshBills,
              textColor: Colors.white,
            ),
            backgroundColor: Colors.red,
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
          'Bills',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Summary Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Bills:',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _bills.length.toString(),
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textblue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${_bills.fold(0.0, (sum, bill) => sum + bill.totalAmount).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textblue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bills List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshBills,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              strokeWidth: 2.5,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _bills.isEmpty
                      ? const Center(
                          child: Text(
                            'No bills found',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 16,
                              color: AppColors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _bills.length,
                          itemBuilder: (context, index) {
                            final bill = _bills[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Bill ${bill.billId}',
                                          style: const TextStyle(
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '₹${bill.totalAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontFamily: 'Lexend',
                                              color: Color.fromARGB(
                                                  255, 112, 159, 255),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    bill.billDate,
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 12,
                                      color: AppColors.black.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BillDetails(bill: bill),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      _refreshBills();
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
