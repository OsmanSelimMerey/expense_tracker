import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// NOKTALAR YERİNE DİREKT PROJE İSMİYLE ÇAĞIRIYORUZ (KESİN ÇÖZÜM)
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/i_expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';

class ApiExpenseRepository implements IExpenseRepository {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiExpenseRepository() {
    _dio = Dio();

    // Her API isteğinden önce araya girip Token'ı ekliyoruz
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // 1. GET METODU
  @override
  Future<List<Expense>> getExpenses(String userId) async {
    final response = await _dio.get('${ApiConstants.baseUrl}/Expenses', queryParameters: {'userId': userId});

    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((e) => Expense.fromJson(e)).toList();
    }
    throw Exception('Veri çekilemedi');
  }

  // 2. ADD METODU
  @override
  Future<void> addExpense(Expense expense) async {
    await _dio.post('${ApiConstants.baseUrl}/Expenses', data: {
      'userId': expense.userId,
      'amount': expense.amount,
      'category': expense.category,
      'date': expense.date.toIso8601String(),
      'description': expense.description,
    });
  }

  // 3. DELETE METODU
  @override
  Future<void> deleteExpense(String id) async {
    await _dio.delete('${ApiConstants.baseUrl}/Expenses/$id');
  }

  // 4. UPDATE METODU
  @override
  Future<void> updateExpense(Expense expense) async {
    await _dio.put('${ApiConstants.baseUrl}/Expenses/${expense.id}', data: {
      'id': expense.id,
      'userId': expense.userId,
      'amount': expense.amount,
      'category': expense.category,
      'date': expense.date.toIso8601String(),
      'description': expense.description,
    });
  }
}