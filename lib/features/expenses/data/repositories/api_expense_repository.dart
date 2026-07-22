// lib/features/expenses/data/repositories/api_expense_repository.dart

import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../models/expense_dto.dart';

/// [IExpenseRepository] backed by the ASP.NET Core API.
///
/// The Hive offline cache behaviour mirrors the previous Firebase repository:
/// successful fetches refresh the cache, and network failures fall back to the
/// last cached data. The cache box name and key format are kept identical so
/// existing cached data remains valid.
class ApiExpenseRepository implements IExpenseRepository {
  final ApiClient _apiClient;
  final String _boxName = 'expensesCacheBox';

  ApiExpenseRepository(this._apiClient);

  @override
  Future<List<Expense>> getExpenses(String userId) async {
    final box = await Hive.openBox(_boxName);
    final cacheKey = 'cached_expenses_$userId';

    try {
      final response = await _apiClient.get('/expenses');
      if (response.statusCode != 200) {
        throw Exception('Failed to load expenses (${response.statusCode})');
      }

      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      final expenses = jsonList.map((json) {
        final dto =
            ExpenseDto.fromApiJson(Map<String, dynamic>.from(json), userId);
        return dto.toEntity();
      }).toList();

      final cacheData = expenses.map((e) {
        final dto = ExpenseDto.fromEntity(e);
        final map = dto.toMap();
        map['id'] = dto.id;
        return map;
      }).toList();

      await box.put(cacheKey, cacheData);

      return expenses;
    } catch (_) {
      final cachedData = box.get(cacheKey);
      if (cachedData != null) {
        final List<dynamic> rawList = cachedData;
        return rawList.map((data) {
          final dto = ExpenseDto.fromMap(
            data['id'],
            Map<String, dynamic>.from(data),
          );
          return dto.toEntity();
        }).toList();
      }
      return [];
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final dto = ExpenseDto.fromEntity(expense);
    final response = await _apiClient.post('/expenses', dto.toApiJson());
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add expense (${response.statusCode})');
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final dto = ExpenseDto.fromEntity(expense);
    final response = await _apiClient.put('/expenses/${dto.id}', dto.toApiJson());
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to update expense (${response.statusCode})');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    final response = await _apiClient.delete('/expenses/$id');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete expense (${response.statusCode})');
    }
  }
}
