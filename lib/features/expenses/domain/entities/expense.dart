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
}