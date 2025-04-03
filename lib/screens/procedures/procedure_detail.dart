import 'package:flutter/material.dart';
import 'package:regrowth_mobile/utils/contants.dart';

import '../../model/procedure_model.dart';

class ProcedureDetail extends StatefulWidget {
  final Procedure procedure;
  final String patientName;

  const ProcedureDetail({
    super.key,
    required this.procedure,
    this.patientName = '',
  });

  @override
  State<ProcedureDetail> createState() => _ProcedureDetailState();
}

class _ProcedureDetailState extends State<ProcedureDetail> {
  String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Procedure Details',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () async {
                await Navigator.pushReplacementNamed(
                  context,
                  '/edit_procedure',
                  arguments: {
                    'procedure': widget.procedure,
                  },
                );
              },
            ),
          ),
        ],
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Patient Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.patientName,
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.procedure.procedureType,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Procedure Details Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Procedure Information',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Description',
                            widget.procedure.procedureDetail,
                          ),
                          _buildDetailRow(
                            'Date',
                            widget.procedure.procedureDate,
                            icon: Icons.calendar_today,
                          ),
                          _buildDetailRow(
                            'Clinic',
                            widget.procedure.clinicName,
                            icon: Icons.local_hospital,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payment Details Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Information',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Total Amount',
                            _formatAmount(widget.procedure.finalAmount),
                            textColor: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          _buildDetailRow(
                            'Cash Payment',
                            _formatAmount(widget.procedure.cashPayment),
                            icon: Icons.money,
                          ),
                          _buildDetailRow(
                            'Online Payment',
                            _formatAmount(widget.procedure.onlinePayment),
                            icon: Icons.credit_card,
                          ),
                          if (widget.procedure.discount > 0)
                            _buildDetailRow(
                              'Discount',
                              _formatAmount(widget.procedure.discount),
                              icon: Icons.discount,
                              textColor: Colors.green,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Staff Information Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Staff Information',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Cashier',
                            widget.procedure.cashierName,
                            icon: Icons.person_outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color? textColor,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Lexend',
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                color: textColor,
                fontWeight: fontWeight ?? FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
