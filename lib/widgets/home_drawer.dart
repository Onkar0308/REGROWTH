// lib/widgets/custom_user_drawer.dart

import 'package:flutter/material.dart';
import 'package:regrowth_mobile/utils/contants.dart';
import '../services/storage_service.dart';
import '../screens/expense/add_expense.dart';
import '../screens/expense/view_expenses.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.height * 1.0,
              color: const Color(0xFF91AFEA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Regrowth_logo_1.PNG',
                    width: MediaQuery.of(context).size.width * 0.45,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.people_alt_outlined,
                      weight: 24,
                    ),
                    title: const Text(
                      'Patients',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/patient_list');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.medical_services_outlined,
                      weight: 24,
                    ),
                    title: const Text(
                      'Ext Procedures',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/ext_procedure_list');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.medication,
                      weight: 24,
                    ),
                    title: const Text(
                      'Medicines',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/medicine_list');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      weight: 24,
                    ),
                    title: const Text(
                      'Invoices',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/invoice_list');
                    },
                  ),
                  ExpansionTile(
                    leading: const Icon(
                      Icons.account_balance_wallet_outlined,
                      weight: 24,
                    ),
                    title: const Text(
                      'Expenses',
                      style: AppTextStyles.listTileTitle,
                    ),
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.only(left: 72),
                        leading: const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                        ),
                        title: const Text(
                          'Add Expense',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddExpense(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.only(left: 72),
                        leading: const Icon(
                          Icons.list_alt,
                          size: 20,
                        ),
                        title: const Text(
                          'View Expenses',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ViewExpenses(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.warning_amber_outlined,
                      weight: 24,
                    ),
                    title: const Text(
                      'Low Stock',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/low_stock');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.currency_rupee_outlined,
                      weight: 24,
                    ),
                    title: const Text(
                      'View Bills',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/bill_list');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.inventory_rounded,
                      weight: 24,
                    ),
                    title: const Text(
                      'Invoice',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/invoice_list');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.inventory_2_outlined,
                      weight: 24,
                    ),
                    title: const Text(
                      'Add Inventory',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/create_invoice',
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      weight: 24,
                    ),
                    title: const Text(
                      'Logout',
                      style: AppTextStyles.listTileTitle,
                    ),
                    onTap: () async {
                      await _storageService.clearUserCredentials();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/support_team',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 37),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Support & Development Team',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.022,
                          color: Color.fromRGBO(77, 77, 77, 1),
                        ),
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
}
