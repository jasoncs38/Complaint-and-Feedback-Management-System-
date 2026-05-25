import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  static const _tokenKey = 'auth_token';
  String? _token;
  String? get token => _token;

  Uri _u(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    final qp = query?.map((k, v) => MapEntry(k, v.toString()));
    return base.replace(
      path: (base.path + path).replaceAll('//', '/'),
      queryParameters: (qp == null || qp.isEmpty) ? null : qp,
    );
  }

  Map<String, String> _headers({bool json = false}) {
    final h = <String, String>{
      'Accept': 'application/json',
      // Bypass the ngrok-free interstitial page so JSON always comes back.
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'complaint-admin-app',
    };
    if (json) h['Content-Type'] = 'application/json';
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  Future<void> loadToken() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString(_tokenKey);
  }

  Future<void> setToken(String? t) async {
    _token = t;
    final sp = await SharedPreferences.getInstance();
    if (t == null || t.isEmpty) {
      await sp.remove(_tokenKey);
    } else {
      await sp.setString(_tokenKey, t);
    }
  }

  dynamic _decode(http.Response r) {
    final body = r.body.isEmpty ? null : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    String msg = 'HTTP ${r.statusCode}';
    if (body is Map && body['detail'] != null) {
      msg = body['detail'].toString();
    } else if (body is Map && body['message'] != null) {
      msg = body['message'].toString();
    }
    throw ApiException(r.statusCode, msg);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final r = await http.get(_u(path, query), headers: _headers());
    return _decode(r);
  }

  Future<dynamic> post(String path, Object? body) async {
    final r = await http.post(
      _u(path),
      headers: _headers(json: true),
      body: jsonEncode(body ?? const {}),
    );
    return _decode(r);
  }

  Future<dynamic> patch(String path, Object? body) async {
    final r = await http.patch(
      _u(path),
      headers: _headers(json: true),
      body: jsonEncode(body ?? const {}),
    );
    return _decode(r);
  }

  Future<dynamic> delete(String path) async {
    final r = await http.delete(_u(path), headers: _headers());
    return _decode(r);
  }

  Future<dynamic> postMultipart(
    String path,
    Map<String, String> fields, {
    File? file,
    String fileField = 'attachment',
  }) async {
    final req = http.MultipartRequest('POST', _u(path));
    req.headers.addAll(_headers());
    req.fields.addAll(fields);
    if (file != null) {
      req.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    }
    final streamed = await req.send();
    final r = await http.Response.fromStream(streamed);
    return _decode(r);
  }
}
