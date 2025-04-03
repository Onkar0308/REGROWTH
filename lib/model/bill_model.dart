// lib/models/medical_bill.dart

class MedicalBill {
  final int billId;
  final int billNumber;
  final String billDate; // timestamp in milliseconds
  final String patientName;
  final double totalAmount;
  final int patientId;

  MedicalBill({
    required this.billId,
    required this.billNumber,
    required this.billDate,
    required this.patientName,
    required this.totalAmount,
    required this.patientId,
  });

  factory MedicalBill.fromJson(Map<String, dynamic> json) {
    return MedicalBill(
      billId: json['billId'],
      billNumber: json['billNumber'],
      billDate: json['billDate'],
      patientName: json['patientName'],
      totalAmount: json['totalAmount'].toDouble(),
      patientId: json['patientId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'billNumber': billNumber,
      'billDate': billDate,
      'patientName': patientName,
      'totalAmount': totalAmount,
      'patientId': patientId,
    };
  }
}

class BillResponse {
  final int billId;
  final int billNumber;
  final String billDate;
  final String patientName;
  final double totalAmount;
  final int patientId;

  BillResponse({
    required this.billId,
    required this.billNumber,
    required this.billDate,
    required this.patientName,
    required this.totalAmount,
    required this.patientId,
  });

  factory BillResponse.fromJson(Map<String, dynamic> json) {
    return BillResponse(
      billId: json['billId'] as int,
      billNumber: json['billNumber'] as int,
      billDate: json['billDate'] as String,
      patientName: json['patientName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      patientId: json['patientId'] as int,
    );
  }
}

class MedicineDetail {
  final int billTransactionId;
  final double medQuantity;
  final String medName;
  final double medMrp;
  final double totalAmount;
  final int billNumber;
  final int medicineNumber;

  MedicineDetail({
    required this.billTransactionId,
    required this.medQuantity,
    required this.medName,
    required this.medMrp,
    required this.totalAmount,
    required this.billNumber,
    required this.medicineNumber,
  });

  factory MedicineDetail.fromJson(Map<String, dynamic> json) {
    return MedicineDetail(
      billTransactionId: json['billTransactionId'],
      medQuantity: json['medQuantity'].toDouble(),
      medName: json['medName'],
      medMrp: json['medMrp'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      billNumber: json['billNumber'],
      medicineNumber: json['medicineNumber'],
    );
  }
}
