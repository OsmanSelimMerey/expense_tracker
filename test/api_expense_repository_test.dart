import 'dart:convert';
import 'dart:io';

import 'package:expense_tracker/features/expenses/data/repositories/api_expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'helpers/fakes.dart';

void main() {
  late Directory tempDir;
  late FakeApiClient api;
  late ApiExpenseRepository repository;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    api = FakeApiClient();
    repository = ApiExpenseRepository(api);
    if (await Hive.boxExists('expensesCacheBox')) {
      await Hive.deleteBoxFromDisk('expensesCacheBox');
    }
  });

  Expense sampleExpense({String id = ''}) => Expense(
        id: id,
        userId: 'user-1',
        amount: 42.5,
        category: 'Food',
        date: DateTime.parse('2026-07-22T10:00:00Z'),
        description: 'Groceries',
      );

  test('getExpenses parses API list and maps title to description', () async {
    api.handler = (method, path, body) => http.Response(
          jsonEncode([
            {
              'id': 'e1',
              'title': 'Groceries',
              'amount': 42.5,
              'date': '2026-07-22T10:00:00Z',
              'category': 'Food',
            }
          ]),
          200,
        );

    final result = await repository.getExpenses('user-1');

    expect(result, hasLength(1));
    expect(result.first.id, 'e1');
    expect(result.first.description, 'Groceries');
    expect(result.first.userId, 'user-1');
    expect(api.requests.single.path, '/expenses');
  });

  test('getExpenses falls back to cache when the API fails', () async {
    // First, a successful call populates the Hive cache.
    api.handler = (method, path, body) => http.Response(
          jsonEncode([
            {
              'id': 'cached-1',
              'title': 'Rent',
              'amount': 100.0,
              'date': '2026-07-01T00:00:00Z',
              'category': 'Housing',
            }
          ]),
          200,
        );
    await repository.getExpenses('user-1');

    // Then the API fails; the repository should return cached data.
    api.handler = (method, path, body) => http.Response('error', 500);
    final result = await repository.getExpenses('user-1');

    expect(result, hasLength(1));
    expect(result.first.id, 'cached-1');
    expect(result.first.description, 'Rent');
  });

  test('getExpenses returns empty list when API fails and no cache exists', () async {
    api.handler = (method, path, body) => http.Response('error', 500);

    final result = await repository.getExpenses('user-without-cache');

    expect(result, isEmpty);
  });

  test('addExpense POSTs to /expenses with title from description', () async {
    api.handler = (method, path, body) => http.Response('{}', 201);

    await repository.addExpense(sampleExpense());

    final request = api.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/expenses');
    final sent = request.body as Map<String, dynamic>;
    expect(sent['title'], 'Groceries');
    expect(sent['amount'], 42.5);
  });

  test('addExpense throws on non-success status', () async {
    api.handler = (method, path, body) => http.Response('bad', 400);

    await expectLater(repository.addExpense(sampleExpense()), throwsException);
  });

  test('updateExpense PUTs to /expenses/{id}', () async {
    api.handler = (method, path, body) => http.Response('', 204);

    await repository.updateExpense(sampleExpense(id: 'e9'));

    expect(api.requests.single.method, 'PUT');
    expect(api.requests.single.path, '/expenses/e9');
  });

  test('deleteExpense DELETEs /expenses/{id}', () async {
    api.handler = (method, path, body) => http.Response('', 204);

    await repository.deleteExpense('e5');

    expect(api.requests.single.method, 'DELETE');
    expect(api.requests.single.path, '/expenses/e5');
  });
}
