// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:regrowth_mobile/screens/appointment/edit_appointment.dart';

import '../../model/appointment_model.dart';
import '../../provider/refresh_provider.dart';
import '../../services/appointment_service.dart';
import '../../utils/contants.dart';

class AppointmentDetails extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetails({required this.appointment, super.key});

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  bool _isDeleting = false;

  Future<void> _deleteAppointment(BuildContext context) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final bool success = await AppointmentService()
          .deleteAppointment(widget.appointment.appointmentId);

      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      if (success) {
        // ignore: duplicate_ignore
        // ignore: use_build_context_synchronously
        context.read<RefreshStateNotifier>().refresh();
        Navigator.of(context).pop(); // Close confirmation dialog
        Navigator.of(context).pop(); // Go back to appointment list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      Navigator.of(context).pop(); // Close confirmation dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete appointment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Appointment',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this appointment? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Lexend'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: _isDeleting
                  ? null
                  : () {
                      _deleteAppointment(context);
                      context.read<RefreshStateNotifier>().refresh();
                    },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: _isDeleting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : const Text(
                      'Delete',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDestructive ? Colors.red[50] : AppColors.primary.withOpacity(0.1),
        foregroundColor: isDestructive ? Colors.red : AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Appointments Details',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAppointment(
                      appointment: widget.appointment,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.textblue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Appointment Id',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.appointment.appointmentId}',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.appointment.appointmentDate,
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${widget.appointment.firstName} ${widget.appointment.middleName ?? ''} ${widget.appointment.lastName}',
                          style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Treatment: ${widget.appointment.treatment}',
                          style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start Time: ${widget.appointment.startTime}',
                          style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Patient Mobile: ${widget.appointment.patientMobile == 0 ? 'Not Available' : widget.appointment.patientMobile}',
                          style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),
                        Text('Cashier: ${widget.appointment.cashierName}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            isDestructive: true,
                            onPressed: () {
                              _showDeleteConfirmation(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
