import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:regrowth_mobile/provider/refresh_provider.dart';
import 'package:regrowth_mobile/utils/contants.dart';
import '../../model/medicine_model.dart';
import '../../services/medicine_service.dart';
import '../../services/storage_service.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen>
    with WidgetsBindingObserver {
  final MedicineService _medicineService = MedicineService(StorageService());
  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
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
      _loadMedicines();
    }
  }

  Future<void> _loadMedicines() async {
    try {
      final medicines = await _medicineService.getMedicineList();
      setState(() {
        _medicines = medicines;
        _filteredMedicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medicines: $e')),
      );
    }
  }

  void _filterMedicines(String query) {
    setState(() {
      _filteredMedicines = _medicines
          .where((medicine) =>
              medicine.medicineName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshStateNotifier>(
        builder: (context, refreshState, child) {
      if (refreshState.shouldRefresh) {
        _loadMedicines();
        refreshState.resetRefresh();
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Medicines',
            style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w400),
          ),
          backgroundColor: AppColors.primary,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: const Icon(
                  Icons.add_business_outlined,
                  color: Colors.black,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/add_medicine');
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
                onChanged: _filterMedicines,
                decoration: const InputDecoration(
                  labelText: 'Search Medicines',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadMedicines,
                      child: ListView.builder(
                        itemCount: _filteredMedicines.length,
                        itemBuilder: (context, index) {
                          final medicine = _filteredMedicines[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue.shade100),
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.blue.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ListTile(
                                onTap: () async {
                                  try {
                                    final medicineDetails =
                                        await _medicineService
                                            .getMedicineDetails(
                                                medicine.medicineId);
                                    if (mounted) {
                                      Navigator.pushNamed(
                                        context,
                                        '/medicine_details',
                                        arguments: {
                                          'medicine': medicineDetails
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error loading details: $e')),
                                    );
                                  }
                                },
                                contentPadding: const EdgeInsets.all(12),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    medicine.medicineType == 'tab'
                                        ? Icons.medication
                                        : Icons.medical_services,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                title: Text(
                                  medicine.medicineName,
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  'Type: ${medicine.medicineType} | Pack: ${medicine.medicinePack}',
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Qty: ${medicine.quantity}',
                                    style: const TextStyle(
                                      fontFamily: 'Lexend',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.buttoncolor,
          onPressed: () {
            Navigator.pushNamed(context, '/add_medicine');
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
