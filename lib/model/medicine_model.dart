class Medicine {
  final int medicineId;
  final String medicineName;
  final int medicinePack;
  final String medicineType;
  final double quantity;

  Medicine({
    required this.medicineId,
    required this.medicineName,
    required this.medicinePack,
    required this.medicineType,
    required this.quantity,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      medicinePack: json['medicinePack'],
      medicineType: json['medicineType'],
      quantity: json['quantity']?.toDouble(),
    );
  }
}

class LowStockMedicine {
  final int medicineId;
  final String medicineName;
  final int medicinePack;
  final String medicineType;
  final double quantity;

  LowStockMedicine({
    required this.medicineId,
    required this.medicineName,
    required this.medicinePack,
    required this.medicineType,
    required this.quantity,
  });

  factory LowStockMedicine.fromJson(Map<String, dynamic> json) {
    return LowStockMedicine(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      medicinePack: json['medicinePack'],
      medicineType: json['medicineType'],
      quantity: json['quantity'].toDouble(),
    );
  }
}

class MedicineInventory {
  final int medtransactionId;
  final String medicineName;
  final int medicineId;
  final int invoiceId;
  final String medicineBatch;
  final String expiry;
  final int medicinePack;
  final double quantity;
  final double availableQuantity;
  final double mrp;
  final double rate;
  final double amount;

  MedicineInventory({
    required this.medtransactionId,
    required this.medicineName,
    required this.medicineId,
    required this.invoiceId,
    required this.medicineBatch,
    required this.expiry,
    required this.medicinePack,
    required this.quantity,
    required this.availableQuantity,
    required this.mrp,
    required this.rate,
    required this.amount,
  });

  factory MedicineInventory.fromJson(Map<String, dynamic> json) {
    return MedicineInventory(
      medtransactionId: json['medtransactionId'],
      medicineName: json['medicineName'],
      medicineId: json['medicineId'],
      invoiceId: json['invoiceId'],
      medicineBatch: json['medicineBatch'],
      expiry: json['expiry'],
      medicinePack: json['medicinePack'],
      quantity: json['quantity'],
      availableQuantity: json['availableQuantity'],
      mrp: json['mrp'],
      rate: json['rate'],
      amount: json['amount'],
    );
  }
}
