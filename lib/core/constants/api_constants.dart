// lib/core/constants/api_constants.dart

/// Central API configuration.
///
/// Communication must go over HTTPS. Adjust [baseUrl] for your run target:
/// - Web / desktop / iOS simulator: https://localhost:7270/api
/// - Android emulator: https://10.0.2.2:7270/api
/// - Physical device: https://YOUR_MACHINE_IP:7270/api
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://localhost:7270/api';
}
