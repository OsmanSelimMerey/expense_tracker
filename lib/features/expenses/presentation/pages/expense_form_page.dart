// lib/features/expenses/presentation/pages/expense_form_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../../domain/entities/expense.dart';
// uuid ve i_auth_repository importlarını sildik, çünkü view'ın bunlarla işi yok!

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

  // YENİ: BELLEK TEMİZLİĞİ (Memory Leak engellemek için)
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // YENİ: TARİH SEÇİCİ FONKSİYONU
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<ExpenseController>();

      // APTAL VIEW PRENSİBİ: Bütün iş mantığı (Entity yaratma, UUID üretme, Auth, if/else)
      // Controller'a devredildi. View sadece kullanıcının girdiği saf metinleri yolluyor!
      controller.saveExpense(
        existingId: widget.expenseToEdit?.id, // Yeniyse null gider, Controller bunu anlar
        amountText: _amountController.text,
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text,
      );
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
                decoration: const InputDecoration(labelText: 'Tutar (₺) (örn: 12.50 veya 12,50)'),
                // Klavyede virgül ve noktanın çıkması için "decimal: true" eklendi
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 16),

              // YENİ: TARİH SEÇİCİ TASARIMI
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Tarih: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Tarih Seç'),
                  )
                ],
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