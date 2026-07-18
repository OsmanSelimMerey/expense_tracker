// lib/features/auth/presentation/pages/auth_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
// Sayfa yönlendirme ve ExpenseController ile işimiz kalmadığı için o importları sildik.

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  bool _isLogin = true; // Sadece arayüzün (UI) ne göstereceğini belirler

  // YENİ: Bellek sızıntısını (Memory Leak) önlemek için dispose eklendi
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // APTAL VIEW PRENSİBİ: View sadece kullanıcının girdiği saf metinleri
    // ve hangi butona bastığını (isLogin) Controller'a gönderir.
    // Hata gösterme, doğrulama veya sayfa değiştirme işini bilmez!
    _authController.submitAuthForm(
      email: _emailController.text,
      password: _passwordController.text,
      isLogin: _isLogin,
    );
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
                  _isLogin = !_isLogin; // Arayüz modunu değiştir
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