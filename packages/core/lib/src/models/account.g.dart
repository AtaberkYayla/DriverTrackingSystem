// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  username: json['username'] as String,
  role: $enumDecode(_$AppRoleEnumMap, json['role']),
  aktif: json['aktif'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'username': instance.username,
  'role': instance.role,
  'aktif': instance.aktif,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$AppRoleEnumMap = {
  AppRole.driver: 'driver',
  AppRole.office: 'office',
  AppRole.manager: 'manager',
  AppRole.admin: 'admin',
};
