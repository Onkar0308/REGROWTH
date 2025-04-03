import 'package:flutter/material.dart';

import '../../model/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../utils/contants.dart';

class EditAppointment extends StatefulWidget {
  final Appointment appointment;

  const EditAppointment({super.key, required this.appointment});

  @override
  State<EditAppointment> createState() => _EditAppointmentState();
}

class _EditAppointmentState extends State<EditAppointment> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _treatmentController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.appointment.firstName);
    _middleNameController =
        TextEditingController(text: widget.appointment.middleName);
    _lastNameController =
        TextEditingController(text: widget.appointment.lastName);
    _treatmentController =
        TextEditingController(text: widget.appointment.treatment);
    _dateController = TextEditingController(
        text: widget.appointment.appointmentDate.toString());
    _timeController =
        TextEditingController(text: widget.appointment.startTime.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Appointment',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(fontFamily: 'Lexend'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                  labelText: 'Middle Name',
                  labelStyle: TextStyle(fontFamily: 'Lexend'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(fontFamily: 'Lexend'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _treatmentController,
                decoration: const InputDecoration(
                  labelText: 'Treatment',
                  labelStyle: TextStyle(fontFamily: 'Lexend'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Appointment Date',
                  labelStyle: TextStyle(fontFamily: 'Lexend'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  labelStyle: TextStyle(fontFamily: 'Lexend'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final updatedAppointment = Appointment(
                          appointmentId: widget.appointment.appointmentId,
                          firstName: _firstNameController.text,
                          middleName: _middleNameController.text,
                          lastName: _lastNameController.text,
                          treatment: _treatmentController.text,
                          startTime: _timeController.text,
                          appointmentDate: _dateController.text,
                          patientMobile: widget.appointment.patientMobile,
                          cashierName: widget.appointment.cashierName,
                          timestamp: '',
                        );

                        final result = await editAppointment(
                            widget.appointment.appointmentId,
                            updatedAppointment);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Appointment updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(
                            context, result); // Return updated appointment
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Failed to update appointment \n\nPlease check Format of your input \n\n $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.buttoncolor,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
