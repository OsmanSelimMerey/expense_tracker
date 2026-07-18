// lib/features/expenses/data/repositories/firebase_expense_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../models/expense_dto.dart'; // DTO'yu import ettik

class FirebaseExpenseRepository implements IExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _boxName = 'expensesCacheBox';

  @override
  Future<List<Expense>> getExpenses(String userId) async {
    final box = await Hive.openBox(_boxName);
    final cacheKey = 'cached_expenses_$userId';

    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();

      // DTO kullanarak Firestore'dan okuma
      final expenses = snapshot.docs.map((doc) {
        final dto = ExpenseDto.fromMap(doc.id, doc.data());
        return dto.toEntity();
      }).toList();

      // DTO kullanarak Hive'a kaydetme
      final cacheData = expenses.map((e) {
        final dto = ExpenseDto.fromEntity(e);
        var map = dto.toMap();
        map['id'] = dto.id; // Hive için ID'yi de map'e ekliyoruz
        return map;
      }).toList();

      await box.put(cacheKey, cacheData);

      return expenses;

    } catch (e) {
      print("🔥 AĞ HATASI / HIVE DEVREDE: $e");
      final cachedData = box.get(cacheKey);

      if (cachedData != null) {
        final List<dynamic> rawList = cachedData;
        return rawList.map((data) {
          final dto = ExpenseDto.fromMap(data['id'], Map<String, dynamic>.from(data));
          return dto.toEntity();
        }).toList();
      }
      return [];
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final dto = ExpenseDto.fromEntity(expense);
    // Yeni eklemede ID'yi Firebase kendi oluşturacağı için boş bir döküman referansı alıyoruz
    await _firestore.collection('expenses').add(dto.toMap());
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final dto = ExpenseDto.fromEntity(expense);
    await _firestore.collection('expenses').doc(dto.id).update(dto.toMap());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }
}