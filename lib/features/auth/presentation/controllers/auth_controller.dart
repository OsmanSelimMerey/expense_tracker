import 'package:get/get.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthController extends GetxController {
  final IAuthRepository _authRepository;

  AuthController(this._authRepository);

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.login(email, password);
      return true;
    } catch (e) {
      errorMessage.value = "Giriş başarısız: Bilgilerinizi kontrol edin.";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.register(email, password);
      return true;
    } catch (e) {
      errorMessage.value = "Kayıt başarısız: Şifre zayıf veya e-posta kullanımda olabilir.";
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}