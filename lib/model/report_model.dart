class Report {
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

  Report({
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

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      procedureId: json['procedureId'],
      patientId: json['patientId'],
      procedureDate: json['procedureDate'],
      procedureType: json['procedureType'],
      procedureDetail: json['procedureDetail'],
      cashPayment: (json['cashPayment'] as num).toDouble(),
      onlinePayment: (json['onlinePayment'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      clinicName: json['clinicName'],
      cashierName: json['cashierName'],
      timestamp: json['timestamp'],
    );
  }
}
