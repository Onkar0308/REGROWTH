import 'package:flutter/material.dart';

import '../../model/invoice_model.dart';
import '../../services/inventory_service.dart';
import '../../utils/contants.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final InventoryService _inventoryService = InventoryService();
  late Future<List<PurchaseDetail>> _purchaseDetailsFuture;

  @override
  void initState() {
    super.initState();
    _purchaseDetailsFuture =
        _inventoryService.getPurchaseDetails(widget.invoice.invoiceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice Details',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Details Card
            Container(
              margin: const EdgeInsets.all(16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invoice No: ${widget.invoice.invoiceNumber}',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID: ${widget.invoice.invoiceId}',
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                      Icons.store, 'Vendor', widget.invoice.vendorName),
                  _buildDetailRow(Icons.calendar_today, 'Purchase Date',
                      widget.invoice.purchaseDate),
                  _buildDetailRow(Icons.currency_rupee, 'Total Amount',
                      '₹${widget.invoice.totalAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),

            // Purchase Details List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Purchase Details',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<PurchaseDetail>>(
              future: _purchaseDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('\n\nError: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                    '\n\nNo purchase details found',
                    style: TextStyle(
                        fontFamily: 'Lexend', fontWeight: FontWeight.w400),
                  ));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final detail = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    detail.medicineName,
                                    style: const TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${detail.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textblue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildPurchaseDetailRow(
                                'Batch', detail.medicineBatch),
                            _buildPurchaseDetailRow('Expiry', detail.expiry),
                            _buildPurchaseDetailRow(
                                'Pack', '${detail.medicinePack}'),
                            _buildPurchaseDetailRow(
                                'Quantity', '${detail.quantity}'),
                            _buildPurchaseDetailRow(
                                'MRP', '₹${detail.mrp.toStringAsFixed(2)}'),
                            _buildPurchaseDetailRow(
                                'Rate', '₹${detail.rate.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.black),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Lexend',
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
