import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';

part 'profile.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.role,
    this.phone,
    this.aktif = true,
    this.notificationEmail,
    this.emailBildirimAktif = true,
  });

  final String id;
  final String fullName;
  final AppRole role;
  final String? phone;
  final bool aktif;

  /// Gerçek bildirim e-postası (giriş için kullanılan sahte @dedemmekatronik.com
  /// adresinden farklı) — kullanıcı kendi profilinden girer.
  final String? notificationEmail;

  /// Yönetici/admin'in kendi profilinden açıp kapatabileceği "yeni durak
  /// bildirimlerini e-posta ile al" tercihi.
  final bool emailBildirimAktif;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
