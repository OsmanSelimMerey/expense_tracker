// lib/features/expenses/presentation/controllers/expense_controller.dart

import 'package:get/get.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart'; // Kullanıcıyı bilmemiz lazım

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

  // SADECE GİRİŞ YAPAN KULLANICININ VERİSİNİ ÇEK
  Future<void> loadExpenses() async {
    final userId = _authRepository.getCurrentUserId();
    if (userId == null) {
      viewState.value = ViewState.error;
      errorMessage.value = "Kullanıcı oturumu bulunamadı.";
      return;
    }

    try {
      viewState.value = ViewState.loading;
      errorMessage.value = '';

      final data = await _expenseRepository.getExpenses(userId);

      expenses.assignAll(data); // Listeyi güncelle

      if (expenses.isEmpty) {
        viewState.value = ViewState.empty;
      } else {
        viewState.value = ViewState.success;
      }
    } catch (e) {
      viewState.value = ViewState.error;
      errorMessage.value = "Harcamalar yüklenirken bir hata oluştu.";
    }
  }

  // TOPLAM TUTARI HESAPLA (GetX'in nimetlerinden biri: Computed özellik)
  double get totalExpense {
    return expenses.fold(0, (sum, item) => sum + item.amount);
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _expenseRepository.addExpense(expense);
      await loadExpenses(); // Listeyi yenile
    } catch (e) {
      print("🔥 EKLEME HATASI: $e");
      Get.snackbar("Hata", "Harcama eklenemedi.");
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _expenseRepository.updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      Get.snackbar("Hata", "Harcama güncellenemedi.");
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _expenseRepository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      Get.snackbar("Hata", "Harcama silinemedi.");
    }
  }
}