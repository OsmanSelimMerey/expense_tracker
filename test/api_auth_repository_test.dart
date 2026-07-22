import 'dart:convert';

import 'package:expense_tracker/features/auth/data/repositories/api_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'helpers/fakes.dart';

void main() {
  late FakeApiClient api;
  late FakeTokenStorage storage;
  late ApiAuthRepository repository;

  setUp(() {
    api = FakeApiClient();
    storage = FakeTokenStorage();
    repository = ApiAuthRepository(api, storage);
  });

  String loginBody() => jsonEncode({
        'token': 'jwt-token-123',
        'user': {'id': 'user-42', 'name': 'Test', 'email': 'a@b.com'},
      });

  test('login stores token + userId and returns userId', () async {
    api.handler = (method, path, body) => http.Response(loginBody(), 200);

    final userId = await repository.login('a@b.com', 'secret');

    expect(userId, 'user-42');
    expect(storage.token, 'jwt-token-123');
    expect(storage.userId, 'user-42');
    expect(api.requests.single.path, '/auth/login');
    expect(api.requests.single.method, 'POST');
  });

  test('login throws on non-200 and does not store a token', () async {
    api.handler = (method, path, body) => http.Response('bad', 401);

    await expectLater(repository.login('a@b.com', 'wrong'), throwsException);
    expect(storage.token, isNull);
  });

  test('register posts to register then logs in, deriving name from email', () async {
    api.handler = (method, path, body) {
      if (path == '/auth/register') return http.Response('{}', 201);
      return http.Response(loginBody(), 200);
    };

    final userId = await repository.register('john.doe@example.com', 'secret');

    expect(userId, 'user-42');
    expect(storage.token, 'jwt-token-123');
    expect(api.requests.length, 2);
    expect(api.requests[0].path, '/auth/register');
    expect(api.requests[1].path, '/auth/login');

    final registerBody = api.requests[0].body as Map<String, dynamic>;
    expect(registerBody['name'], 'john.doe');
    expect(registerBody['email'], 'john.doe@example.com');
  });

  test('logout clears the stored session', () async {
    await storage.saveSession(token: 't', userId: 'u');

    await repository.logout();

    expect(storage.token, isNull);
    expect(storage.userId, isNull);
  });

  test('getCurrentUserId reflects stored session synchronously', () async {
    expect(repository.getCurrentUserId(), isNull);
    await storage.saveSession(token: 't', userId: 'user-7');
    expect(repository.getCurrentUserId(), 'user-7');
  });
}
