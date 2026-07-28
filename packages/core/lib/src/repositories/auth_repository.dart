import 'dart:async';

import '../api/api_client.dart';
import '../models/profile.dart';

enum AuthState { signedIn, signedOut }

/// Giris artik gercek bir `username` sutunuyla yapiliyor (backend/schema.sql
/// users.username) - eski Supabase Auth'un e-posta zorunlulugunu asmak icin
/// kullanilan sentetik `kullaniciadi@dedemmekatronik.com` hilesine artik
/// gerek yok, bu yuzden ofis/yonetim ve sofor girisleri tek bir metotta
/// birlesti.
class AuthRepository {
  final _controller = StreamController<AuthState>.broadcast();

  Stream<AuthState> get onAuthStateChange => _controller.stream;

  Future<bool> hasSession() async => (await api.tokenStore.read()) != null;

  Future<void> signIn({required String username, required String password}) async {
    final data = await api.post('/auth_login.php', body: {
      'username': username,
      'password': password,
    }) as Map<String, dynamic>;
    await api.tokenStore.write(data['token'] as String);
    _controller.add(AuthState.signedIn);
  }

  Future<void> signOut() async {
    try {
      await api.post('/auth_logout.php');
    } catch (_) {
      // Token zaten gecersizse onemli degil, yerel token'i yine de temizleriz.
    }
    await api.tokenStore.clear();
    _controller.add(AuthState.signedOut);
  }

  /// Gecerli bir token yoksa ya da sunucu artik gecersiz sayiyorsa (401)
  /// null doner ve yerel token temizlenir - eski ayri session-check +
  /// profile-fetch adimlarini tek bir çağrıda birleştirir.
  Future<Profile?> fetchCurrentProfile() async {
    if (!await hasSession()) return null;
    try {
      final data = await api.get('/auth_me.php') as Map<String, dynamic>;
      return Profile.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await api.tokenStore.clear();
        _controller.add(AuthState.signedOut);
        return null;
      }
      rethrow;
    }
  }

  Future<void> updateOwnProfile({
    String? fullName,
    String? notificationEmail,
    bool? emailBildirimAktif,
  }) async {
    final payload = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (notificationEmail != null) 'notification_email': notificationEmail,
      if (emailBildirimAktif != null) 'email_bildirim_aktif': emailBildirimAktif,
    };
    if (payload.isEmpty) return;
    await api.post('/profile_update.php', body: payload);
  }

  Future<void> updatePassword(String yeniSifre) async {
    await api.post('/auth_change_password.php', body: {'password': yeniSifre});
  }
}
