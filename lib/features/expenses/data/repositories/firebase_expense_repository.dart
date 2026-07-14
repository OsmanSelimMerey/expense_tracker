import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../../domain/entities/expense.dart';

class FirebaseExpenseRepository implements IExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _boxName = 'expensesCacheBox'; // Hive kutumuzun adı

  @override
  Future<List<Expense>> getExpenses(String userId) async {
    // Hive kutusunu açıyoruz
    final box = await Hive.openBox(_boxName);
    final cacheKey = 'cached_expenses_$userId';

    try {
      // 1. ADIM: İNTERNET VAR MI DİYE FIREBASE'DEN ÇEKMEYİ DENE
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();

      final expenses = snapshot.docs.map((doc) {
        final data = doc.data();

        // YENİ EKLENEN GÜVENLİ TARİH KONTROLÜ
        DateTime parsedDate;
        if (data['date'] is Timestamp) {
          parsedDate = (data['date'] as Timestamp).toDate();
        } else {
          parsedDate = DateTime.parse(data['date'].toString());
        }

        return Expense(
          id: doc.id,
          userId: data['userId'],
          amount: data['amount'].toDouble(),
          category: data['category'],
          date: parsedDate, // Güvenli tarihi buraya veriyoruz
          description: data['description'] ?? '',
        );
      }).toList();
      // 2. ADIM: BAŞARILIYSA YENİ VERİYİ HIVE'A (ÖNBELLEĞE) KAYDET
      // Sınıfı doğrudan kaydedemediğimiz için Map (Sözlük) yapısına çeviriyoruz
      final cacheData = expenses.map((e) => {
        'id': e.id,
        'userId': e.userId,
        'amount': e.amount,
        'category': e.category,
        'date': e.date.toIso8601String(), // Tarihi metne çeviriyoruz
        'description': e.description,
      }).toList();

      await box.put(cacheKey, cacheData);

      return expenses;

    } catch (e) {
      print("🔥 FIREBASE HATA YAKALANDI: $e");
      // 3. ADIM: İNTERNET YOKSA VEYA HATA OLURSA HIVE'DAN (YERELDEN) OKU
      final cachedData = box.get(cacheKey);

      if (cachedData != null) {
        final List<dynamic> rawList = cachedData;
        return rawList.map((data) => Expense(
          id: data['id'],
          userId: data['userId'],
          amount: data['amount'],
          category: data['category'],
          date: DateTime.parse(data['date']),
          description: data['description'],
        )).toList();
      }

      // Eğer cihazda kayıtlı hiçbir şey yoksa (ilk giriş ve internet yok) boş liste dön
      return [];
    }
  }

  // --- Aşağıdaki ekleme, silme, güncelleme metodları aynen kalıyor ---

  @override
  Future<void> addExpense(Expense expense) async {
    await _firestore.collection('expenses').doc(expense.id).set({
      'userId': expense.userId,
      'amount': expense.amount,
      'category': expense.category,
      'date': expense.date,
      'description': expense.description,
    });
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await _firestore.collection('expenses').doc(expense.id).update({
      'amount': expense.amount,
      'category': expense.category,
      'date': expense.date,
      'description': expense.description,
    });
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }
}