import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:regrowth_mobile/utils/contants.dart';
import '../../model/patient_model.dart';
import '../../provider/refresh_provider.dart';
import '../../services/patient_service.dart';

class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> with WidgetsBindingObserver {
  final PatientService _patientService = PatientService();
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPatients();
    }
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _patientService.getPatientList();
      setState(() {
        _patients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // print('Error loading patients: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading patients: $e')),
      );
    }
  }

  void _filterPatients(String query) {
    setState(() {
      _searchQuery = query;
      _filteredPatients = _patients.where((patient) {
        final fullName =
            '${patient.firstName} ${patient.middleName} ${patient.lastName}'
                .toLowerCase();
        final mobile = '${patient.patientMobile1}';
        return fullName.contains(query.toLowerCase()) || mobile.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshStateNotifier>(
        builder: (context, refreshState, child) {
      if (refreshState.shouldRefresh) {
        _loadPatients();
        refreshState.resetRefresh();
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Patients',
            style: TextStyle(fontFamily: 'Lexend'),
          ),
          backgroundColor: AppColors.primary,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: const Icon(
                  Icons.person_add_alt_1,
                  color: Colors.black,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/add_new_patient');
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search patients by name or mobile',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: _filterPatients,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPatients.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No patients found'
                                : 'No matching patients found',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadPatients,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = _filteredPatients[index];
                              return PatientCard(patient: patient);
                            },
                          ),
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.buttoncolor,
          onPressed: () {
            Navigator.pushNamed(context, '/add_new_patient');
          },
          child: const Icon(
            Icons.add,
            color: AppColors.white,
          ),
        ),
      );
    });
  }
}

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(230, 235, 255, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/patient_details',
              arguments: {'patientId': patient.patientId},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${patient.firstName} ${patient.middleName} ${patient.lastName}',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ID: ${patient.patientId}',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          color: Color(0xFF4A5568),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: Color(0xFF4A5568),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${patient.patientMobile1 == 0 ? 'Not Available' : patient.patientMobile1}',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        color: Color(0xFF4A5568),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.event_outlined,
                      size: 18,
                      color: Color(0xFF4A5568),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reg. Date: ${patient.patientRegDate}',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        color: Color(0xFF4A5568),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      patient.patientGender.toLowerCase() == 'male'
                          ? Icons.male_outlined
                          : Icons.female_outlined,
                      size: 18,
                      color: const Color(0xFF4A5568),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${patient.patientAge} years, ${patient.patientGender}',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        color: Color(0xFF4A5568),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (patient.patientMedicalHistory.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Medical History',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      color: Color(0xFF2D3748),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3FBFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      patient.patientMedicalHistory,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        color: Color(0xFF4A5568),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
