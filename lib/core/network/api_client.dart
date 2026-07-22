// lib/core/network/api_client.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

/// Thin HTTP wrapper that attaches the JWT as `Authorization: Bearer <token>`
/// on authenticated requests. The token is read from [TokenStorage] and is
/// never logged.
class ApiClient {
  final TokenStorage _tokenStorage;
  final http.Client _client;

  ApiClient(this._tokenStorage, {http.Client? client})
      : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Map<String, String> _headers({required bool auth}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = _tokenStorage.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool auth = true}) {
    return _client.get(_uri(path), headers: _headers(auth: auth));
  }

  Future<http.Response> post(String path, Object? body, {bool auth = true}) {
    return _client.post(
      _uri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String path, Object? body, {bool auth = true}) {
    return _client.put(
      _uri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, {bool auth = true}) {
    return _client.delete(_uri(path), headers: _headers(auth: auth));
  }
}
