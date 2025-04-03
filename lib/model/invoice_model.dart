class Invoice {
  final int invoiceId;
  final String invoiceNumber;
  final String purchaseDate;
  final String vendorName;
  final double totalAmount;

  Invoice({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.purchaseDate,
    required this.vendorName,
    required this.totalAmount,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceId: json['invoiceId'],
      invoiceNumber: json['inoviceNumber'] ?? '',
      purchaseDate: json['purchaseDate'] ?? '',
      vendorName: json['vendorName'] ?? '',
      totalAmount: json['totalAmount'],
    );
  }
}

class PurchaseDetail {
  final int medtransactionId;
  final String medicineName;
  final int medicineId;
  final int invoiceId;
  final String medicineBatch;
  final String expiry;
  final int medicinePack;
  final double quantity;
  final double mrp;
  final double rate;
  final double amount;

  PurchaseDetail({
    required this.medtransactionId,
    required this.medicineName,
    required this.medicineId,
    required this.invoiceId,
    required this.medicineBatch,
    required this.expiry,
    required this.medicinePack,
    required this.quantity,
    required this.mrp,
    required this.rate,
    required this.amount,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      medtransactionId: json['medtransactionId'],
      medicineName: json['medicineName'],
      medicineId: json['medicineId'],
      invoiceId: json['invoiceId'],
      medicineBatch: json['medicineBatch'],
      expiry: json['expiry'],
      medicinePack: json['medicinePack'],
      quantity: json['quantity'].toDouble(),
      mrp: json['mrp'].toDouble(),
      rate: json['rate'].toDouble(),
      amount: json['amount'].toDouble(),
    );
  }
}
