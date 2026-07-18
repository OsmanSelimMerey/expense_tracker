// lib/features/expenses/presentation/controllers/expense_controller.dart

import 'package:get/get.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';

enum ViewState { loading, empty, error, success }

class ExpenseController extends GetxController {
  final IExpenseRepository _expenseRepository;
  final IAuthRepository _authRepository;

  ExpenseController(this._expenseRepository, this._authRepository);

  // Observable Değişkenler (UI bu değişiklikleri dinleyecek)
  var viewState = ViewState.loading.obs;
  var expenses = <Expense>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses(); // Controller ayağa kalkarken verileri çek
  }

  // EKSİK OLAN VE DURUMLARI YÖNETEN ANA METOT
  Future<void> loadExpenses() async {
    try {
      viewState.value = ViewState.loading;
      final userId = _authRepository.getCurrentUserId();

      if (userId == null) {
        throw Exception("Kullanıcı bulunamadı");
      }

      final data = await _expenseRepository.getExpenses(userId);

      if (data.isEmpty) {
        viewState.value = ViewState.empty;
      } else {
        expenses.value = data;
        viewState.value = ViewState.success;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      viewState.value = ViewState.error;
    }
  }

  // --- YENİ EKLENEN AKILLI KAYDETME METODU ---
  Future<void> saveExpense({
    String? existingId,
    required String amountText,
    required String category,
    required DateTime date,
    required String description,
  }) async {
    try {
      // 1. Virgül sorununu çöz (12,50 girilirse 12.50 yap) ve sayıya çevir
      final cleanAmountText = amountText.replaceAll(',', '.');
      final amount = double.parse(cleanAmountText);

      // 2. Giriş yapan kullanıcının ID'sini kendi repository'nden al
      final userId = _authRepository.getCurrentUserId();
      if (userId == null) throw Exception("Kullanıcı bulunamadı!");

      // 3. Domain Entity'sini (Expense) oluştur (İş mantığı burada)
      final expense = Expense(
        id: existingId ?? '', // Yeni kayıtsa boş bırak, Firebase kendi ID atayacak
        userId: userId,
        amount: amount,
        category: category,
        date: date,
        description: description,
      );

      // 4. Duruma göre Ekle veya Güncelle
      if (existingId == null || existingId.isEmpty) {
        await _expenseRepository.addExpense(expense);
      } else {
        await _expenseRepository.updateExpense(expense);
      }

      // 5. Listeyi yenile ve başarı mesajı göster
      await loadExpenses();
      Get.back(); // Form sayfasını kapat
      Get.snackbar('Başarılı', 'Harcama kaydedildi.', snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      // Sayıya çevirme hatası veya başka bir hata olursa View çökmez, mesaj gösteririz
      print("🔥 KAYDETME HATASI: $e");
      Get.snackbar('Hata', 'Lütfen geçerli bir tutar girin.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // TOPLAM TUTARI HESAPLA
  double get totalExpense {
    return expenses.fold(0, (sum, item) => sum + item.amount);
  }

  // SİLME METODU
  Future<void> deleteExpense(String id) async {
    try {
      await _expenseRepository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      Get.snackbar("Hata", "Harcama silinemedi.");
    }
  }
}