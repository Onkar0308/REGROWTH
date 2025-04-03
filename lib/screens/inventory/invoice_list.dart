import 'package:flutter/material.dart';
import 'package:regrowth_mobile/screens/inventory/invoice_details.dart';
import 'package:regrowth_mobile/utils/contants.dart';

import '../../model/invoice_model.dart';
import '../../services/inventory_service.dart';

class InvoiceList extends StatefulWidget {
  const InvoiceList({super.key});

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  final InventoryService _inventoryService = InventoryService();
  late Future<List<Invoice>> _invoicesFuture;
  List<Invoice> _allInvoices = [];
  List<Invoice> _filteredInvoices = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    _invoicesFuture = _inventoryService.getInvoiceList();
    _allInvoices = await _invoicesFuture;
    _filteredInvoices = _allInvoices;
    setState(() {});
  }

  void _filterInvoices(String query) {
    setState(() {
      _filteredInvoices = _allInvoices.where((invoice) {
        return invoice.invoiceNumber
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            invoice.vendorName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice List',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _filterInvoices,
              style: const TextStyle(fontFamily: 'Lexend'),
              decoration: InputDecoration(
                hintText: 'Search invoices...',
                hintStyle: const TextStyle(
                  fontFamily: 'Lexend',
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.black),
                filled: true,
                fillColor: AppColors.secondary.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.secondary.withOpacity(0.3)),
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
              color: AppColors.black,
              backgroundColor: AppColors.white,
              onRefresh: () async {
                setState(() {
                  _invoicesFuture = _inventoryService.getInvoiceList();
                });
                final refreshedInvoices = await _invoicesFuture;
                setState(() {
                  _allInvoices = refreshedInvoices;
                  _filterInvoices(_searchController.text);
                });
              },
              child: FutureBuilder<List<Invoice>>(
                future: _invoicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.primary,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              fontFamily: 'Lexend',
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Pull to refresh',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_filteredInvoices.isEmpty) {
                    return const Center(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              color: AppColors.primary,
                              size: 60,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No invoices found',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Pull to refresh',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final invoice = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InvoiceDetailsScreen(invoice: invoice),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          color: AppColors.white,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.secondary, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.receipt_long,
                                            color: AppColors.black),
                                        const SizedBox(width: 8),
                                        Text(
                                          invoice.invoiceNumber,
                                          style: const TextStyle(
                                            fontFamily: 'Lexend',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'ID: ${invoice.invoiceId}',
                                        style: const TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 12,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.store,
                                        size: 20, color: AppColors.black),
                                    const SizedBox(width: 8),
                                    Text(
                                      invoice.vendorName,
                                      style: const TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 20, color: AppColors.black),
                                    const SizedBox(width: 8),
                                    Text(
                                      invoice.purchaseDate,
                                      style: const TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.currency_rupee_rounded,
                                        size: 20, color: AppColors.black),
                                    const SizedBox(width: 8),
                                    Text(
                                      invoice.totalAmount.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
