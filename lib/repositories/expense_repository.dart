import 'package:dio/dio.dart';
import '../constants.dart'; // Az önce oluşturduğumuz dosyayı import ediyoruz.
import '../models/expense.dart'; // Senin harcama modelin.

class ExpenseRepository {
  final Dio _dio = Dio();

  Future<List<Expense>> fetchExpenses() async {
    try {
      // API'ye GET isteği atıyoruz
      final response = await _dio.get('${ApiConstants.baseUrl}/Expenses');

      if (response.statusCode == 200) {
        // Gelen veriyi Listeye dönüştürüyoruz
        final List data = response.data;
        return data.map((e) => Expense.fromJson(e)).toList();
      } else {
        throw Exception('Veriler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print("Hata: $e");
      throw Exception('Bağlantı hatası: $e');
    }
  }
}