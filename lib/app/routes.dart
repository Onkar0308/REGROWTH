// lib/app/routes.dart

import 'package:flutter/material.dart';
import 'package:regrowth_mobile/screens/Ext%20Procedure/create_ext_procedure.dart';
import 'package:regrowth_mobile/screens/Ext%20Procedure/ext_procedure_list.dart';
import 'package:regrowth_mobile/screens/appointment/appointment_list.dart';
import 'package:regrowth_mobile/screens/appointment/create_appointment.dart';
import 'package:regrowth_mobile/screens/auth/login.dart';
import 'package:regrowth_mobile/screens/billing/patient_bill.dart';
import 'package:regrowth_mobile/screens/home/home_screen.dart';
import 'package:regrowth_mobile/screens/medicine/add_medicine_screen.dart';
import 'package:regrowth_mobile/screens/medicine/low_stock_screen.dart';
import 'package:regrowth_mobile/screens/patients/patient_details.dart';
import 'package:regrowth_mobile/screens/patients/patient_list.dart';
import 'package:regrowth_mobile/screens/splash/splash_screen.dart';
import 'package:regrowth_mobile/widgets/support_team.dart';

import '../screens/billing/bill_list.dart';
import '../screens/billing/create_bill.dart';
import '../screens/expense/add_expense.dart';
import '../screens/expense/view_expenses.dart';
import '../screens/inventory/create_invoice.dart';
import '../screens/inventory/invoice_list.dart';
import '../screens/medicine/medicine_detail_screen.dart';
import '../screens/medicine/medicine_list_screen.dart';
import '../screens/patients/add_new_patient.dart';
import '../screens/patients/edit_patient_details.dart';
import '../screens/patients/patient_reports.dart';
import '../screens/procedures/create_procedure.dart';
import '../screens/procedures/edit_procedure.dart';
import '../screens/procedures/patient_procedures.dart';
import '../screens/procedures/procedure_detail.dart';
import '../screens/procedures/procedure_list.dart';
import '../widgets/under_development.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const login_Screen(),
  '/home': (context) => const home_Screen(),
  '/patient_list': (context) => const PatientList(),
  '/patient_details': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return PatientDetails(patientId: args['patientId']);
  },
  '/add_new_patient': (context) => const AddNewPatient(),
  '/procedure_list': (context) => const ProcedureList(),
  '/create_procedure': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return CreateProcedureScreen(patientId: args['patientId']);
  },
  '/medicine_list': (context) => const MedicineListScreen(),
  '/add_medicine': (context) => const AddMedicineScreen(),
  '/medicine_details': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return MedicineDetailsScreen(medicine: args['medicine']);
  },
  '/invoice_list': (context) => const InvoiceList(),
  '/create_invoice': (context) => const CreateInvoiceScreen(),
  '/under_development': (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    return UnderDevelopmentScreen(
      screenName: args?['screenName'] ?? '',
    );
  },
  '/create_bill': (context) => const CreateBill(),
  '/bill_list': (context) => const BillList(),
  '/low_stock': (context) => const LowStockScreen(),
  '/view_procedure': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return PatientProcedures(
      patientId: args['patientId'],
      patientName: args['patientName'],
    );
  },
  '/procedure_detail': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ProcedureDetail(
      procedure: args['procedure'],
      patientName: args['patientName'],
    );
  },
  '/edit_procedure': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return EditProcedure(
      procedure: args['procedure'],
    );
  },
  '/edit_patient': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return EditPatient(
      patient: args['patient'],
    );
  },
  '/patient_bills': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return PatientBills(
      patientId: args['patientId'].toString(),
      patientName: args['patientName'] as String,
    );
  },
  '/patient_reports': (context) => const PatientReports(),
  '/support_team': (context) => SupportTeamScreen(),
  '/appointment_list': (context) => const AppointmentList(),
  '/create_appointment': (context) => const CreateAppointment(),
  '/ext_procedure_list': (context) => const ExtProcedureList(),
  '/create_ext_procedure': (context) => const CreateExtProcedure(),
  '/add_expense': (context) => const AddExpense(),
  '/view_expenses': (context) => const ViewExpenses(),
};
