import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/appointment_model.dart';
import '../../provider/refresh_provider.dart';
import '../../services/appointment_service.dart';
import '../../services/storage_service.dart';
import '../../utils/contants.dart';
import 'package:intl/intl.dart';

class CreateAppointment extends StatefulWidget {
  const CreateAppointment({super.key});

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _appointmentDateController =
      TextEditingController();
  final TextEditingController _patientMobileController =
      TextEditingController();

  bool _isSubmitting = false;

  String capitalizeText(String text) {
    if (text.isEmpty) return text;

    // Split the text into words and capitalize each word
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() +
          (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).join(' ');
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final storageService = StorageService();
    final userCredentials = await storageService.getUserCredentials();
    final username = userCredentials['username'] ?? 'Unknown';

    final newAppointment = Appointment(
      appointmentId: 0, // This will be assigned by the server
      firstName: _firstNameController.text,
      middleName: _middleNameController.text.isNotEmpty
          ? _middleNameController.text
          : null,
      lastName: _lastNameController.text,
      treatment: _treatmentController.text,
      startTime: _startTimeController.text,
      appointmentDate: _appointmentDateController.text,
      patientMobile: int.tryParse(_patientMobileController.text) ?? 0,
      cashierName: username,
      timestamp: '', // Not needed for submission
    );

    try {
      final createdAppointment =
          await AppointmentService().createAppointment(newAppointment);

      context.read<RefreshStateNotifier>().refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Appointment created: ${createdAppointment.appointmentId}'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Format the selected date and update the controller
        _appointmentDateController.text =
            DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // Convert TimeOfDay to string in "HH:mm" format
      final DateTime now = DateTime.now();
      final DateTime formattedTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      final String formattedTimeString =
          DateFormat('HH:mm').format(formattedTime);

      setState(() {
        _startTimeController.text = formattedTimeString;
      });
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    String? mobileValidator(String? value) {
      if (isRequired && (value == null || value.isEmpty)) {
        return 'Required field';
      }
      if (value != null && value.isNotEmpty) {
        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
          return 'Please enter a valid 10-digit mobile number';
        }
      }
      return null;
    }

    String? defaultValidator(String? value) {
      if (isRequired && (value == null || value.isEmpty)) {
        return 'Required field';
      }
      return null;
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFEDEDED),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            final capitalizedText = capitalizeText(value);
            if (value != capitalizedText) {
              controller.value = controller.value.copyWith(
                text: capitalizedText,
                selection:
                    TextSelection.collapsed(offset: capitalizedText.length),
              );
            }
          },
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            border: InputBorder.none,
            labelStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
            ),
          ),
          validator: validator ??
              (label.toLowerCase().contains('mobile')
                  ? mobileValidator
                  : defaultValidator),
        ),
      ),
    );
  }

  Widget _buildFormFieldTime({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFEDEDED),
        ),
        child: ListTile(
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontFamily: 'Lexend',
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () => _selectTime(context),
          ),
          subtitle: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: true, // Prevent manual editing
            decoration: const InputDecoration(
              hintText: 'Select time',
              border: InputBorder.none,
            ),
            validator: validator ??
                (isRequired
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required field';
                        }
                        return null;
                      }
                    : null),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Appointment',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFormField(
                  controller: _firstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
                _buildFormField(
                  controller: _middleNameController,
                  label: 'Middle Name',
                ),
                _buildFormField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
                _buildFormField(
                  controller: _treatmentController,
                  label: 'Treatment',
                  isRequired: true,
                ),
                _buildFormFieldTime(
                  controller: _startTimeController,
                  label: 'Start Time',
                  isRequired: true,
                  keyboardType: TextInputType.datetime,
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.90,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromRGBO(237, 237, 237, 1),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 28),
                      title: Text(
                        'Appointment Date: ${_appointmentDateController.text.isEmpty ? '\nSelect a date' : _appointmentDateController.text}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                ),
                _buildFormField(
                  controller: _patientMobileController,
                  label: 'Mobile Number',
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.90,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAppointment,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: AppColors.buttoncolor,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            )
                          : const Text(
                              'Create Appointment',
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
      ),
    );
  }
}
