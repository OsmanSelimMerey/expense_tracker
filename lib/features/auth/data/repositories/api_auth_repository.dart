// lib/features/auth/data/repositories/api_auth_repository.dart

import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// [IAuthRepository] backed by the ASP.NET Core API.
///
/// On successful login the JWT is stored in [TokenStorage] (secure storage) and
/// the user id is returned to satisfy the existing contract. Register auto-logs
/// in afterwards because the API register endpoint does not return a token.
class ApiAuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ApiAuthRepository(this._apiClient, this._tokenStorage);

  @override
  Future<String> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      {'email': email, 'password': password},
      auth: false,
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final userId = user['id'].toString();

    await _tokenStorage.saveSession(token: token, userId: userId);
    return userId;
  }

  @override
  Future<String> register(String email, String password) async {
    // The API requires a name; derive a reasonable default from the email so
    // the existing (email, password) contract stays intact.
    final name = email.contains('@') ? email.split('@').first : email;

    final response = await _apiClient.post(
      '/auth/register',
      {'name': name, 'email': email, 'password': password},
      auth: false,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Register failed (${response.statusCode})');
    }

    // Register returns no token, so log in to obtain and persist one.
    return login(email, password);
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  @override
  String? getCurrentUserId() => _tokenStorage.userId;
}
