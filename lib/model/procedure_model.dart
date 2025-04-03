class Procedure {
  final int procedureId;
  final int patientId;
  final String procedureDate;
  final String procedureType;
  final String procedureDetail;
  final double cashPayment;
  final double onlinePayment;
  final double totalAmount;
  final double discount;
  final double finalAmount;
  final String clinicName;
  final String cashierName;
  final String timestamp;

  Procedure({
    required this.procedureId,
    required this.patientId,
    required this.procedureDate,
    required this.procedureType,
    required this.procedureDetail,
    required this.cashPayment,
    required this.onlinePayment,
    required this.totalAmount,
    required this.discount,
    required this.finalAmount,
    required this.clinicName,
    required this.cashierName,
    required this.timestamp,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      procedureId: json['procedureId'] ?? 0,
      patientId: json['patientId'] ?? 0,
      procedureDate: json['procedureDate'] ?? '',
      procedureType: json['procedureType'] ?? '',
      procedureDetail: json['procedureDetail'] ?? '',
      cashPayment: (json['cashPayment'] ?? 0.0).toDouble(),
      onlinePayment: (json['onlinePayment'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0.0).toDouble(),
      clinicName: json['clinicName'] ?? '',
      cashierName: json['cashierName'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
