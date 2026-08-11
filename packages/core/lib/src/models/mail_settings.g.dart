// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MailSettings _$MailSettingsFromJson(Map<String, dynamic> json) => MailSettings(
  smtpHost: json['smtp_host'] as String?,
  smtpPort: (json['smtp_port'] as num?)?.toInt(),
  useSsl: json['use_ssl'] as bool? ?? true,
  fromEmail: json['from_email'] as String?,
  fromName: json['from_name'] as String?,
  smtpUser: json['smtp_user'] as String?,
  hasPassword: json['has_password'] as bool? ?? false,
);

Map<String, dynamic> _$MailSettingsToJson(MailSettings instance) =>
    <String, dynamic>{
      'smtp_host': instance.smtpHost,
      'smtp_port': instance.smtpPort,
      'use_ssl': instance.useSsl,
      'from_email': instance.fromEmail,
      'from_name': instance.fromName,
      'smtp_user': instance.smtpUser,
      'has_password': instance.hasPassword,
    };
