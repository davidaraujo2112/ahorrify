import 'package:intl/intl.dart';

enum TransactionType {
  income,
  expense,
}

class TransactionModel {
  final int? id;
  final double amount;
  final String title;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  TransactionModel({
    this.id,
    required this.amount,
    required this.title,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'title': title,
      'type': type.toString().split('.').last,
      'category': category,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      title: map['title'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  TransactionModel copyWith({
    int? id,
    double? amount,
    String? title,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
