class Clinic {
  final int clinicId;
  final String clinicName;

  Clinic({required this.clinicId, required this.clinicName});

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
    );
  }
}
