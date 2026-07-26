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

  /// Kullanicinin kendi profilini (ad, bildirim e-postasi, bildirim tercihi)
  /// guncellemesi icin. RLS zaten `id = auth.uid()` oldugunda izin veriyor,
  /// bu yuzden herhangi bir admin RPC'sine ihtiyac yok.
  Future<void> updateOwnProfile({
    String? fullName,
    String? notificationEmail,
    bool? emailBildirimAktif,
  }) async {
    final userId = currentSession?.user.id;
    if (userId == null) return;
    final payload = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (notificationEmail != null) 'notification_email': notificationEmail,
      if (emailBildirimAktif != null) 'email_bildirim_aktif': emailBildirimAktif,
    };
    if (payload.isEmpty) return;
    await supabase.from('profiles').update(payload).eq('id', userId);
  }

  /// Kullanicinin kendi sifresini degistirmesi icin (kendi oturumuyla,
  /// admin RPC'sine gerek yok - Supabase Auth'un kendi client metodu).
  Future<void> updatePassword(String yeniSifre) async {
    await supabase.auth.updateUser(UserAttributes(password: yeniSifre));
  }
}
