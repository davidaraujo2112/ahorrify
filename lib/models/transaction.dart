import 'package:intl/intl.dart';

/// Enum que define los tipos de transacción.
enum TransactionType {
  income,
  expense,
}

/// Modelo para representar una transacción financiera.
class Transaction {
  final int? id;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  /// Convierte la transacción en un mapa para SQLite o JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'category': category,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'note': note,
    };
  }

  /// Crea una instancia de Transacción desde un mapa.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  /// Métodos para trabajar con JSON directamente (opcional pero útil).
  Map<String, dynamic> toJson() => toMap();
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      Transaction.fromMap(json);

  /// Método utilitario para clonar objetos con cambios específicos.
  Transaction copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
