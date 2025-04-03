import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/patient_model.dart';
import '../../model/report_model.dart';
import '../../services/report_service.dart';
import '../../services/patient_service.dart';
import '../../utils/contants.dart';

class PatientReports extends StatefulWidget {
  const PatientReports({super.key});

  @override
  State<PatientReports> createState() => _PatientReportsState();
}

class _PatientReportsState extends State<PatientReports> {
  final ReportService _reportService = ReportService();
  final PatientService _patientService = PatientService();
  final TextEditingController _searchController = TextEditingController();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  String _selectedSession = 'Both';
  bool _isLoading = false;
  List<Report> _reports = [];
  Map<int, String> _patientNames = {};
  List<Report> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReports() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredReports = _reports;
      } else {
        _filteredReports = _reports.where((report) {
          final patientName =
              _patientNames[report.patientId]?.toLowerCase() ?? '';
          return patientName.contains(searchTerm);
        }).toList();
      }
    });
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.black.withOpacity(0.5)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search by patient name...',
            hintStyle: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              color: AppColors.black.withOpacity(0.7),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.black.withOpacity(0.7),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    color: AppColors.black.withOpacity(0.7),
                    onPressed: () {
                      _searchController.clear();
                      _filterReports();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load reports and patient data in parallel
      final reportsData = _reportService.getReports(
        fromDate: DateFormat('dd-MM-yyyy').format(_fromDate),
        toDate: DateFormat('dd-MM-yyyy').format(_toDate),
        session: _selectedSession,
      );
      final patientsData = _patientService.getPatientList();

      final results = await Future.wait([reportsData, patientsData]);
      final reports = results[0] as List<Report>;
      final patients = results[1] as List<Patient>;

      // Create patient names map
      final patientNamesMap = {
        for (var patient in patients)
          patient.patientId: [
            patient.firstName.trim(),
            if (patient.middleName.isNotEmpty) patient.middleName.trim(),
            patient.lastName.trim(),
          ].where((s) => s.isNotEmpty).join(' ')
      };

      setState(() {
        _reports = reports;
        _filteredReports = reports;
        _patientNames = patientNamesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      _loadData();
    }
  }

  Widget _buildDateRangeSelector() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'From Date',
                      labelStyle: const TextStyle(
                        fontFamily: 'Lexend',
                        color: AppColors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.black),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(_fromDate),
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'To Date',
                      labelStyle: const TextStyle(
                        fontFamily: 'Lexend',
                        color: AppColors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.black),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(_toDate),
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: screenWidth * 0.8,
            child: DropdownButtonFormField<String>(
              value: _selectedSession,
              decoration: InputDecoration(
                labelText: 'Session',
                labelStyle: const TextStyle(
                  fontFamily: 'Lexend',
                  color: AppColors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.black),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: Colors.black,
              ),
              dropdownColor: Colors.white,
              menuMaxHeight: 300,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.black,
              ),
              items: ['Morning', 'Evening', 'Both']
                  .map((session) => DropdownMenuItem(
                        value: session,
                        child: Text(
                          session,
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSession = value;
                  });
                  _loadData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    final patientName = _patientNames[report.patientId] ?? 'Unknown Patient';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'ID: ${report.patientId}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.textblue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${report.finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textblue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Procedure', report.procedureType),
            _buildInfoRow('Details', report.procedureDetail),
            _buildInfoRow(
                'Date',
                DateFormat('MMM dd, yyyy').format(
                    DateFormat('yyyy-MM-dd').parse(report.procedureDate))),
            _buildInfoRow('Clinic', report.clinicName),
            _buildInfoRow('Cashier', report.cashierName),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPaymentInfo('Cash', report.cashPayment),
                _buildPaymentInfo('Online', report.onlinePayment),
                _buildPaymentInfo('Discount', report.discount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Reports',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          _buildDateRangeSelector(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReports
                        .isEmpty // Changed from _reports to _filteredReports
                    ? const Center(
                        child: Text(
                          'No reports found',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredReports
                            .length, // Changed from _reports to _filteredReports
                        itemBuilder: (context, index) =>
                            _buildReportCard(_filteredReports[index]),
                      ),
          )
        ],
      ),
    );
  }
}
