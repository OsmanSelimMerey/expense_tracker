// lib/features/expenses/domain/repositories/i_expense_repository.dart

import '../entities/expense.dart';

abstract class IExpenseRepository {
  // Harcamaları getirecek metot. (İleride Firebase'den mi, Mock'tan mı gelir burası bilmez)
  Future<List<Expense>> getExpenses(String userId);

  // Yeni harcama ekleme
  Future<void> addExpense(Expense expense);

  // Mevcut harcamayı güncelleme
  Future<void> updateExpense(Expense expense);

  // Harcamayı silme
  Future<void> deleteExpense(String id);
}