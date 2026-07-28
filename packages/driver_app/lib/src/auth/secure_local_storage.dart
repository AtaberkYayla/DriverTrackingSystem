import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Sofor oturumunun tek seferlik giristen sonra kalici kalmasi icin oturum
/// token'ini isletim sisteminin guvenli depolamasinda (Android Keystore) tutar.
class SecureLocalStorage implements TokenStore {
  const SecureLocalStorage();

  static const _key = 'auth_token';
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
