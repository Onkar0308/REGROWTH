import 'package:flutter/material.dart';
import 'package:regrowth_mobile/utils/contants.dart';

import '../../model/procedure_model.dart';
import '../../services/patient_service.dart';
import '../../services/procedure_service.dart';

class ProcedureList extends StatefulWidget {
  const ProcedureList({super.key});

  @override
  State<ProcedureList> createState() => _ProcedureListState();
}

class _ProcedureListState extends State<ProcedureList> {
  final ProcedureService _procedureService = ProcedureService();
  final PatientService _patientService = PatientService();
  final TextEditingController _searchController = TextEditingController();

  List<Procedure> _procedures = [];
  List<Procedure> _filteredProcedures = [];
  Map<int, String> _patientNames = {};

  bool _isLoading = true;
  String? _error;
  String _searchCriteria = 'patientName';

  @override
  void initState() {
    super.initState();

    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredProcedures = _procedures;
      } else {
        _filteredProcedures = _procedures.where((procedure) {
          final patientName =
              _patientNames[procedure.patientId]?.toLowerCase() ?? '';
          if (_searchCriteria == 'patientName') {
            return patientName.contains(searchTerm);
          } else {
            return procedure.procedureType.toLowerCase().contains(searchTerm);
          }
        }).toList();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load both procedures and patients
      final procedures =
          await _procedureService.getProcedureListWithErrorHandling();
      final patients = await _patientService.getPatientList();

      // Create a map of patient IDs to their full names
      final patientNamesMap = {
        for (var patient in patients)
          patient.patientId: [
            patient.firstName.trim(),
            if (patient.middleName.isNotEmpty) patient.middleName.trim(),
            patient.lastName.trim(),
          ].where((s) => s.isNotEmpty).join(' ')
      };

      setState(() {
        // Reverse the procedures list before assigning
        _procedures = procedures.reversed.toList();
        _filteredProcedures =
            _procedures; // Filtered list will also be in reverse order
        _patientNames = patientNamesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  Widget _buildSearchBar() {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _searchCriteria == 'patientName'
                          ? 'Search by Patient Name...'
                          : 'Search by Procedure Type...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Patient Name'),
                selected: _searchCriteria == 'patientName',
                selectedColor: AppColors.textblue.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _searchCriteria == 'patientName'
                      ? AppColors.textblue
                      : Colors.grey[700],
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _searchCriteria = 'patientName';
                      _onSearchChanged();
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Procedure Type'),
                selected: _searchCriteria == 'procedureType',
                selectedColor: AppColors.textblue.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _searchCriteria == 'procedureType'
                      ? AppColors.textblue
                      : Colors.grey[700],
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _searchCriteria = 'procedureType';
                      _onSearchChanged();
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureCard(Procedure procedure) {
    final patientName = _patientNames[procedure.patientId] ?? 'Loading...';

    return GestureDetector(
      onTap: () {
        final patientName =
            _patientNames[procedure.patientId] ?? 'Unknown Patient';
        Navigator.pushNamed(
          context,
          '/procedure_detail',
          arguments: {
            'procedure': procedure,
            'patientName': patientName,
          },
        ).then((value) {
          if (value == true) {
            _loadData();
          }
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient ID and Procedure Type Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient ID Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textblue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.textblue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          patientName,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Procedure Type and Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      procedure.procedureType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatAmount(procedure.finalAmount),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                procedure.procedureDetail,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              // Date and Clinic
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          procedure.procedureDate,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          procedure.clinicName,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Payment Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Payment Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.money,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cash: ${_formatAmount(procedure.cashPayment)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.credit_card,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Online: ${_formatAmount(procedure.onlinePayment)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Discount Badge
                  if (procedure.discount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.discount,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Discount: ${_formatAmount(procedure.discount)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // Cashier name
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cashier: ${procedure.cashierName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
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
          'Procedures',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.refresh,
                size: 28,
              ),
              onPressed: _loadData,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: $_error',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredProcedures.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _procedures.isEmpty
                                      ? 'No procedures found'
                                      : 'No matching procedures found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _filteredProcedures.length,
                              itemBuilder: (context, index) {
                                return _buildProcedureCard(
                                    _filteredProcedures[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
