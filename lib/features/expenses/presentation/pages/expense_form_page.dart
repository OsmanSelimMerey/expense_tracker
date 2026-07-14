// lib/features/expenses/presentation/pages/expense_form_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/expense_controller.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/entities/expense.dart';

class ExpenseFormPage extends StatefulWidget {
  final Expense? expenseToEdit;

  const ExpenseFormPage({super.key, this.expenseToEdit});

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late DateTime _selectedDate;

  final List<String> _categories = ['Yemek', 'Ulaşım', 'Fatura', 'Market', 'Diğer'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expenseToEdit?.amount.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.expenseToEdit?.description ?? '');
    _selectedCategory = widget.expenseToEdit?.category ?? _categories.first;
    _selectedDate = widget.expenseToEdit?.date ?? DateTime.now();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final authRepo = Get.find<IAuthRepository>();
      final currentUserId = authRepo.getCurrentUserId();

      if (currentUserId == null) {
        Get.snackbar('Hata', 'Kullanıcı oturumu bulunamadı.');
        return;
      }

      final expense = Expense(
        id: widget.expenseToEdit?.id ?? Uuid().v4(),
        userId: currentUserId, // EN KRİTİK NOKTA: Gerçek kullanıcının ID'si eklendi
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text,
      );

      final controller = Get.find<ExpenseController>();

      if (widget.expenseToEdit == null) {
        controller.addExpense(expense);
      } else {
        controller.updateExpense(expense);
      }

      Get.back(); // Ana sayfaya dön
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseToEdit == null ? 'Yeni Harcama Ekle' : 'Harcamayı Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Tutar (₺)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Lütfen bir tutar girin' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama (Opsiyonel)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Kaydet'),
              )
            ],
          ),
        ),
      ),
    );
  }
}