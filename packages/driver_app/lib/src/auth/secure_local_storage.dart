import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Sofor oturumunun tek seferlik giristen sonra kalici kalmasi icin
/// Supabase oturum tokenini varsayilan SharedPreferences yerine
/// isletim sisteminin guvenli depolamasinda (Keystore/Keychain) tutar.
class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage();

  static const _key = 'supabase.auth.session';
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    final value = await _storage.read(key: _key);
    return value != null;
  }

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);
}
