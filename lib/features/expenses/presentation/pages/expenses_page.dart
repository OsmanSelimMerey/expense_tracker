// lib/features/expenses/presentation/pages/expenses_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import 'expense_form_page.dart';

class ExpensesPage extends StatelessWidget { // ConsumerWidget YERİNE StatelessWidget
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) { // WidgetRef ref SİLİNDİ
    final controller = Get.find<ExpenseController>();
    // ... geri kalanı tamamen aynı, hiçbir şeye DOKUNMA!

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcamalarım'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Obx(() => Text(
                'Toplam: ₺${controller.totalExpense.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // GETX İLE 4 FARKLI DURUMUN (STATE) YÖNETİMİ
        switch (controller.viewState.value) {

        // 1. DURUM: YÜKLENİYOR
          case ViewState.loading:
            return const Center(child: CircularProgressIndicator());

        // 2. DURUM: HATA
          case ViewState.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadExpenses(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );

        // 3. DURUM: BOŞ LİSTE (Henüz kayıt yok)
          case ViewState.empty:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Henüz harcama yok.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Get.to(() => const ExpenseFormPage()),
                    child: const Text('Harcama Eklemek İster Misin?'),
                  )
                ],
              ),
            );

        // 4. DURUM: BAŞARILI (Listeyi Göster)
          case ViewState.success:
            return ListView.builder(
              itemCount: controller.expenses.length,
              itemBuilder: (context, index) {
                final expense = controller.expenses[index];

                // SAĞDAN SOLA KAYDIRARAK SİLME ÖZELLİĞİ
                return Dismissible(
                  key: Key(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    controller.deleteExpense(expense.id);
                    Get.snackbar(
                      'Silindi',
                      'Harcama başarıyla silindi.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: ListTile(
                    title: Text(expense.category),
                    subtitle: Text('${expense.date.day}/${expense.date.month}/${expense.date.year} - ${expense.description}'),
                    trailing: Text('₺${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onTap: () => Get.to(() => ExpenseFormPage(expenseToEdit: expense)),
                  ),
                );
              },
            );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const ExpenseFormPage()),
        child: const Icon(Icons.add),
      ),
    );
  }
}