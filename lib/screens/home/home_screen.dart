import 'package:flutter/material.dart';
import 'package:regrowth_mobile/services/patient_service.dart';
import 'package:regrowth_mobile/utils/contants.dart';
import 'package:regrowth_mobile/widgets/custom_app_bar.dart';
import 'package:regrowth_mobile/widgets/home_drawer.dart';
import 'package:intl/intl.dart';

import '../../model/bill_model.dart';
import '../../model/ext_procedure_model.dart';
import '../../model/invoice_model.dart';
import '../../model/procedure_model.dart';
import '../../services/billing_service.dart';
import '../../services/inventory_service.dart';
import '../../services/procedure_service.dart';
import '../../services/storage_service.dart';

class home_Screen extends StatefulWidget {
  const home_Screen({super.key});

  @override
  State<home_Screen> createState() => _home_ScreenState();
}

class _home_ScreenState extends State<home_Screen> {
  final ProcedureService _procedureService = ProcedureService();
  final InventoryService _inventoryService = InventoryService();
  final BillingService _billingService = BillingService();
  final StorageService _storageService = StorageService();
  final PatientService _patientService = PatientService();

  bool isLoading = true;
  double totalIncome = 0.0;
  int totalProcedures = 0;
  double totalExpenses = 0.0;
  double totalBillRevenue = 0.0;
  String? role;

  @override
  void initState() {
    super.initState();
    fetchMonthlyStats();
    fetchUserRole();
  }

  Future<void> fetchMonthlyStats() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> stats = await getMonthlyProcedureStats();
    Map<String, dynamic> externalStats =
        await getMonthlyExternalProcedureStats();
    Map<String, dynamic> expense = await getMonthlyExpenses();
    Map<String, dynamic> billRevenue = await getMonthlyBillRevenue();

    setState(() {
      totalIncome = stats['totalIncome'] + externalStats['totalExternalIncome'];
      totalProcedures =
          stats['totalProcedures'] + externalStats['totalExternalProcedures'];
      totalExpenses = expense['totalExpenses'];
      totalBillRevenue = billRevenue['totalBillRevenue'];
      isLoading = false;
    });
  }

  Future<void> fetchUserRole() async {
    final credentials = await _storageService.getUserCredentials();
    setState(() {
      role = credentials['role'];
    });
  }

  Future<Map<String, dynamic>> getMonthlyProcedureStats() async {
    try {
      List<Procedure> procedures = await _procedureService.getProcedureList();

      // Get current month and year
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      // Filter procedures for the current month
      List<Procedure> monthlyProcedures = procedures.where((procedure) {
        DateTime procedureDate =
            DateFormat('dd-MM-yyyy').parse(procedure.procedureDate);
        return procedureDate.month == currentMonth &&
            procedureDate.year == currentYear;
      }).toList();

      double totalIncome = monthlyProcedures.fold(
          0.0, (sum, procedure) => sum + procedure.finalAmount);
      int totalProcedures = monthlyProcedures.length;

      return {
        'totalIncome': totalIncome,
        'totalProcedures': totalProcedures,
      };
    } catch (e) {
      print("Error calculating total income: $e");
      return {
        'totalIncome': 0.0,
        'totalProcedures': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getMonthlyExternalProcedureStats() async {
    try {
      List<ExternalProcedure> externalProcedures =
          await _patientService.getExternalProcedureList();

      // Get current month and year
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      // Filter external procedures for the current month
      List<ExternalProcedure> monthlyExternalProcedures =
          externalProcedures.where((procedure) {
        DateTime procedureDate =
            DateFormat('dd-MM-yyyy').parse(procedure.procedureDate);
        return procedureDate.month == currentMonth &&
            procedureDate.year == currentYear;
      }).toList();

      // Calculate total income and total procedures from external procedures
      double totalExternalIncome = monthlyExternalProcedures.fold(
          0.0, (sum, procedure) => sum + procedure.finalAmount);
      int totalExternalProcedures = monthlyExternalProcedures.length;

      return {
        'totalExternalIncome': totalExternalIncome,
        'totalExternalProcedures': totalExternalProcedures,
      };
    } catch (e) {
      print("Error calculating external procedure stats: $e");
      return {
        'totalExternalIncome': 0.0,
        'totalExternalProcedures': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getMonthlyExpenses() async {
    try {
      List<Invoice> invoices = await _inventoryService.getInvoiceList();

      // Get current month and year
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      // Filter invoices for the current month
      List<Invoice> monthlyInvoices = invoices.where((invoice) {
        DateTime invoiceDate =
            DateFormat('dd-MM-yyyy').parse(invoice.purchaseDate);
        return invoiceDate.month == currentMonth &&
            invoiceDate.year == currentYear;
      }).toList();

      // Calculate total expenses
      double totalExpenses = monthlyInvoices.fold(
          0.0, (sum, invoice) => sum + invoice.totalAmount);

      return {
        'totalExpenses': totalExpenses, // ✅ Use a string key
      };
    } catch (e) {
      print("Error calculating total expenses: $e");
      return {
        'totalExpenses': 0.0,
      };
    }
  }

  Future<Map<String, dynamic>> getMonthlyBillRevenue() async {
    try {
      List<MedicalBill> bills = await _billingService.getBillList();

      // Get current month and year
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      // Filter bills for the current month
      List<MedicalBill> monthlyBills = bills.where((bill) {
        DateTime billDate = DateFormat('dd-MM-yyyy').parse(bill.billDate);
        return billDate.month == currentMonth && billDate.year == currentYear;
      }).toList();

      // Calculate total bill revenue
      double totalBillRevenue =
          monthlyBills.fold(0.0, (sum, bill) => sum + bill.totalAmount);

      return {
        'totalBillRevenue': totalBillRevenue,
      };
    } catch (e) {
      print("Error calculating bill revenue: $e");
      return {
        'totalBillRevenue': 0.0,
      };
    }
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue, // Change as per your theme
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "This Month",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required IconData icon,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomUserAppBar(),
      drawer: CustomDrawer(),
      body: isLoading
          ? Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: AppColors.lightGradient,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text("Just a second",
                        style: TextStyle(fontSize: 16, fontFamily: 'Lexend')),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: AppColors.lightGradient,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.textblue,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Quick access to all clinic modules',
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (role == "ADMIN")
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: [
                              _buildCard(
                                icon: Icons.attach_money,
                                title: "Total Income",
                                count: "₹${totalIncome.toStringAsFixed(0)}",
                                color: AppColors.primary,
                              ),
                              _buildCard(
                                icon: Icons.local_hospital,
                                title: "Procedures",
                                count: "$totalProcedures",
                                color: AppColors.primary,
                              ),
                              _buildCard(
                                icon: Icons.money,
                                title: "Expenses",
                                count: "₹${totalExpenses.toStringAsFixed(0)}",
                                color: AppColors.primary,
                              ),
                              _buildCard(
                                icon: Icons.medication_outlined,
                                title: "Medicine Bill",
                                count:
                                    "₹${totalBillRevenue.toStringAsFixed(0)}",
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          children: [
                            _buildModuleCard(
                              title: 'Patients',
                              icon: Icons.people,
                              count: 'View details',
                              color: AppColors.primary,
                              onTap: () =>
                                  Navigator.pushNamed(context, '/patient_list'),
                            ),
                            _buildModuleCard(
                              title: 'Procedures',
                              icon: Icons.medical_services,
                              count: 'View All',
                              color: AppColors.pink,
                              onTap: () {
                                Navigator.pushNamed(context, '/procedure_list');
                              },
                            ),
                            _buildModuleCard(
                              title: 'Appointments',
                              icon: Icons.person_add_alt_1,
                              count: 'View All',
                              color: AppColors.accent,
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/appointment_list');
                              },
                            ),
                            _buildModuleCard(
                              title: 'Reports',
                              icon: Icons.analytics_outlined,
                              count: 'View All',
                              color: const Color(0xFFFFA726),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/patient_reports');
                              },
                            ),
                            _buildModuleCard(
                              title: 'Inventory',
                              icon: Icons.inventory_2,
                              count: 'Add Items',
                              color: AppColors.secondary,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/create_invoice',
                                );
                              },
                            ),
                            _buildModuleCard(
                              title: 'Billing',
                              icon: Icons.analytics,
                              count: 'Create New',
                              color: const Color(0xFF66BB6A),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/create_bill',
                                );
                              },
                            ),
                          ],
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
