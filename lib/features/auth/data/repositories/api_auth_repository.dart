import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Proje ismin farklıysa (expense_tracker yerine) burayı güncellemeyi unutma:
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/features/auth/domain/repositories/i_auth_repository.dart';

class ApiAuthRepository implements IAuthRepository {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';

  String? _currentUserId;

  @override
  String? getCurrentUserId() {
    return _currentUserId;
  }

  Future<void> init() async {
    _currentUserId = await _secureStorage.read(key: _userIdKey);
  }

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/Auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userId = response.data['userId'] ?? email;

        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(key: _userIdKey, value: userId);

        _currentUserId = userId;
        return userId;
      } else {
        throw Exception('Giriş bilgileri hatalı.');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  @override
  Future<String> register(String email, String password) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/Auth/register',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Kayıt Başarılı";
      } else {
        throw Exception('Kayıt başarısız oldu.');
      }
    } catch (e) {
      throw Exception('Kayıt hatası: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    _currentUserId = null;
  }
}