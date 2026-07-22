import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;

/// In-memory [TokenStorage] that avoids the flutter_secure_storage platform
/// channel so repositories can be unit tested on the Dart VM.
class FakeTokenStorage extends TokenStorage {
  String? _token;
  String? _userId;

  @override
  Future<void> init() async {}

  @override
  String? get token => _token;

  @override
  String? get userId => _userId;

  @override
  Future<void> saveSession({required String token, required String userId}) async {
    _token = token;
    _userId = userId;
  }

  @override
  Future<void> clear() async {
    _token = null;
    _userId = null;
  }
}

/// [ApiClient] test double that records requests and returns canned responses.
class FakeApiClient extends ApiClient {
  FakeApiClient() : super(FakeTokenStorage());

  final List<({String method, String path, Object? body})> requests = [];
  http.Response Function(String method, String path, Object? body)? handler;

  http.Response _respond(String method, String path, Object? body) {
    requests.add((method: method, path: path, body: body));
    return handler?.call(method, path, body) ?? http.Response('', 200);
  }

  @override
  Future<http.Response> get(String path, {bool auth = true}) async =>
      _respond('GET', path, null);

  @override
  Future<http.Response> post(String path, Object? body, {bool auth = true}) async =>
      _respond('POST', path, body);

  @override
  Future<http.Response> put(String path, Object? body, {bool auth = true}) async =>
      _respond('PUT', path, body);

  @override
  Future<http.Response> delete(String path, {bool auth = true}) async =>
      _respond('DELETE', path, null);
}
