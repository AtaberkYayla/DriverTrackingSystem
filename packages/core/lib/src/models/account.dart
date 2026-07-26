import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';

part 'account.g.dart';

/// `admin_list_accounts()` RPC'sinden donen, giris hesabi + profil bilgisini
/// birlikte tasiyan salt-okunur kayit. E-posta `profiles` tablosunda degil
/// `auth.users`'da tutuldugu icin normal [Profile] modeliyle degil, bu
/// RPC uzerinden okunur (bkz. AccountRepository).
@JsonSerializable(fieldRename: FieldRename.snake)
class Account {
  const Account({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.aktif,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final AppRole role;
  final bool aktif;
  final DateTime createdAt;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
