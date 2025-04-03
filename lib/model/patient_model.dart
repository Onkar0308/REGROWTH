class Patient {
  final int patientId;
  final String firstName;
  final String middleName;
  final String lastName;
  final int patientAge;
  final String patientGender;
  final String patientRegDate;
  final int patientMobile1;
  final int patientMobile2;
  final String patientMedicalHistory;
  final String cashierName;
  final String patientReports;
  final String timestamp;
  final List<dynamic>? patientprocedure;

  Patient({
    required this.patientId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.patientAge,
    required this.patientGender,
    required this.patientRegDate,
    required this.patientMobile1,
    required this.patientMobile2,
    required this.patientMedicalHistory,
    required this.cashierName,
    required this.patientReports,
    required this.timestamp,
    this.patientprocedure,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patientId'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      patientAge: json['patientAge'],
      patientGender: json['patientGender'],
      patientRegDate: json['patientRegDate'],
      patientMobile1: json['patientMobile1'] ?? 0,
      patientMobile2: json['patientMobile2'] ?? 0,
      patientMedicalHistory: json['patientMedicalHistory'],
      cashierName: json['cashierName'],
      patientReports: json['patientReports'],
      timestamp: json['timestamp'],
      patientprocedure: json['patientprocedure'] as List<dynamic>?,
    );
  }
}
