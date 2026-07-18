// lib/features/auth/presentation/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../../expenses/presentation/controllers/expense_controller.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';

class AuthController extends GetxController {
  final IAuthRepository _authRepository;

  AuthController(this._authRepository);

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // --- YENİ EKLENEN AKILLI FORM YÖNETİM METODU ---
  Future<void> submitAuthForm({
    required String email,
    required String password,
    required bool isLogin,
  }) async {
    // 1. Boşlukları temizle
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    // 2. Doğrulama (Validation) işlemleri
    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      Get.snackbar("Uyarı", "Lütfen tüm alanları doldurun.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 3. Giriş mi Kayıt mı? Karar ver ve çalıştır
    bool success;
    if (isLogin) {
      success = await login(cleanEmail, cleanPassword);
    } else {
      success = await register(cleanEmail, cleanPassword);
    }

    // 4. Sonuca göre Yönlendirme ve Veri Yükleme
    if (success) {
      // Giriş başarılı olunca ExpenseController'a verileri yenilemesini söylüyoruz
      Get.find<ExpenseController>().loadExpenses();

      // Harcamalar sayfasına yönlendir
      Get.offAll(() => const ExpensesPage());
    } else {
      // Hata durumunda mesajı göster
      Get.snackbar(
        "Hata",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.login(email, password);
      return true;
    } catch (e) {
      errorMessage.value = "Giriş başarısız: Bilgilerinizi kontrol edin.";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.register(email, password);
      return true;
    } catch (e) {
      errorMessage.value = "Kayıt başarısız: Şifre zayıf veya e-posta kullanımda olabilir.";
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}