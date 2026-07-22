// lib/core/storage/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT and the authenticated user id.
///
/// The token is kept **only** in [FlutterSecureStorage] (never in Hive or
/// SharedPreferences). An in-memory copy is maintained so callers that need a
/// synchronous session lookup (e.g. `IAuthRepository.getCurrentUserId`) can read
/// it without awaiting. Call [init] once at startup to hydrate that copy.
class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';

  final FlutterSecureStorage _storage;

  String? _token;
  String? _userId;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> init() async {
    _token = await _storage.read(key: _tokenKey);
    _userId = await _storage.read(key: _userIdKey);
  }

  String? get token => _token;
  String? get userId => _userId;

  Future<void> saveSession({required String token, required String userId}) async {
    _token = token;
    _userId = userId;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<void> clear() async {
    _token = null;
    _userId = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
  }
}
