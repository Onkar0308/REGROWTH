class ExpenseModel {
  final String? id;
  final double cash_amount;
  final double online_amount;
  final String category;
  final String description;
  final DateTime date;

  ExpenseModel({
    this.id,
    required this.cash_amount,
    required this.online_amount,
    required this.category,
    required this.description,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString(),
      cash_amount: (json['cash_amount'] as num?)?.toDouble() ?? 0.0,
      online_amount: (json['online_amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'cash_amount': cash_amount,
      'online_amount': online_amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
    };
    
    if (id != null) {
      data['id'] = id;
    }
    
    return data;
  }

  // Helper method to get total amount
  double get totalAmount => cash_amount + online_amount;
}