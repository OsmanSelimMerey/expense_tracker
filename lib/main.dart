import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- Arayüzler (Interfaces) ---
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/expenses/domain/repositories/i_expense_repository.dart';

// --- YENİ API Repository'leri (İşte değişen TEK yer burası!) ---
import 'features/auth/data/repositories/api_auth_repository.dart'; // Bunu oluşturacağız
import 'features/expenses/data/repositories/api_expense_repository.dart';

// --- Controller'lar ---
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/expenses/presentation/controllers/expense_controller.dart';

// --- Sayfalar ---
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/expenses/presentation/pages/expenses_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Auth Repository'yi oluştur ve hafızadaki token'ı/kullanıcıyı yükle
  final apiAuthRepo = ApiAuthRepository();
  await apiAuthRepo.init(); // <-- GİZLİ KAHRAMAN BURASI (Kullanıcıyı hatırlar)

  Get.put<IAuthRepository>(apiAuthRepo);
  Get.put(AuthController(Get.find<IAuthRepository>()));

  // 2. Expense Bağımlılıkları
  Get.put<IExpenseRepository>(ApiExpenseRepository());
  Get.put(ExpenseController(Get.find<IExpenseRepository>(), Get.find<IAuthRepository>()));

  // 3. Kullanıcı Kontrolü
  final authRepo = Get.find<IAuthRepository>();
  final currentUserId = authRepo.getCurrentUserId();

  final Widget initialRoute = currentUserId != null ? const ExpensesPage() : const AuthPage();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final Widget initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // GetX için GetMaterialApp şart
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: initialRoute,
    );
  }
}