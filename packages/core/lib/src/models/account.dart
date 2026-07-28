import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';

part 'account.g.dart';

/// `/accounts_list.php`'den donen hesap kaydi. Giris artik gercek bir
/// `username` sutunuyla yapiliyor (bkz. AuthRepository), bu yuzden eski
/// `email` alani yerini `username`a birakti.
@JsonSerializable(fieldRename: FieldRename.snake)
class Account {
  const Account({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
    required this.aktif,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String username;
  final AppRole role;
  final bool aktif;
  final DateTime createdAt;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
