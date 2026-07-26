import '../models/account.dart';
import '../models/enums.dart';
import '../supabase/supabase_config.dart';

/// Hesap yonetimi (sofor/onay verici/yonetici/admin girisleri). Tum
/// islemler `SECURITY DEFINER` Postgres fonksiyonlariyla (bkz.
/// supabase/functions_accounts.sql) yapilir; client hicbir zaman
/// service_role/secret key gormez, yetki kontrolu fonksiyonun icinde
/// cagiranin rolune gore yapilir.
class AccountRepository {
  Future<List<Account>> listAccounts() async {
    final rows = await supabase.rpc('admin_list_accounts');
    return (rows as List).cast<Map<String, dynamic>>().map(Account.fromJson).toList();
  }

  Future<String> createAccount({
    required String fullName,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    final id = await supabase.rpc('admin_create_account', params: {
      'p_full_name': fullName,
      'p_email': email,
      'p_password': password,
      'p_role': role.toJson(),
    });
    return id as String;
  }

  Future<void> updateAccount({
    required String userId,
    String? fullName,
    String? email,
    String? password,
    AppRole? role,
    bool? aktif,
  }) async {
    await supabase.rpc('admin_update_account', params: {
      'p_user_id': userId,
      if (fullName != null) 'p_full_name': fullName,
      if (email != null) 'p_email': email,
      if (password != null) 'p_password': password,
      if (role != null) 'p_role': role.toJson(),
      if (aktif != null) 'p_aktif': aktif,
    });
  }
}
