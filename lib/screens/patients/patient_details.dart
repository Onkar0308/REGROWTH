import 'package:flutter/material.dart';
import 'package:regrowth_mobile/utils/contants.dart';
import '../../model/patient_model.dart';
import '../../services/patient_service.dart';

class PatientDetails extends StatefulWidget {
  final int patientId;

  const PatientDetails({
    super.key,
    required this.patientId,
  });

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  final PatientService _patientService = PatientService();
  bool _isLoading = true;
  Patient? _patient;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  Future<void> _loadPatientDetails() async {
    try {
      final patient = await _patientService.getPatientDetails(widget.patientId);
      setState(() {
        _patient = patient;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _patient?.firstName ?? 'Patient Details',
          style: const TextStyle(fontFamily: 'Lexend'),
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
                final result = await Navigator.pushNamed(
                  context,
                  '/edit_patient',
                  arguments: {
                    'patient': _patient,
                  },
                );

                // Reload patient details if update was successful
                if (result == true) {
                  _loadPatientDetails();
                }
              },
            ),
          ),
        ],
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _patient == null
                  ? const Center(child: Text('Patient not found'))
                  : RefreshIndicator(
                      onRefresh: _loadPatientDetails,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildInfoCard(),
                            const SizedBox(height: 16),
                            _buildContactCard(),
                            const SizedBox(height: 16),
                            _buildMedicalCard(),
                            if (_patient?.patientprocedure?.isNotEmpty ??
                                false) ...[
                              const SizedBox(height: 16),
                              _buildProceduresList(),
                            ],
                            const SizedBox(height: 16),
                            _buildProcedureButtons(),
                            const SizedBox(height: 16),
                            _buildActionButtons(),
                            const SizedBox(height: 16),
                            _buildViewBillsButton(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttoncolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create_procedure',
            arguments: {
              'patientId': widget.patientId,
            },
          );
        },
        child: const Text(
          'Create Procedure',
          style: TextStyle(
              fontSize: 16, fontFamily: 'Lexend', color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProcedureButtons() {
    final fullName = [
      _patient!.firstName,
      if (_patient!.middleName.isNotEmpty == true) _patient!.middleName,
      _patient!.lastName,
    ].join(' ');

    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttoncolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/view_procedure',
            arguments: {
              'patientId': widget.patientId,
              'patientName': fullName,
            },
          );
        },
        child: const Text(
          'View Procedures',
          style: TextStyle(
              fontSize: 16, fontFamily: 'Lexend', color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildViewBillsButton() {
    final fullName = [
      _patient!.firstName,
      if (_patient!.middleName.isNotEmpty == true) _patient!.middleName,
      _patient!.lastName,
    ].join(' ');

    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttoncolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/patient_bills',
            arguments: {
              'patientId': widget.patientId,
              'patientName': fullName,
            },
          );
        },
        child: const Text(
          'View Bills',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Lexend',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                  fontFamily: 'Lexened',
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const Divider(),
            _buildInfoRow('Name',
                '${_patient!.firstName} ${_patient!.middleName} ${_patient!.lastName}'),
            _buildInfoRow('Age', '${_patient!.patientAge} years'),
            _buildInfoRow('Gender', _patient!.patientGender),
            _buildInfoRow('Registration Date', _patient!.patientRegDate),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                  fontFamily: 'Lexened',
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const Divider(),
            _buildInfoRow('Primary Mobile', '${_patient!.patientMobile1}'),
            _buildInfoRow(
                'Secondary Mobile',
                _patient!.patientMobile2 == 0
                    ? '-'
                    : '${_patient!.patientMobile2}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Information',
              style: TextStyle(
                  fontFamily: 'Lexened',
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const Divider(),
            _buildInfoRow(
                'Medical History',
                _patient!.patientMedicalHistory.isEmpty
                    ? 'History Unavailable'
                    : _patient!.patientMedicalHistory),
            if (_patient!.patientReports.isNotEmpty)
              _buildInfoRow('Reports', _patient!.patientReports),
            _buildInfoRow('Cashier', _patient!.cashierName),
            _buildInfoRow('Last Updated', _patient!.timestamp),
          ],
        ),
      ),
    );
  }

  Widget _buildProceduresList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Procedures',
              style: TextStyle(
                  fontFamily: 'Lexened',
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _patient?.patientprocedure?.length ?? 0,
              itemBuilder: (context, index) {
                final procedure = _patient!.patientprocedure?[index];
                return ListTile(
                  title: Text(procedure.toString()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'Lexend', fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
