import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../supabase/supabase_config.dart';

/// Supabase Auth e-posta/parola ister; soforler icin "kullanici adi" UX'i
/// saglamak amaciyla kullanici adi, sabit bir alan adi eklenerek sentetik
/// bir e-postaya cevrilir (ör. "ahmet" -> "ahmet@dedemmekatronik.com").
/// Bu donusum sadece giris ekraninda kullanilir; kullanici adini gormez.
///
/// Dikkat: bu alan adi gercek sirket e-posta alan adiysa, bir soforun
/// kullanici adi mevcut bir personelin e-posta on-ekiyle ayni olursa
/// (ör. hem sofor hem ofis personeli "ahmet" ise) hesap catismasi olusur.
/// Sofor kullanici adlarini bu yuzden gercek personel e-postalariyla
/// carpismayacak sekilde secmek gerekir.
class AuthRepository {
  AuthRepository({this.usernameDomain = 'dedemmekatronik.com'});

  final String usernameDomain;

  String usernameToEmail(String username) =>
      '${username.trim().toLowerCase()}@$usernameDomain';

  Session? get currentSession => supabase.auth.currentSession;

  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;

  Future<AuthResponse> signInWithUsername({
    required String username,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(
      email: usernameToEmail(username),
      password: password,
    );
  }

  /// Yonetim web paneli icin: ofis/yonetim kullanicilari kendi e-postalari
  /// ile giris yapar (kullanici adi donusumu uygulanmaz).
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => supabase.auth.signOut();

  Future<Profile?> fetchCurrentProfile() async {
    final userId = currentSession?.user.id;
    if (userId == null) return null;
    final row = await supabase.from('profiles').select().eq('id', userId).maybeSingle();
    if (row == null) return null;
    return Profile.fromJson(row);
  }
}
