import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.status});
  final String message;
  final int? status;

  @override
  String toString() => message;
}

/// Stateless wrapper over the Hitha REST API. Unwraps the universal
/// `{success, status, message, data}` envelope and returns raw JSON `data`.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _storage = storage ?? const FlutterSecureStorage();

  final http.Client _client;
  final String baseUrl;
  final FlutterSecureStorage? _storage;
  static const _timeout = Duration(seconds: 12);
  static const _accessKey = 'hitha.doctor.accessToken';
  static const _refreshKey = 'hitha.doctor.refreshToken';

  String? _accessToken;
  String? _refreshToken;
  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  /// Restores session from secure hardware storage (Android Keystore / iOS Keychain)
  Future<void> restoreSession() async {
    try {
      _accessToken = await _storage?.read(key: _accessKey);
      _refreshToken = await _storage?.read(key: _refreshKey);
    } catch (_) {
      await clearSession();
    }
  }

  Future<void> setTokens({required String? accessToken, String? refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken ?? _refreshToken;
    if (_accessToken == null) return clearSession();
    try {
      await _storage?.write(key: _accessKey, value: _accessToken);
      if (_refreshToken != null) await _storage?.write(key: _refreshKey, value: _refreshToken);
    } catch (_) {}
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    try {
      await _storage?.delete(key: _accessKey);
      await _storage?.delete(key: _refreshKey);
    } catch (_) {}
  }

  Uri _uri(String path, [Map<String, Object?>? query]) {
    final q = <String, String>{
      for (final e in (query ?? const {}).entries)
        if (e.value != null && '${e.value}'.isNotEmpty) e.key: '${e.value}',
    };
    return Uri.parse('$baseUrl$path').replace(queryParameters: q.isEmpty ? null : q);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<dynamic> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _client.get(_uri(path, query), headers: _headers));

  Future<dynamic> post(String path, [Object? body]) =>
      _send(() => _client.post(_uri(path), headers: _headers, body: body == null ? null : jsonEncode(body)));

  Future<dynamic> patch(String path, Object body) =>
      _send(() => _client.patch(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> delete(String path) =>
      _send(() => _client.delete(_uri(path), headers: _headers));

  Future<dynamic> uploadFile(String path, {required String filePath}) => _send(() async {
        final req = http.MultipartRequest('POST', _uri(path))
          ..headers.addAll({if (_accessToken != null) 'Authorization': 'Bearer $_accessToken'})
          ..files.add(await http.MultipartFile.fromPath('file', filePath));
        return http.Response.fromStream(await _client.send(req));
      });

  Future<Uint8List> getBytes(String path) async {
    final res = await _withRefresh(() => _client.get(_uri(path), headers: _headers));
    if (res.statusCode >= 400) throw ApiException('Download failed (${res.statusCode})', status: res.statusCode);
    return res.bodyBytes;
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final res = await _withRefresh(request);
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    final envelope = body is Map<String, dynamic> ? body : null;
    if (res.statusCode >= 400 || envelope?['success'] == false) {
      throw ApiException(
        envelope?['message'] as String? ?? 'Request failed (${res.statusCode})',
        status: res.statusCode,
      );
    }
    return envelope != null && envelope.containsKey('data') ? envelope['data'] : body;
  }

  /// Retries once after rotating tokens via POST /auth/refresh on a 401
  Future<http.Response> _withRefresh(Future<http.Response> Function() request) async {
    var res = await request().timeout(_timeout);
    if (res.statusCode == 401 && _refreshToken != null && await _refresh()) {
      res = await request().timeout(_timeout);
    }
    return res;
  }

  Future<bool> _refresh() async {
    try {
      final res = await _client
          .post(_uri('/auth/refresh'),
              headers: {'Content-Type': 'application/json'}, body: jsonEncode({'refreshToken': _refreshToken}))
          .timeout(_timeout);
      if (res.statusCode >= 400) throw ApiException('Session refresh failed');
      final data = (jsonDecode(res.body) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      await setTokens(accessToken: data['accessToken'] as String?, refreshToken: data['refreshToken'] as String?);
      return _accessToken != null;
    } catch (_) {
      await clearSession();
      return false;
    }
  }
}
