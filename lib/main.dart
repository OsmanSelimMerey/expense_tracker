// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Core (network & secure storage)
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';

// Auth Importları
import 'features/auth/data/repositories/api_auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/auth_page.dart';

// Expense Importları
import 'features/expenses/data/repositories/api_expense_repository.dart';
import 'features/expenses/domain/repositories/i_expense_repository.dart';
import 'features/expenses/presentation/controllers/expense_controller.dart';
import 'features/expenses/presentation/pages/expenses_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 0. Paylaşılan servisler: token deposu (secure storage) ve HTTP istemcisi
  final tokenStorage = TokenStorage();
  await tokenStorage.init();
  Get.put<TokenStorage>(tokenStorage);
  Get.put<ApiClient>(ApiClient(tokenStorage));

  // 1. Auth Bağımlılıkları (Önce Repository, sonra Controller)
  Get.put<IAuthRepository>(
    ApiAuthRepository(Get.find<ApiClient>(), Get.find<TokenStorage>()),
  );
  Get.put(AuthController(Get.find<IAuthRepository>()));

// 2. Expense Bağımlılıkları (Önce Repository, sonra Controller)
  Get.put<IExpenseRepository>(ApiExpenseRepository(Get.find<ApiClient>()));
  Get.put(ExpenseController(Get.find<IExpenseRepository>(), Get.find<IAuthRepository>()));

  // 3. Kullanıcı daha önce giriş yapmış mı kontrol et
  final authRepo = Get.find<IAuthRepository>();
  final currentUserId = authRepo.getCurrentUserId();

  // Eğer id varsa direkt içeri al, yoksa AuthPage'e at
  final Widget initialRoute = currentUserId != null ? const ExpensesPage() : const AuthPage();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final Widget initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: initialRoute,
    );
  }
}