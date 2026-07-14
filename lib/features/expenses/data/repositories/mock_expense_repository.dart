// lib/features/expenses/data/repositories/mock_expense_repository.dart

import 'dart:math';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/i_expense_repository.dart';

class MockExpenseRepository implements IExpenseRepository {
  // In-memory list to act as our fake database
  final List<Expense> _mockDatabase = [];
  final _random = Random();

  @override
  Future<List<Expense>> getExpenses(String userId) async {
    // Simulate a 2-second network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a random network error (20% chance) to test the error state
    if (_random.nextDouble() < 0.2) {
      throw Exception('Network error occurred while fetching expenses.');
    }

    // Return expenses filtered by userId
    return _mockDatabase.where((e) => e.userId == userId).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockDatabase.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockDatabase.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _mockDatabase[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockDatabase.removeWhere((e) => e.id == id);
  }
}