import 'package:flutter/material.dart';
import 'package:regrowth_mobile/screens/billing/bill_details.dart';

import '../../model/bill_model.dart';
import '../../services/billing_service.dart';
import '../../utils/contants.dart';

class BillList extends StatefulWidget {
  const BillList({super.key});

  @override
  State<BillList> createState() => _BillListState();
}

class _BillListState extends State<BillList> with WidgetsBindingObserver {
  final BillingService _billingService = BillingService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;

  List<MedicalBill> _bills = [];
  List<MedicalBill> _filteredBills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
    _searchController.addListener(_filterBills);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _filterBills() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBills = _bills.where((bill) {
        return bill.patientName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadBills();
    }
  }

  Future<void> _loadBills() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bills = await _billingService.getBillList();
      if (mounted) {
        setState(() {
          _bills = bills;
          _filteredBills = bills;
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
    setState(() {});

    try {
      final bills = await _billingService.getBillList();
      if (mounted) {
        setState(() {
          _bills = bills;
          _filterBills();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
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
          'Medical Bills',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Patient Name',
                hintStyle: const TextStyle(fontFamily: 'Lexend'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
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
                  : _filteredBills.isEmpty
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
                          itemCount: _filteredBills.length,
                          itemBuilder: (context, index) {
                            final bill = _filteredBills[index];
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
                                    const SizedBox(height: 8),
                                    Text(
                                      bill.patientName,
                                      style: const TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Patient ID: ${bill.patientId}',
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 12,
                                          color:
                                              AppColors.black.withOpacity(0.7),
                                        ),
                                      ),
                                      Text(
                                        bill.billDate,
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 12,
                                          color:
                                              AppColors.black.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
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
