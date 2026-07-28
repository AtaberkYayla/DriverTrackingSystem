import 'package:json_annotation/json_annotation.dart';

part 'mail_settings.g.dart';

/// backend/mail_settings.php'nin GET yanitini tasir. Sifre alani hicbir zaman
/// sunucudan geri donmez - sadece `hasPassword` ile dolu olup olmadigi bilinir.
@JsonSerializable(fieldRename: FieldRename.snake)
class MailSettings {
  const MailSettings({
    this.smtpHost,
    this.smtpPort,
    this.useSsl = true,
    this.fromEmail,
    this.fromName,
    this.smtpUser,
    this.hasPassword = false,
  });

  final String? smtpHost;
  final int? smtpPort;
  final bool useSsl;
  final String? fromEmail;
  final String? fromName;
  final String? smtpUser;
  final bool hasPassword;

  factory MailSettings.fromJson(Map<String, dynamic> json) => _$MailSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$MailSettingsToJson(this);
}
