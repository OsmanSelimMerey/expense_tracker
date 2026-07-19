import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/expense_repository.dart';
import '../models/expense.dart';

// Dosyanın ismiyle aynı olması gereken bu part satırı çok önemli!
part 'expense_provider.g.dart';

@riverpod
Future<List<Expense>> expenses(ExpensesRef ref) async {
  final repository = ExpenseRepository();
  return repository.fetchExpenses();
}