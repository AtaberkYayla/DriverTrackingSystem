import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Oturum token'ini tarayicinin guvenli depolamasinda tutar
/// (flutter_secure_storage web'de WebCrypto + IndexedDB kullanir).
class SecureTokenStore implements TokenStore {
  const SecureTokenStore();

  static const _key = 'auth_token';
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
