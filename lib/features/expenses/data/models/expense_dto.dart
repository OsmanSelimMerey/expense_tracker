// lib/features/expenses/data/models/expense_dto.dart

import '../../domain/entities/expense.dart';

class ExpenseDto {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final int dateMilliseconds; // Tarihi milisaniye (int) olarak tutacağız
  final String description;

  ExpenseDto({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.dateMilliseconds,
    required this.description,
  });

  // 1. Firebase/Hive'dan gelen Map'i DTO'ya çevirir
  factory ExpenseDto.fromMap(String documentId, Map<String, dynamic> map) {
    return ExpenseDto(
      id: documentId,
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      dateMilliseconds: map['date'] ?? 0,
      description: map['description'] ?? '',
    );
  }

  // 2. DTO'yu Firebase/Hive'a yazılacak Map'e çevirir
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'date': dateMilliseconds,
      'description': description,
    };
  }

  // 3. DTO'yu saf Domain Entity'sine (Expense) çevirir
  Expense toEntity() {
    return Expense(
      id: id,
      userId: userId,
      amount: amount,
      category: category,
      date: DateTime.fromMillisecondsSinceEpoch(dateMilliseconds),
      description: description, // Hatanın çözüldüğü kısım!
    );
  }

  // 4. Saf Domain Entity'sini (Expense) DTO'ya çevirir
  factory ExpenseDto.fromEntity(Expense expense) {
    return ExpenseDto(
      id: expense.id,
      userId: expense.userId,
      amount: expense.amount,
      category: expense.category,
      dateMilliseconds: expense.date.millisecondsSinceEpoch,
      description: expense.description,
    );
  }
}