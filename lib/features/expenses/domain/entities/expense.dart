// lib/features/expenses/domain/entities/expense.dart

class Expense {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  // YENİ EKLENEN KISIM: Veriyi Firestore'a kaydetmek için (Object to Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  // YENİ EKLENEN KISIM: Veriyi Firestore'dan okumak için (Map to Object)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
      description: map['description'] ?? '',
    );
  }
}