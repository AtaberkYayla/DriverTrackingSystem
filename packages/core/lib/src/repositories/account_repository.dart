import '../api/api_client.dart';
import '../models/account.dart';
import '../models/enums.dart';

/// Hesap yonetimi (sofor/onay verici/yonetici/admin girisleri). Eski
/// `SECURITY DEFINER` Postgres RPC'lerinin (supabase/functions_accounts.sql)
/// yerini backend/accounts_*.php alir - ayni yetki kurallari (yonetici/
/// admin hesabi olusturmak/duzenlemek icin admin sarti) sunucu tarafinda
/// aynen korunuyor.
class AccountRepository {
  Future<List<Account>> listAccounts() async {
    final rows = await api.get('/accounts_list.php') as List;
    return rows.cast<Map<String, dynamic>>().map(Account.fromJson).toList();
  }

  Future<String> createAccount({
    required String fullName,
    required String username,
    required String password,
    required AppRole role,
  }) async {
    final data = await api.post('/accounts_create.php', body: {
      'full_name': fullName,
      'username': username,
      'password': password,
      'role': role.toJson(),
    }) as Map<String, dynamic>;
    return data['id'] as String;
  }

  Future<void> updateAccount({
    required String userId,
    String? fullName,
    String? username,
    String? password,
    AppRole? role,
    bool? aktif,
  }) async {
    await api.post('/accounts_update.php', body: {
      'user_id': userId,
      if (fullName != null) 'full_name': fullName,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (role != null) 'role': role.toJson(),
      if (aktif != null) 'aktif': aktif,
    });
  }

  Future<void> deleteAccount(String userId) async {
    await api.delete('/accounts_delete.php', query: {'id': userId});
  }
}
