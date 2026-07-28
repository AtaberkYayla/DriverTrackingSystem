/// Oturum token'inin platforma gore (guvenli depolama/tarayici) nasil
/// saklanacagini soyutlar. admin_web ve driver_app kendi implementasyonunu
/// saglar (ikisi de flutter_secure_storage kullanir).
abstract class TokenStore {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}
