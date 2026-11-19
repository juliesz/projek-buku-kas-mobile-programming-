class TransactionItem {
  final String? id;
  final String title;
  final int amount;
  final bool isIncome;
  final DateTime date;

  TransactionItem({
    this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id']?.toString(),
      title: json['title'] as String,
      amount: (json['amount'] as num).toInt(),
      isIncome: json['isIncome'] as bool,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
    };
  }
}