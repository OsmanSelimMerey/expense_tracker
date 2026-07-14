// lib/features/auth/presentation/pages/auth_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';
import '../../../expenses/presentation/controllers/expense_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  bool _isLogin = true; // Sayfa ilk açıldığında "Giriş Yap" modunda olsun

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Uyarı", "Lütfen tüm alanları doldurun.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    bool success;
    if (_isLogin) {
      success = await _authController.login(email, password);
    } else {
      success = await _authController.register(email, password);
    }

    if (success) {
      // ÇÖZÜM BURADA: Giriş başarılı olunca ExpenseController'a verileri yenilemesini söylüyoruz.
      Get.find<ExpenseController>().loadExpenses();

      Get.offAll(() => const ExpensesPage());
    } else {
      Get.snackbar(
        "Hata",
        _authController.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Obx(() => _authController.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
            )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin; // Modu değiştir
                });
              },
              child: Text(_isLogin ? 'Hesabın yok mu? Kayıt Ol' : 'Zaten hesabın var mı? Giriş Yap'),
            )
          ],
        ),
      ),
    );
  }
}