import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/token_store.dart';

/// backend/lib/response.php'nin ürettiği hata şeklini (`{"error": {"code",
/// "message"}}`) taşır - eski `PostgrestException` yakalamalarının yerini alır.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.code, this.message);

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenStore,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final TokenStore tokenStore;
  final http.Client _http;

  Future<Map<String, String>> _headers() async {
    final token = await tokenStore.read();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanQuery = <String, String>{
      for (final entry in (query ?? const {}).entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
    return Uri.parse('$baseUrl$path')
        .replace(queryParameters: cleanQuery.isEmpty ? null : cleanQuery);
  }

  dynamic _decode(http.Response response) {
    final Map<String, dynamic> body =
        response.body.isEmpty ? const {} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'];
    }
    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      response.statusCode,
      error?['code'] as String? ?? 'unknown_error',
      error?['message'] as String? ?? 'Bilinmeyen bir hata oluştu',
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final response = await _http.get(_uri(path, query), headers: await _headers());
    return _decode(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _http.post(
      _uri(path),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? query}) async {
    final response = await _http.delete(_uri(path, query), headers: await _headers());
    return _decode(response);
  }
}

ApiClient? _apiClient;

/// Tum repository'lerin kullandigi global istemci - eski `supabase` getter'inin
/// karsiligi. `initApiClient()` cagrilmadan kullanilirsa acik bir hata verir.
ApiClient get api {
  final client = _apiClient;
  if (client == null) {
    throw StateError('api kullanilmadan once initApiClient() cagrilmali');
  }
  return client;
}

/// Uygulama baslangicinda bir kere cagrilir (eski `initSupabase`'in yerini alir).
Future<void> initApiClient({
  required String baseUrl,
  required TokenStore tokenStore,
  http.Client? httpClient,
}) async {
  _apiClient = ApiClient(baseUrl: baseUrl, tokenStore: tokenStore, httpClient: httpClient);
}
