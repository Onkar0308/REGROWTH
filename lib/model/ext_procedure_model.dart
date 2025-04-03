class ExternalProcedure {
  final int doctorId;
  final String doctorName;
  final String procedureDate;
  final String procedureType;
  final String procedureDetail;
  final double feesCharged;
  final double discount;
  final double finalAmount;
  final String cashierName;
  final String timestamp;

  ExternalProcedure({
    required this.doctorId,
    required this.doctorName,
    required this.procedureDate,
    required this.procedureType,
    required this.procedureDetail,
    required this.feesCharged,
    required this.discount,
    required this.finalAmount,
    required this.cashierName,
    required this.timestamp,
  });

  factory ExternalProcedure.fromJson(Map<String, dynamic> json) {
    return ExternalProcedure(
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      procedureDate: json['procedureDate'],
      procedureType: json['procedureType'],
      procedureDetail: json['procedureDetail'],
      feesCharged: json['feesCharged'],
      discount: json['discount'],
      finalAmount: json['finalAmount'],
      cashierName: json['cashierName'],
      timestamp: json['timestamp'],
    );
  }
}
