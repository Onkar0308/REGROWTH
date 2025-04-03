class Appointment {
  final int appointmentId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String treatment;
  final String startTime;
  final String appointmentDate;
  final int patientMobile;
  final String cashierName;
  final String timestamp;

  Appointment({
    required this.appointmentId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.treatment,
    required this.startTime,
    required this.appointmentDate,
    required this.patientMobile,
    required this.cashierName,
    required this.timestamp,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      treatment: json['treatment'],
      startTime: json['startTime'],
      appointmentDate: json['appointmentDate'] ?? '',
      patientMobile: json['patientmobile1'],
      cashierName: json['cashiername'],
      timestamp: json['timestamp'],
    );
  }
}
